import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart'; // 引入 Equatable 支持 GetOrderListParams
import 'package:injectable/injectable.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart'; // 现在路径应该有效
import '../entities/order.dart';
import '../entities/order_status.dart';
import '../repositories/i_order_repository.dart'; // 实现类需要依赖 Repository 接口
// import '../repositories/i_order_repository.dart'; // UseCase 接口定义本身不直接依赖 Repository

/// 获取订单列表的用例接口。
/// 定义了获取订单列表的输入参数和输出类型。
@injectable
class GetOrderListUseCase implements UseCase<List<Order>, GetOrderListParams> {
  // 继承自 UseCase<OutputType, ParamsType>
  // 这里 OutputType 是 List<Order>
  // ParamsType 是 GetOrderListParams (下面定义)

  // UseCase 接口主要用于类型约束，可以不包含具体方法签名，
  // 或者显式声明 call 方法签名以明确。
  final IOrderRepository repository;

  GetOrderListUseCase(this.repository);

  @override
  Future<Either<Failure, List<Order>>> call(GetOrderListParams params) async {
    // 直接调用 Repository 的方法并返回结果
    return await repository.getOrderList(
      status: params.status,
      keyword: params.keyword,
      productId: params.productId,
      page: params.page,
      limit: params.limit,
      userRole: params.userRole,
      forceRefresh: params.forceRefresh,
    );
  }
}

/// [GetOrderListUseCase] 的输入参数。
class GetOrderListParams extends Equatable { // 继承 Equatable
  final OrderStatus? status;
  final String? keyword;
  final int? productId;
  final int page;
  final int limit;
  final String userRole; // Ensure it's final String, not String?
  final bool forceRefresh; // 强制刷新，绕过缓存

  const GetOrderListParams({
    this.status,
    this.keyword,
    this.productId,
    required this.page,
    required this.limit,
    required this.userRole, // Ensure it's required
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [status, keyword, productId, page, limit, userRole, forceRefresh];
}
