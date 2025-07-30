/// 订单材料实体
class OrderMaterials {
  final int id;
  final int productId;
  final int orderId;
  final List<MaterialFeature> features; // 问题及答案数据
  final List<String> files; // 附件文件URL列表
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderMaterials({
    required this.id,
    required this.productId, 
    required this.orderId,
    required this.features,
    required this.files,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderMaterials &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          orderId == other.orderId;

  @override
  int get hashCode => id.hashCode ^ productId.hashCode ^ orderId.hashCode;

  @override
  String toString() {
    return 'OrderMaterials{id: $id, productId: $productId, orderId: $orderId, features: $features, files: $files}';
  }
}

/// 材料特征（问题-答案对）
class MaterialFeature {
  final String question;
  final String answer;

  const MaterialFeature({
    required this.question,
    required this.answer,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
  };

  factory MaterialFeature.fromJson(Map<String, dynamic> json) {
    return MaterialFeature(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialFeature &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          answer == other.answer;

  @override
  int get hashCode => question.hashCode ^ answer.hashCode;

  @override
  String toString() => 'MaterialFeature{question: $question, answer: $answer}';
}