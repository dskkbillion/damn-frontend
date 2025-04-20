import 'package:equatable/equatable.dart';
import '../../domain/entities/liked_story.dart';

/// 已点赞故事的数据传输对象
class LikedStoryDto extends Equatable {
  /// 点赞ID
  final String id;

  /// 故事ID
  final String storyId;

  /// 故事标题
  final String title;

  /// 封面图片URL
  final String? coverUrl;

  /// 作者名称
  final String? authorName;

  /// 点赞时间
  final DateTime likedAt;

  /// 构造函数
  const LikedStoryDto({
    required this.id,
    required this.storyId,
    required this.title,
    this.coverUrl,
    this.authorName,
    required this.likedAt,
  });

  /// 从JSON映射创建LikedStoryDto实例
  factory LikedStoryDto.fromJson(Map<String, dynamic> json) {
    return LikedStoryDto(
      id: json['id'] ?? '',
      storyId: json['storyId'] ?? '',
      title: json['title'] ?? '',
      coverUrl: json['coverUrl'],
      authorName: json['authorName'],
      likedAt: json['likedAt'] is String
          ? DateTime.parse(json['likedAt'])
          : (json['likedAt'] is DateTime ? json['likedAt'] : DateTime.now()),
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'title': title,
      'coverUrl': coverUrl,
      'authorName': authorName,
      'likedAt': likedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, storyId, title, coverUrl, authorName, likedAt];
}
