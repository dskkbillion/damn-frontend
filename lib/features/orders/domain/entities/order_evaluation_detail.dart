import 'package:equatable/equatable.dart';

import 'member.dart';

class OrderEvaluationDetail extends Equatable {
  final int? memberId;
  final int? score;
  final String? remark;
  final List<String> images;
  final bool? anonymityFlag;
  final Member? buyer;
  final DateTime? createTime;

  const OrderEvaluationDetail({
    this.memberId,
    this.score,
    this.remark,
    this.images = const [],
    this.anonymityFlag,
    this.buyer,
    this.createTime,
  });

  @override
  List<Object?> get props => [
        memberId,
        score,
        remark,
        images,
        anonymityFlag,
        buyer,
        createTime,
      ];
}
