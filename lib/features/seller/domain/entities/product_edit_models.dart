/// 产品编辑相关的基础数据模型
/// 从product_edit_page.dart中提取出来以减少代码复杂度

/// QA数据模型
class QAPair {
  String question;
  String answer;
  final String id; // 用于识别唯一性
  
  QAPair({
    required this.question,
    required this.answer,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  // 从JSON创建
  factory QAPair.fromJson(Map<String, dynamic> json) {
    return QAPair(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }
  
  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }
}

/// 买家信息类型枚举
enum BuyerInfoType {
  text('文字描述'),
  image('图片'),
  file('文件'),
  contact('联系方式'),
  requirement('需求说明'),
  reference('参考资料');
  
  const BuyerInfoType(this.displayName);
  final String displayName;
}

/// 买家信息项
class BuyerInfoItem {
  final BuyerInfoType type;
  final String label;
  final String description;
  final bool isRequired;
  
  BuyerInfoItem({
    required this.type,
    required this.label,
    required this.description,
    this.isRequired = false,
  });
  
  // 从JSON创建
  factory BuyerInfoItem.fromJson(Map<String, dynamic> json) {
    return BuyerInfoItem(
      type: BuyerInfoType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BuyerInfoType.text,
      ),
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      isRequired: json['isRequired'] ?? false,
    );
  }
  
  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'label': label,
      'description': description,
      'isRequired': isRequired,
    };
  }
}

/// 成功案例数据模型
class SuccessCase {
  final String id;
  final String imagePath;
  final String imageUrl;
  final String title;
  final String description;
  final DateTime createTime;
  
  SuccessCase({
    String? id,
    required this.imagePath,
    this.imageUrl = '',
    required this.title,
    required this.description,
    DateTime? createTime,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createTime = createTime ?? DateTime.now();
  
  // 从JSON创建
  factory SuccessCase.fromJson(Map<String, dynamic> json) {
    return SuccessCase(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: json['imagePath'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createTime: DateTime.tryParse(json['createTime'] ?? '') ?? DateTime.now(),
    );
  }
  
  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'createTime': createTime.toIso8601String(),
    };
  }
} 