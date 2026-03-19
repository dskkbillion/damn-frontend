import '../../../../core/utils/data_mapper.dart'; // Assuming you have helper for safe parsing
import '../../domain/entities/after_sales_application.dart';

class AfterSalesApplicationModel extends AfterSalesApplication {
  const AfterSalesApplicationModel({
    required super.id,
    super.buyerId,
    super.tenantId,
    required super.orderId,
    required super.orderItemId,
    super.productId,
    super.variantId,
    super.productName,
    super.variantName,
    super.productImage,
    super.refundSn,
    required super.refundType,
    super.refundReason,
    super.refundExplain,
    super.refundImage,
    super.refundNumber,
    super.refundPrice,
    required super.refundState,
    super.finalState,
    super.refundAddress,
    super.auditRemark,
    super.auditTime,
    super.shipTime,
    super.confirmTime,
    super.cancelTime,
    super.memberType,
    super.auditType,
    super.refundStateText,
    super.refundTypeText,
    super.orderState,
    super.createTime,
    super.updateTime,
  });

  factory AfterSalesApplicationModel.fromJson(Map<String, dynamic> json) {
    final orderVo = json['orderVo'] is Map<String, dynamic>
        ? json['orderVo'] as Map<String, dynamic>
        : null;
    return AfterSalesApplicationModel(
      id: DataMapper.toInt(json['id']), 
      buyerId: DataMapper.toIntN(json['buyerId']),
      tenantId: DataMapper.toIntN(json['tenantId']),
      orderId: DataMapper.toInt(json['orderId']), 
      orderItemId: DataMapper.toInt(json['orderItemId']), 
      productId: DataMapper.toIntN(json['productId']),
      variantId: DataMapper.toIntN(json['variantId']),
      productName: DataMapper.toStringN(json['productName']),
      variantName: DataMapper.toStringN(json['variantName']),
      productImage: DataMapper.toStringN(json['productImage']),
      refundSn: DataMapper.toStringN(json['refundSn']),
      refundType: DataMapper.toStringVal(json['refundType'], fallback: 'UNKNOWN'), // Provide fallback
      refundReason: DataMapper.toStringN(json['refundReason']),
      refundExplain: DataMapper.toStringN(json['refundExplain']),
      refundImage: DataMapper.toStringListN(json['refundImage']),
      refundNumber: DataMapper.toIntN(json['refundNumber']),
      refundPrice: DataMapper.toDoubleN(json['refundPrice']),
      refundState: DataMapper.toStringVal(json['refundState'], fallback: 'UNKNOWN'), // Provide fallback
      finalState: DataMapper.toStringN(json['finalState']),
      refundAddress: DataMapper.toStringN(json['refundAddress']),
      auditRemark: DataMapper.toStringN(json['auditRemark']),
      auditTime: DataMapper.toDateTimeN(json['auditTime']),
      shipTime: DataMapper.toDateTimeN(json['shipTime']),
      confirmTime: DataMapper.toDateTimeN(json['confirmTime']),
      cancelTime: DataMapper.toDateTimeN(json['cancelTime']),
      memberType: DataMapper.toStringN(json['memberType']),
      auditType: DataMapper.toStringN(json['auditType']),
      refundStateText: DataMapper.toStringN(json['refundStateText']),
      refundTypeText: DataMapper.toStringN(json['refundTypeText']),
      orderState: DataMapper.toStringN(orderVo?['state']),
      createTime: DataMapper.toDateTimeN(json['createTime']),
      updateTime: DataMapper.toDateTimeN(json['updateTime']),
    );
  }

  // toJson might be needed if you ever need to send the full object back,
  // but usually only specific fields are sent for updates/creation.
  // Map<String, dynamic> toJson() { ... }
} 
