import 'package:equatable/equatable.dart';

class UpgradeLevelDataDto extends Equatable {
  final int days;
  final int orderNum;
  final int orderPrice;
  final int totalDays;
  final int totalOrderNum; // Remember this is for upgrade progress
  final int totalOrderPrice;

  const UpgradeLevelDataDto({
    required this.days,
    required this.orderNum,
    required this.orderPrice,
    required this.totalDays,
    required this.totalOrderNum,
    required this.totalOrderPrice,
  });

  factory UpgradeLevelDataDto.fromJson(Map<String, dynamic> json) {
    return UpgradeLevelDataDto(
      days: json['days'] as int,
      orderNum: json['orderNum'] as int,
      orderPrice: json['orderPrice'] as int,
      totalDays: json['totalDays'] as int,
      totalOrderNum: json['totalOrderNum'] as int, // Source for upgradeProgressOrderCount
      totalOrderPrice: json['totalOrderPrice'] as int,
    );
  }

  @override
  List<Object?> get props => [
        days,
        orderNum,
        orderPrice,
        totalDays,
        totalOrderNum,
        totalOrderPrice,
      ];
} 