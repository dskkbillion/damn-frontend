// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_statistics_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SellerUpgradeStatisticsDtoImpl _$$SellerUpgradeStatisticsDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SellerUpgradeStatisticsDtoImpl(
      days: (json['days'] as num?)?.toInt() ?? 0,
      orderNum: (json['orderNum'] as num?)?.toInt() ?? 0,
      orderPrice: (json['orderPrice'] as num?)?.toDouble() ?? 0.0,
      totalDays: (json['totalDays'] as num?)?.toInt() ?? 0,
      totalOrderNum: (json['totalOrderNum'] as num?)?.toInt() ?? 0,
      totalOrderPrice: (json['totalOrderPrice'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$SellerUpgradeStatisticsDtoImplToJson(
        _$SellerUpgradeStatisticsDtoImpl instance) =>
    <String, dynamic>{
      'days': instance.days,
      'orderNum': instance.orderNum,
      'orderPrice': instance.orderPrice,
      'totalDays': instance.totalDays,
      'totalOrderNum': instance.totalOrderNum,
      'totalOrderPrice': instance.totalOrderPrice,
    };

_$SellerIndexStatisticsDtoImpl _$$SellerIndexStatisticsDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SellerIndexStatisticsDtoImpl(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      thisMonthTotalEarnings:
          (json['thisMonthTotalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalOrderNum: (json['totalOrderNum'] as num?)?.toInt() ?? 0,
      activeOrderNum: (json['activeOrderNum'] as num?)?.toInt() ?? 0,
      pendingOrderNum: (json['pendingOrderNum'] as num?)?.toInt() ?? 0,
      receiptOrderNum: (json['receiptOrderNum'] as num?)?.toInt() ?? 0,
      earlyTime: (json['earlyTime'] as num?)?.toInt() ?? 0,
      latenessTime: (json['latenessTime'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SellerIndexStatisticsDtoImplToJson(
        _$SellerIndexStatisticsDtoImpl instance) =>
    <String, dynamic>{
      'totalEarnings': instance.totalEarnings,
      'thisMonthTotalEarnings': instance.thisMonthTotalEarnings,
      'totalOrderNum': instance.totalOrderNum,
      'activeOrderNum': instance.activeOrderNum,
      'pendingOrderNum': instance.pendingOrderNum,
      'receiptOrderNum': instance.receiptOrderNum,
      'earlyTime': instance.earlyTime,
      'latenessTime': instance.latenessTime,
    };

_$SellerPercentStatisticsDtoImpl _$$SellerPercentStatisticsDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SellerPercentStatisticsDtoImpl(
      heatPercent: (json['heatPercent'] as num?)?.toDouble() ?? 0.0,
      recoverPercent: (json['recoverPercent'] as num?)?.toDouble() ?? 0.0,
      completePercent: (json['completePercent'] as num?)?.toDouble() ?? 0.0,
      goodPercent: (json['goodPercent'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$SellerPercentStatisticsDtoImplToJson(
        _$SellerPercentStatisticsDtoImpl instance) =>
    <String, dynamic>{
      'heatPercent': instance.heatPercent,
      'recoverPercent': instance.recoverPercent,
      'completePercent': instance.completePercent,
      'goodPercent': instance.goodPercent,
    };
