import 'package:equatable/equatable.dart';

/// 用户点赞的笔记/内容
class LikedStory extends Equatable {
  /// 笔记/内容唯一标识
  final String storyId;

  /// 笔记/内容标题
  final String title;

  /// 笔记/内容预览
  final String? previewContent;

  /// 笔记/内容图片 URL
  final String? imageUrl;

  /// 作者名称
  final String? authorName;

  /// 点赞时间
  final DateTime? likedAt;

  /// 创建 LikedStory 实例
  const LikedStory({
    required this.storyId,
    required this.title,
    this.previewContent,
    this.imageUrl,
    this.authorName,
    this.likedAt,
  });

  @override
  List<Object?> get props => [
    storyId,
    title,
    previewContent,
    imageUrl,
    authorName,
    likedAt,
  ];
}
