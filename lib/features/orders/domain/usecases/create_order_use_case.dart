import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_order_repository.dart';
import '../entities/order_creation_result.dart';

/// 创建订单用例
@injectable
class CreateOrderUseCase {
  final IOrderRepository repository;

  CreateOrderUseCase(this.repository);
  
  /// 执行创建订单
  /// 
  /// 参数：
  /// [productId] - 商品ID
  /// [variantId] - 商品变体ID
  /// [quantity] - 数量
  /// [sellerId] - 卖家ID
  /// [price] - 价格
  /// 
  /// 返回 [OrderCreationResult] 或 [Failure]
  Future<Either<Failure, OrderCreationResult>> execute({
    required int productId,
    required int variantId,
    required int quantity,
    required int sellerId,
    required double price,
    int? chatRoomId,
  }) {
    return repository.createOrder(
      productId: productId,
      variantId: variantId,
      quantity: quantity,
      sellerId: sellerId,
      price: price,
      chatRoomId: chatRoomId,
    );
  }
}
