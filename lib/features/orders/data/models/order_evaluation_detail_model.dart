import '../../domain/entities/order_evaluation_detail.dart';
import 'member_model.dart';

class OrderEvaluationDetailModel {
  final int? memberId;
  final int? score;
  final String? remark;
  final List<String> images;
  final bool? anonymityFlag;
  final MemberModel? buyer;
  final DateTime? createTime;

  const OrderEvaluationDetailModel({
    this.memberId,
    this.score,
    this.remark,
    this.images = const [],
    this.anonymityFlag,
    this.buyer,
    this.createTime,
  });

  factory OrderEvaluationDetailModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseOptionalDateTime(String? dateString) {
      if (dateString == null) return null;
      return DateTime.tryParse(dateString);
    }

    return OrderEvaluationDetailModel(
      memberId: json['memberId'] as int?,
      score: json['score'] as int?,
      remark: json['remark'] as String?,
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      anonymityFlag: json['anonymityFlag'] as bool?,
      buyer: json['buyer'] is Map<String, dynamic>
          ? MemberModel.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
      createTime: parseOptionalDateTime(json['createTime']?.toString()),
    );
  }

  OrderEvaluationDetail toEntity() {
    return OrderEvaluationDetail(
      memberId: memberId,
      score: score,
      remark: remark,
      images: images,
      anonymityFlag: anonymityFlag,
      buyer: buyer?.toEntity(),
      createTime: createTime,
    );
  }
}
