import 'package:dskk_flutter_refactor/features/orders/data/models/address_model.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_payment_info.dart';
import '../../domain/entities/order_price_summary.dart';
import '../../domain/entities/order_shipping_info.dart';
import '../../domain/entities/order_status.dart';
import 'member_model.dart';
import 'order_item_model.dart';

/// Data Transfer Object (DTO) for an Order, matching the API structure.
class OrderModel {
  final int id;
  final String orderSn; // Changed back from 'no' to match API and Entity
  final String state; // API 字段: state (字符串)
  final String? orderType;
  final List<OrderItemModel> items;
  // Use nested AddressModel instead of flat fields
  final AddressModel? address; // API: address (object)
  // 价格相关字段
  final double? totalPrice;
  final double? discountPrice;
  final double? deliveryPrice;
  final double? payPrice;
  // 支付相关字段
  // Removed payStatus as it doesn't seem to be in API response
  final DateTime? payTime;
  final String? payChannelCode;
  // 物流相关字段
  final int? logisticsId;
  final String? logisticsNo;
  final DateTime? deliveryTime;
  // 时间相关字段
  final DateTime? createTime; // API 字段: createTime
  final DateTime? completeTime;
  final DateTime? cancelTime;
  // 其他字段
  final String? buyerRemark;
  // 买家和卖家信息
  final MemberModel? buyer;
  final MemberModel? tenant;
  // 自动处理时间
  final DateTime? autoCancelTime;
  final DateTime? autoMaterialTime;
  final DateTime? autoOrderReceivinTime;
  final DateTime? deliveryTimestamp;
  // 是否已评价
  final bool? evaluate;

  const OrderModel({
    required this.id,
    required this.orderSn, // Changed back from 'no'
    required this.state,
    this.orderType,
    required this.items,
    this.address, // Changed from receiver fields
    this.totalPrice,
    this.discountPrice,
    this.deliveryPrice,
    this.payPrice,
    // Removed payStatus
    this.payTime,
    this.payChannelCode,
    this.logisticsId,
    this.logisticsNo,
    this.deliveryTime,
    this.createTime, // Changed from createdAt
    this.completeTime,
    this.cancelTime,
    this.buyerRemark,
    this.buyer,
    this.tenant,
    this.autoCancelTime,
    this.autoMaterialTime,
    this.autoOrderReceivinTime,
    this.deliveryTimestamp,
    this.evaluate,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItemModel>[];
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((itemJson) => OrderItemModel.fromJson(itemJson))
          .toList();
    }

    DateTime? parseOptionalDateTime(String? dateString) {
       if (dateString == null) return null;
      // Handle potential integer timestamps from API (milliseconds since epoch)
      if (int.tryParse(dateString) != null) {
          try {
              return DateTime.fromMillisecondsSinceEpoch(int.parse(dateString));
          } catch (_) {
               // Fall through to try parsing as string
          }
      }
      // Try parsing as ISO string
      try {
          return DateTime.tryParse(dateString);
      } catch (_) {
        return null;
      }
    }

    // Parse address object
    AddressModel? parsedAddress;
    if (json['address'] != null && json['address'] is Map<String, dynamic>) {
       try {
         parsedAddress = AddressModel.fromJson(json['address']);
       } catch (e) {
         print('Error parsing address: $e'); // Log error if parsing fails
         parsedAddress = null;
       }
    }
    
    // Parse buyer and tenant
    MemberModel? parsedBuyer;
    if (json['buyer'] != null && json['buyer'] is Map<String, dynamic>) {
      try {
        parsedBuyer = MemberModel.fromJson(json['buyer']);
      } catch (e) {
        print('Error parsing buyer: $e');
      }
    }
    
    MemberModel? parsedTenant;
    if (json['tenant'] != null && json['tenant'] is Map<String, dynamic>) {
      try {
        parsedTenant = MemberModel.fromJson(json['tenant']);
      } catch (e) {
        print('Error parsing tenant: $e');
      }
    }

    return OrderModel(
      id: json['id'] as int? ?? 0,
      orderSn: json['orderSn'] as String? ?? '', // Use 'orderSn' key from API
      state: json['state'] as String? ?? 'unknown',
      orderType: json['orderType'] as String?,
      items: itemsList,
      address: parsedAddress, // Assign parsed address
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      deliveryPrice: (json['deliveryPrice'] as num?)?.toDouble(),
      payPrice: (json['payPrice'] as num?)?.toDouble(),
      // Removed payStatus
      payTime: parseOptionalDateTime(json['payTime']?.toString()), // Ensure input is String?
      payChannelCode: json['payChannelCode'] as String?,
      logisticsId: json['logisticsId'] as int?,
      logisticsNo: json['logisticsNo'] as String?,
      deliveryTime: parseOptionalDateTime(json['deliveryTime']?.toString()),
      createTime: parseOptionalDateTime(json['createTime']?.toString()), // Use 'createTime' key
      completeTime: parseOptionalDateTime(json['completeTime']?.toString()),
      cancelTime: parseOptionalDateTime(json['cancelTime']?.toString()),
      buyerRemark: json['buyerRemark'] as String?,
      buyer: parsedBuyer,
      tenant: parsedTenant,
      autoCancelTime: parseOptionalDateTime(json['autoCancelTime']?.toString()),
      autoMaterialTime: parseOptionalDateTime(json['autoMaterialTime']?.toString()),
      autoOrderReceivinTime: parseOptionalDateTime(json['autoOrderReceivinTime']?.toString()),
      deliveryTimestamp: parseOptionalDateTime(json['deliveryTimestamp']?.toString()),
      evaluate: json['evaluate'] as bool?,
    );
  }

  /// Converts this Data Transfer Object to a Domain [Order] entity.
  Order toEntity() {
    // Build Address from AddressModel or provide default
    final domainAddress = address?.toEntity() ?? const Address(recipientName: '', phone: '', areaId: '', detailAddress: '');

    final priceSummary = OrderPriceSummary(
      totalPrice: totalPrice ?? 0.0,
      discountPrice: discountPrice ?? 0.0,
      deliveryPrice: deliveryPrice ?? 0.0,
      payPrice: payPrice ?? 0.0,
    );

    // Determine payStatus based on payTime in the domain layer
    final paymentInfo = OrderPaymentInfo(
      payStatus: payTime != null,
      payTime: payTime,
      payChannelCode: payChannelCode,
    );

    final shippingInfo = OrderShippingInfo(
      logisticsId: logisticsId,
      logisticsNo: logisticsNo,
      deliveryTime: deliveryTime,
    );

    return Order(
      id: id,
      orderSn: orderSn, // Now directly maps model.orderSn to entity.orderSn
      state: OrderStatus.fromString(state),
      orderType: orderType,
      items: items.map((itemModel) => itemModel.toEntity()).toList(),
      shippingAddress: domainAddress, // Use converted or default address
      priceSummary: priceSummary,
      paymentInfo: paymentInfo,
      shippingInfo: shippingInfo,
      createdAt: createTime ?? DateTime(1970), // Map createTime to createdAt
      completeTime: completeTime,
      cancelTime: cancelTime,
      buyerRemark: buyerRemark,
      buyer: buyer?.toEntity(),
      tenant: tenant?.toEntity(),
      autoCancelTime: autoCancelTime,
      autoMaterialTime: autoMaterialTime,
      autoOrderReceivinTime: autoOrderReceivinTime,
      deliveryTimestamp: deliveryTimestamp,
      evaluate: evaluate,
    );
  }

  // OrderModel 不需要继承 Equatable，因为它主要用于数据传输和转换
} 