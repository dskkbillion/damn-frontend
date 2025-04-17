import '../../domain/entities/home_feed_item.dart';

/// HomeFeedItem 模型，用于序列化和反序列化 API 响应
class HomeFeedItemModel extends HomeFeedItem {
  const HomeFeedItemModel({
    required String id,
    required String type,
    required String name,
    required List<String> images,
    required double sellingPrice,
    required double score,
    required int evaluateNum,
  }) : super(
          id: id,
          type: type,
          name: name,
          images: images,
          sellingPrice: sellingPrice,
          score: score,
          evaluateNum: evaluateNum,
        );

  /// 从 JSON 创建 HomeFeedItemModel 实例
  factory HomeFeedItemModel.fromJson(Map<String, dynamic> json) {
    // 处理图片列表，确保它是一个字符串列表
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        imagesList = (json['images'] as List).map((e) => e.toString()).toList();
      } else if (json['images'] is String) {
        imagesList = [json['images'] as String];
      }
    }

    return HomeFeedItemModel(
      id: json['id'].toString(),
      type: json['type'] ?? 'product',
      name: json['name'] ?? json['service_title'] ?? '',
      images: imagesList,
      sellingPrice: (json['sellingPrice'] ?? json['price'] ?? 0).toDouble(),
      score: (json['score'] ?? json['rating'] ?? 5.0).toDouble(),
      evaluateNum: (json['evaluateNum'] ?? json['rating_num'] ?? 0) as int,
    );
  }

  /// 将 HomeFeedItemModel 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'images': images,
      'sellingPrice': sellingPrice,
      'score': score,
      'evaluateNum': evaluateNum,
    };
  }

  /// 创建一个新的 HomeFeedItemModel 实例，并替换指定的属性
  HomeFeedItemModel copyWith({
    String? id,
    String? type,
    String? name,
    List<String>? images,
    double? sellingPrice,
    double? score,
    int? evaluateNum,
  }) {
    return HomeFeedItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      images: images ?? this.images,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      score: score ?? this.score,
      evaluateNum: evaluateNum ?? this.evaluateNum,
    );
  }
}