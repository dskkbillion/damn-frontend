import 'dart:convert';

import 'package:dskk_flutter_refactor/features/seller/data/models/order_product_item_dto.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/order_refund_state.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/refund_type.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/order_refund.dart';

/// 售后退款DTO
/// 与API响应的数据格式一致
class OrderRefundDto {
  /// 退款ID
  final int? id;
  
  /// 申请人ID
  final int? creatorId;
  
  /// 退款状态
  final String? refundState;
  
  /// 退款类型
  final String? refundType;
  
  /// 退款原因
  final String? refundReason;
  
  /// 退款备注
  final String? refundRemarks;
  
  /// 退款金额
  final double? refundAmount;
  
  /// 审核备注
  final String? auditRemark;
  
  /// 创建时间
  final String? createTime;
  
  /// 图片列表
  final List<String>? images;
  
  /// 订单信息
  final Map<String, dynamic>? order;
  
  /// 订单商品项
  final Map<String, dynamic>? orderProductItem;

  /// 构造函数
  OrderRefundDto({
    this.id,
    this.creatorId,
    this.refundState,
    this.refundType,
    this.refundReason,
    this.refundRemarks,
    this.refundAmount,
    this.auditRemark,
    this.createTime,
    this.images,
    this.order,
    this.orderProductItem,
  });

  /// 从JSON创建DTO
  factory OrderRefundDto.fromJson(Map<String, dynamic> json) {
    return OrderRefundDto(
      id: json['id'] as int?,
      creatorId: json['creatorId'] as int?,
      refundState: json['refundState'] as String?,
      refundType: json['refundType'] as String?,
      refundReason: json['refundReason'] as String?,
      refundRemarks: json['refundRemarks'] as String?,
      refundAmount: (json['refundAmount'] as num?)?.toDouble(),
      auditRemark: json['auditRemark'] as String?,
      createTime: json['createTime'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      order: json['order'] as Map<String, dynamic>?,
      orderProductItem: json['orderProductItem'] as Map<String, dynamic>?,
    );
  }

  /// 转换为领域实体
  OrderRefund toEntity() {
    DateTime? parsedCreateTime;
    
    try {
      if (createTime != null && createTime!.isNotEmpty) {
        parsedCreateTime = DateTime.parse(createTime!);
      }
    } catch (_) {
      // 如果解析失败，使用当前时间
      parsedCreateTime = DateTime.now();
    }

    // // 解析商品项数据 (暂时不需要，OrderRefund 实体没有直接包含这些)
    // OrderProductItemDto? productItemDto;
    // if (orderProductItem != null) {
    //   productItemDto = OrderProductItemDto.fromJson(orderProductItem!);
    // }

    return OrderRefund(
      id: id ?? 0,
      orderId: order?['id'] as int? ?? 0,
      orderSn: order?['orderSn'] as String? ?? '',
      refundSn: id?.toString() ?? 'unknown', // 使用 id 作为占位符
      refundPrice: ((refundAmount ?? 0.0) * 100).toInt(), // 转换为分
      reason: refundReason ?? '',
      credentials: images ?? [], // 使用 images 填充 credentials
      state: OrderRefundState.fromValue(refundState ?? ''),
      type: RefundType.fromValue(refundType ?? ''),
      applyTime: parsedCreateTime ?? DateTime.now(), // 使用 createTime
      // 可选参数可以保持默认 null
      // auditTime: ..., 
      // finishTime: ..., 
      // refuseReason: ..., 
      // receiveAddress: ..., 
      // ...
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (creatorId != null) 'creatorId': creatorId,
      if (refundState != null) 'refundState': refundState,
      if (refundType != null) 'refundType': refundType,
      if (refundReason != null) 'refundReason': refundReason,
      if (refundRemarks != null) 'refundRemarks': refundRemarks,
      if (refundAmount != null) 'refundAmount': refundAmount,
      if (auditRemark != null) 'auditRemark': auditRemark,
      if (createTime != null) 'createTime': createTime,
      if (images != null) 'images': images,
      if (order != null) 'order': order,
      if (orderProductItem != null) 'orderProductItem': orderProductItem,
    };
  }
}

/// 分页列表DTO
class PaginatedListDto<T> {
  /// 总记录数
  final int total;
  
  /// 记录列表
  final List<T> records;

  PaginatedListDto({
    required this.total,
    required this.records,
  });

  /// 从JSON创建分页列表DTO
  factory PaginatedListDto.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    return PaginatedListDto<T>(
      total: json['total'] as int? ?? 0,
      records: (json['records'] as List<dynamic>?)
              ?.map((e) => fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
} 