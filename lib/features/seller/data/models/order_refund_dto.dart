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

  final String? refundExplain;

  final String? refundSn;

  /// 退款备注
  final String? refundRemarks;

  /// 退款金额
  final double? refundAmount;

  final double? refundPrice;

  /// 审核备注
  final String? auditRemark;

  /// 创建时间
  final String? createTime;

  final String? auditTime;

  final String? finishTime;

  /// 图片列表
  final List<String>? images;

  /// 订单信息
  final Map<String, dynamic>? order;

  final Map<String, dynamic>? orderVo;

  /// 订单商品项
  final Map<String, dynamic>? orderProductItem;

  /// 构造函数
  OrderRefundDto({
    this.id,
    this.creatorId,
    this.refundState,
    this.refundType,
    this.refundReason,
    this.refundExplain,
    this.refundSn,
    this.refundRemarks,
    this.refundAmount,
    this.refundPrice,
    this.auditRemark,
    this.createTime,
    this.auditTime,
    this.finishTime,
    this.images,
    this.order,
    this.orderVo,
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
      refundExplain: json['refundExplain'] as String?,
      refundSn: json['refundSn'] as String?,
      refundRemarks: json['refundRemarks'] as String?,
      refundAmount: (json['refundAmount'] as num?)?.toDouble(),
      refundPrice: (json['refundPrice'] as num?)?.toDouble(),
      auditRemark: json['auditRemark'] as String?,
      createTime: json['createTime'] as String?,
      auditTime: json['auditTime'] as String?,
      finishTime: json['finishTime'] as String?,
      images: ((json['images'] ?? json['credentials']) as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      order: json['order'] as Map<String, dynamic>?,
      orderVo: json['orderVo'] as Map<String, dynamic>?,
      orderProductItem: json['orderProductItem'] as Map<String, dynamic>?,
    );
  }

  /// 转换为领域实体
  OrderRefund toEntity() {
    final orderData = orderVo ?? order;
    final parsedCreateTime = _parseDateTime(createTime) ?? DateTime.now();
    final parsedAuditTime = _parseDateTime(auditTime);
    final parsedFinishTime = _parseDateTime(finishTime);
    final resolvedRefundPrice = refundPrice ?? refundAmount ?? 0.0;

    return OrderRefund(
      id: id ?? 0,
      orderId: (orderData?['id'] as int?) ?? 0,
      orderSn: (jsonString(orderData?['orderSn']) ??
          jsonString(orderData?['orderNo']) ??
          jsonString(orderData?['sn']) ??
          ''),
      refundSn: refundSn ?? id?.toString() ?? 'unknown',
      refundPrice: (resolvedRefundPrice * 100).toInt(),
      reason: refundReason ?? refundExplain ?? '',
      credentials: images ?? [],
      state: OrderRefundState.fromValue(refundState ?? ''),
      type: RefundType.fromValue(refundType ?? ''),
      applyTime: parsedCreateTime,
      auditTime: parsedAuditTime,
      finishTime: parsedFinishTime,
      refuseReason: auditRemark,
    );
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(value.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  String? jsonString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (creatorId != null) 'creatorId': creatorId,
      if (refundState != null) 'refundState': refundState,
      if (refundType != null) 'refundType': refundType,
      if (refundReason != null) 'refundReason': refundReason,
      if (refundExplain != null) 'refundExplain': refundExplain,
      if (refundSn != null) 'refundSn': refundSn,
      if (refundRemarks != null) 'refundRemarks': refundRemarks,
      if (refundAmount != null) 'refundAmount': refundAmount,
      if (refundPrice != null) 'refundPrice': refundPrice,
      if (auditRemark != null) 'auditRemark': auditRemark,
      if (createTime != null) 'createTime': createTime,
      if (auditTime != null) 'auditTime': auditTime,
      if (finishTime != null) 'finishTime': finishTime,
      if (images != null) 'images': images,
      if (order != null) 'order': order,
      if (orderVo != null) 'orderVo': orderVo,
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
    // 优先尝试解析 'rows' 字段 (根据API日志)，如果不存在则回退到 'records'
    final listData = json['rows'] ?? json['records'];

    return PaginatedListDto<T>(
      total: json['total'] as int? ?? 0,
      records: (listData as List<dynamic>?)
              ?.map((e) => fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
