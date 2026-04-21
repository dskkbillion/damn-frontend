/// 产品编辑相关的基础数据模型
/// 从product_edit_page.dart中提取出来以减少代码复杂度
library;

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

/// 成功案例上传状态枚举
enum SuccessCaseUploadStatus {
  pending, // 待上传
  uploading, // 上传中
  completed, // 已完成
  failed, // 失败
}

/// 成功案例数据模型
class SuccessCase {
  final String id;
  final String imagePath;
  final String imageUrl;
  final String title;
  final String description;
  final DateTime createTime;
  final SuccessCaseUploadStatus uploadStatus;
  final String? errorMessage;
  final double uploadProgress; // 0-100
  
  SuccessCase({
    String? id,
    required this.imagePath,
    this.imageUrl = '',
    required this.title,
    required this.description,
    DateTime? createTime,
    this.uploadStatus = SuccessCaseUploadStatus.pending,
    this.errorMessage,
    this.uploadProgress = 0,
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
      uploadStatus: _parseUploadStatus(json['uploadStatus']),
      errorMessage: json['errorMessage'],
      uploadProgress: (json['uploadProgress'] ?? 0).toDouble(),
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
      'uploadStatus': uploadStatus.name,
      'errorMessage': errorMessage,
      'uploadProgress': uploadProgress,
    };
  }
  
  // 复制方法用于更新部分字段
  SuccessCase copyWith({
    String? id,
    String? imagePath,
    String? imageUrl,
    String? title,
    String? description,
    DateTime? createTime,
    SuccessCaseUploadStatus? uploadStatus,
    String? errorMessage,
    double? uploadProgress,
  }) {
    return SuccessCase(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      createTime: createTime ?? this.createTime,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
  
  // 辅助方法：解析上传状态
  static SuccessCaseUploadStatus _parseUploadStatus(dynamic value) {
    if (value == null) return SuccessCaseUploadStatus.pending;
    if (value is String) {
      return SuccessCaseUploadStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SuccessCaseUploadStatus.pending,
      );
    }
    return SuccessCaseUploadStatus.pending;
  }
  
  // 判断是否需要上传
  bool get needsUpload => uploadStatus == SuccessCaseUploadStatus.pending && 
                          imagePath.isNotEmpty && 
                          imageUrl.isEmpty;
  
  // 判断是否可以重试
  bool get canRetry => uploadStatus == SuccessCaseUploadStatus.failed;
  
  // 判断是否正在上传
  bool get isUploading => uploadStatus == SuccessCaseUploadStatus.uploading;
  
  // 判断是否上传完成
  bool get isCompleted => uploadStatus == SuccessCaseUploadStatus.completed && imageUrl.isNotEmpty;
} 