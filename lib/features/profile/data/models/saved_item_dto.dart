import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_item.dart';

/// 已收藏项目的数据传输对象
class SavedItemDto extends Equatable {
  /// 收藏ID
  final String id;

  /// 内容ID
  final String contentId;

  /// 内容类型
  final String contentType;

  /// 标题
  final String title;

  /// 封面图片URL
  final String? coverUrl;

  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  const SavedItemDto({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.title,
    this.coverUrl,
    required this.createdAt,
  });

  /// 从JSON映射创建SavedItemDto实例
  factory SavedItemDto.fromJson(Map<String, dynamic> json) {
    return SavedItemDto(
      id: json['id'] ?? '',
      contentId: json['contentId'] ?? '',
      contentType: json['contentType'] ?? '',
      title: json['title'] ?? '',
      coverUrl: json['coverUrl'],
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.now()),
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'contentType': contentType,
      'title': title,
      'coverUrl': coverUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, contentId, contentType, title, coverUrl, createdAt];
}
