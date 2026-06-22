import 'package:dartz/dartz.dart' hide Order;
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_detail_use_case.dart';
import 'package:dskk_flutter_refactor/features/payment/presentation/pages/payment_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// 修复项2 回归测试：支付 success 直跳后,PaymentResultPage 应启动一次「预热」短轮询
/// (≤3 次,每 3s),等后端 webhook 把订单状态翻出 awaitingPayment;命中即停;
/// 且轮询全程不修改 _status(页面始终保持「支付成功」),不污染 pending 的进度文案。
///
/// 用 fake GetOrderDetailUseCase 驱动,不依赖 staging webhook,确定性可重复。
class _FakeGetOrderDetailUseCase implements GetOrderDetailUseCase {
  _FakeGetOrderDetailUseCase(this._results);

  /// 每次 call 依序返回的结果;用尽后重复最后一项。
  final List<Either<Failure, Order>> _results;
  int callCount = 0;

  @override
  Future<Either<Failure, Order>> call(int params) async {
    final idx = callCount < _results.length ? callCount : _results.length - 1;
    callCount++;
    return _results[idx];
  }

  @override
  IOrderRepository get repository => throw UnimplementedError();
}

/// 极简 Order 替身:只暴露 state,其余字段在本测试中不被读取。
class _FakeOrder implements Order {
  _FakeOrder(this._state);
  final OrderStatus _state;

  @override
  OrderStatus get state => _state;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final getIt = GetIt.instance;

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PaymentResultPage(
          initialStatus: PaymentResultStatus.success,
          orderId: '779',
        ),
      ),
    );
  }

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('success 直跳即启动预热轮询,命中非 awaitingPayment 后停止', (tester) async {
    // 第一次轮询仍 awaitingPayment,第二次翻成 awaitingConfirmation → 应停止。
    final fake = _FakeGetOrderDetailUseCase([
      Right(_FakeOrder(OrderStatus.awaitingPayment)),
      Right(_FakeOrder(OrderStatus.awaitingConfirmation)),
    ]);
    getIt.registerSingleton<GetOrderDetailUseCase>(fake);

    await pumpPage(tester);

    // 进入后页面立即显示「支付成功」。
    expect(find.text('支付成功'), findsWidgets);
    expect(fake.callCount, 0);

    // 推进到第 1 次轮询(3s)。
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(); // flush async fold
    expect(fake.callCount, 1);

    // 推进到第 2 次轮询(再 3s),此时返回 awaitingConfirmation,应停止。
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(fake.callCount, 2);

    // 再推进 6s,轮询已停止,callCount 不再增长。
    await tester.pump(const Duration(seconds: 6));
    await tester.pump();
    expect(fake.callCount, 2, reason: '命中后应停止,不再继续轮询');

    // 全程 _status 不变:页面始终是「支付成功」,绝不出现 pending 的进度文案。
    expect(find.text('支付成功'), findsWidgets);
    expect(find.textContaining('正在向后端确认'), findsNothing);
  });

  testWidgets('预热轮询最多 3 次(9s)后自行停止,且不把 _status 改为 failure', (tester) async {
    // 始终 awaitingPayment → 轮询永不命中,应在 3 次后停。
    final fake = _FakeGetOrderDetailUseCase([
      Right(_FakeOrder(OrderStatus.awaitingPayment)),
    ]);
    getIt.registerSingleton<GetOrderDetailUseCase>(fake);

    await pumpPage(tester);

    // 推进足够长时间(覆盖 >3 次的间隔)。
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
    }

    // 上限 _maxSuccessPolls=3:最多调用 3 次后停止。
    expect(fake.callCount, 3, reason: 'success 预热轮询上限为 3 次');

    // 关键:success 轮询超时不得像 pending 那样翻成 failure,页面仍是「支付成功」。
    expect(find.text('支付成功'), findsWidgets);
    expect(find.text('支付失败'), findsNothing);
  });
}
