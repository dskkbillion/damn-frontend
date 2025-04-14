import 'package:equatable/equatable.dart';

class IndexDataDto extends Equatable {
  final int totalEarnings;
  final int thisMonthTotalEarnings;
  final int totalOrderNum; // Remember this is for overall stats
  final int activeOrderNum;
  final int pendingOrderNum;
  final int receiptOrderNum;
  final int earlyTime;
  final int latenessTime;

  const IndexDataDto({
    required this.totalEarnings,
    required this.thisMonthTotalEarnings,
    required this.totalOrderNum,
    required this.activeOrderNum,
    required this.pendingOrderNum,
    required this.receiptOrderNum,
    required this.earlyTime,
    required this.latenessTime,
  });

  factory IndexDataDto.fromJson(Map<String, dynamic> json) {
    return IndexDataDto(
      totalEarnings: json['totalEarnings'] as int,
      thisMonthTotalEarnings: json['thisMonthTotalEarnings'] as int,
      totalOrderNum: json['totalOrderNum'] as int, // Source for overallTotalOrderCount
      activeOrderNum: json['activeOrderNum'] as int,
      pendingOrderNum: json['pendingOrderNum'] as int,
      receiptOrderNum: json['receiptOrderNum'] as int,
      earlyTime: json['earlyTime'] as int,
      latenessTime: json['latenessTime'] as int,
    );
  }

  @override
  List<Object?> get props => [
        totalEarnings,
        thisMonthTotalEarnings,
        totalOrderNum,
        activeOrderNum,
        pendingOrderNum,
        receiptOrderNum,
        earlyTime,
        latenessTime,
      ];
} 