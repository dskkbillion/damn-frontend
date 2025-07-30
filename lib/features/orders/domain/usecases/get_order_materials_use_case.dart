import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_materials.dart';
import '../entities/order_delivery.dart';
import '../repositories/i_order_repository.dart';

/// 获取订单材料和交付信息的用例
@injectable
class GetOrderMaterialsUseCase implements UseCase<OrderMaterialsAndDeliveries, GetOrderMaterialsParams> {
  final IOrderRepository repository;

  GetOrderMaterialsUseCase(this.repository);

  @override
  Future<Either<Failure, OrderMaterialsAndDeliveries>> call(GetOrderMaterialsParams params) async {
    // 并行获取材料和交付信息
    final materialsResult = await repository.getOrderMaterials(params.orderId);
    final deliveriesResult = await repository.getOrderDeliveries(params.orderId);

    // 检查两个请求的结果
    return materialsResult.fold(
      (failure) => Left(failure),
      (materials) => deliveriesResult.fold(
        (failure) => Left(failure),
        (deliveries) => Right(OrderMaterialsAndDeliveries(
          materials: materials,
          deliveries: deliveries,
        )),
      ),
    );
  }
}

/// 参数类
class GetOrderMaterialsParams {
  final int orderId;

  GetOrderMaterialsParams({required this.orderId});
}

/// 返回结果类
class OrderMaterialsAndDeliveries {
  final List<OrderMaterials> materials;
  final List<OrderDelivery> deliveries;

  OrderMaterialsAndDeliveries({
    required this.materials,
    required this.deliveries,
  });
}