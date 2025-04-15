import '../../domain/entities/saved_item.dart';

/// 收藏项目数据传输对象
class SavedItemDto {
  final String itemId;
  final String title;
  final String? imageUrl;
  final double? price;
  final String? sellerName;
  final String? savedAtString;

  const SavedItemDto({
    required this.itemId,
    required this.title,
    this.imageUrl,
    this.price,
    this.sellerName,
    this.savedAtString,
  });

  /// 从 JSON 映射创建 SavedItemDto 实例
  factory SavedItemDto.fromJson(Map<String, dynamic> json) {
    return SavedItemDto(
      itemId: json['itemId'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'] ?? json['img_url'],
      price: _parseDouble(json['price']),
      sellerName: json['sellerName'] ?? json['seller_name'],
      savedAtString: json['savedAt'] ?? json['saved_at'],
    );
  }

  /// 转换为 SavedItem 实体
  SavedItem toEntity() {
    DateTime? savedAt;
    if (savedAtString != null) {
      try {
        savedAt = DateTime.parse(savedAtString!);
      } catch (_) {}
    }

    return SavedItem(
      itemId: itemId,
      title: title,
      imageUrl: imageUrl,
      price: price,
      sellerName: sellerName,
      savedAt: savedAt,
    );
  }

  /// 将 SavedItemDto 转换为 JSON 映射
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'title': title,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (price != null) 'price': price,
      if (sellerName != null) 'sellerName': sellerName,
      if (savedAtString != null) 'savedAt': savedAtString,
    };
  }

  /// 解析数字类型值，处理字符串和数字类型
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
