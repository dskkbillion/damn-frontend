// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_statistics_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SellerUpgradeStatisticsDtoImpl _$$SellerUpgradeStatisticsDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$SellerUpgradeStatisticsDtoImpl(
      days: (json['days'] as num).toInt(),
      orderNum: (json['orderNum'] as num).toInt(),
      orderPrice: (json['orderPrice'] as num).toDouble(),
      totalDays: (json['totalDays'] as num).toInt(),
      totalOrderNum: (json['totalOrderNum'] as num).toInt(),
      totalOrderPrice: (json['totalOrderPrice'] as num).toDouble(),
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
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      thisMonthTotalEarnings:
          (json['thisMonthTotalEarnings'] as num).toDouble(),
      totalOrderNum: (json['totalOrderNum'] as num).toInt(),
      activeOrderNum: (json['activeOrderNum'] as num).toInt(),
      pendingOrderNum: (json['pendingOrderNum'] as num).toInt(),
      receiptOrderNum: (json['receiptOrderNum'] as num).toInt(),
      earlyTime: (json['earlyTime'] as num).toInt(),
      latenessTime: (json['latenessTime'] as num).toInt(),
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
      heatPercent: (json['heatPercent'] as num).toDouble(),
      recoverPercent: (json['recoverPercent'] as num).toDouble(),
      completePercent: (json['completePercent'] as num).toDouble(),
      goodPercent: (json['goodPercent'] as num).toDouble(),
    );

Map<String, dynamic> _$$SellerPercentStatisticsDtoImplToJson(
        _$SellerPercentStatisticsDtoImpl instance) =>
    <String, dynamic>{
      'heatPercent': instance.heatPercent,
      'recoverPercent': instance.recoverPercent,
      'completePercent': instance.completePercent,
      'goodPercent': instance.goodPercent,
    };
