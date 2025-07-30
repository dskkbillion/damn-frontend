import '../models/order_materials_model.dart';
import '../models/order_delivery_model.dart';

/// 订单材料和交付远程数据源接口
abstract class IOrderMaterialsRemoteDataSource {
  /// 获取订单的材料信息
  Future<List<OrderMaterialsModel>> getOrderMaterials(int orderId);
  
  /// 获取订单的交付信息
  Future<List<OrderDeliveryModel>> getOrderDeliveries(int orderId);
  
  /// 根据ID获取特定材料详情
  Future<OrderMaterialsModel> getOrderMaterialById(int materialId);
  
  /// 根据ID获取特定交付详情
  Future<OrderDeliveryModel> getOrderDeliveryById(int deliveryId);
}