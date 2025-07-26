import 'package:equatable/equatable.dart';

/// 表示订单中的一个商品项。
class OrderItem extends Equatable {
  /// 订单项唯一标识符。
  final int id;

  /// 关联的订单 ID。
  final int orderId;

  /// 关联的产品 ID (SPU ID)。
  final int productId;

  /// 商品名称 (SPU Name)。
  final String productName;

  /// 商品规格 ID (SKU ID)。
  final int skuId;

  /// 规格描述 (例如 "红色, XL")，可能从 SKU 属性组合而来。
  final String? skuName; // API 字段: properties

  /// 商品图片 URL。
  final String imageUrl; // API 字段: picUrl

  /// 购买数量。
  final int quantity;

  /// 商品单价。
  final double price; // 使用 double 存储价格，或者考虑更精确的 Decimal 类型库

  /// 商品总价 (price * quantity)。
  final double totalPrice;
  
  /// 交付时间（天数）
  final int? deliveryDay;
  
  /// 可修改次数
  final int? editNum;

  /// 创建一个 [OrderItem] 实例。
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.skuId,
    this.skuName,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.deliveryDay,
    this.editNum,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        skuId,
        skuName,
        imageUrl,
        quantity,
        price,
        totalPrice,
        deliveryDay,
        editNum,
      ];
} 