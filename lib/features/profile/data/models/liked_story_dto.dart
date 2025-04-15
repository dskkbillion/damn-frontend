import '../../domain/entities/liked_story.dart';

/// 点赞笔记数据传输对象
class LikedStoryDto {
  final String storyId;
  final String title;
  final String? previewContent;
  final String? imageUrl;
  final String? authorName;
  final String? likedAtString;

  const LikedStoryDto({
    required this.storyId,
    required this.title,
    this.previewContent,
    this.imageUrl,
    this.authorName,
    this.likedAtString,
  });

  /// 从 JSON 映射创建 LikedStoryDto 实例
  factory LikedStoryDto.fromJson(Map<String, dynamic> json) {
    return LikedStoryDto(
      storyId: json['storyId'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      previewContent: json['previewContent'] ?? json['preview'] ?? json['content'],
      imageUrl: json['imageUrl'] ?? json['image'] ?? json['img_url'],
      authorName: json['authorName'] ?? json['author'] ?? json['author_name'],
      likedAtString: json['likedAt'] ?? json['liked_at'],
    );
  }

  /// 转换为 LikedStory 实体
  LikedStory toEntity() {
    DateTime? likedAt;
    if (likedAtString != null) {
      try {
        likedAt = DateTime.parse(likedAtString!);
      } catch (_) {}
    }

    return LikedStory(
      storyId: storyId,
      title: title,
      previewContent: previewContent,
      imageUrl: imageUrl,
      authorName: authorName,
      likedAt: likedAt,
    );
  }

  /// 将 LikedStoryDto 转换为 JSON 映射
  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
      'title': title,
      if (previewContent != null) 'previewContent': previewContent,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (authorName != null) 'authorName': authorName,
      if (likedAtString != null) 'likedAt': likedAtString,
    };
  }
}
