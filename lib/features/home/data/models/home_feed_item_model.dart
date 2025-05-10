import '../../domain/entities/home_feed_item.dart';

/// HomeFeedItem 模型，用于序列化和反序列化 API 响应
class HomeFeedItemModel extends HomeFeedItem {
  HomeFeedItemModel({
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
    print('Parsing HomeFeedItemModel from JSON: $json');
    
    // 处理图片URL
    List<String> imagesList = [];
    
    // 尝试解析images字段
    if (json['images'] != null) {
      if (json['images'] is List) {
        // 如果是列表，直接使用
        imagesList = (json['images'] as List)
            .map((img) => img != null ? _getFullImageUrl(img.toString()) : '')
            .where((url) => url.isNotEmpty)
            .toList();
      } else if (json['images'] is String) {
        // 如果是字符串，可能是逗号分隔的URL列表
        imagesList = (json['images'] as String)
            .split(',')
            .map((img) => _getFullImageUrl(img.trim()))
            .where((url) => url.isNotEmpty)
            .toList();
      }
    }
    
    // 如果没有找到图片，尝试其他可能的字段
    if (imagesList.isEmpty) {
      if (json['image'] != null && json['image'].toString().isNotEmpty) {
        imagesList.add(_getFullImageUrl(json['image'].toString()));
      } else if (json['mainImage'] != null && json['mainImage'].toString().isNotEmpty) {
        imagesList.add(_getFullImageUrl(json['mainImage'].toString()));
      }
    }
    
    // 如果仍然没有图片，使用空列表
    if (imagesList.isEmpty) {
      print('没有找到产品图片');
      imagesList = [];
    } else {
      print('产品图片列表: $imagesList');
    }

    // 尝试解析价格
    double price = 0.0;
    try {
      var priceValue = json['sellingPrice'] ?? json['price'] ?? json['originalPrice'] ?? '0';
      if (priceValue is String) {
        price = double.tryParse(priceValue) ?? 0.0;
      } else if (priceValue is num) {
        price = priceValue.toDouble();
      }
    } catch (e) {
      print('Error parsing price: $e');
      price = 0.0;
    }

    // 尝试解析评分
    double score = 5.0;
    try {
      var scoreValue = json['score'] ?? json['rating'] ?? 5.0;
      if (scoreValue is String) {
        score = double.tryParse(scoreValue) ?? 5.0;
      } else if (scoreValue is num) {
        score = scoreValue.toDouble();
      }
    } catch (e) {
      print('Error parsing score: $e');
      score = 5.0;
    }

    // 尝试解析评价数量
    int evaluateNum = 0;
    try {
      evaluateNum = int.parse((json['evaluateNum'] ?? json['rating_num'] ?? '0').toString());
    } catch (e) {
      print('Error parsing evaluateNum: $e');
      evaluateNum = 0;
    }

    return HomeFeedItemModel(
      id: json['id'].toString(),
      type: json['type'] ?? 'product',
      name: json['name'] ?? json['title'] ?? json['service_title'] ?? '',
      images: imagesList,
      sellingPrice: price,
      score: score,
      evaluateNum: evaluateNum,
    );
  }
  
  /// 将相对图片URL转换为完整URL
  static String _getFullImageUrl(String relativeUrl) {
    print('处理产品图片URL: $relativeUrl');
    
    if (relativeUrl.isEmpty) return '';
    
    // 尝试解析JSON格式的URL（如["https://example.com/image.jpg"]）
    if (relativeUrl.trim().startsWith('[') && relativeUrl.trim().endsWith(']')) {
      try {
        // 移除外层引号和其他非必要字符，提取实际URL
        final cleaned = relativeUrl
            .replaceAll(RegExp(r'^\["'), '')
            .replaceAll(RegExp(r'"\]$'), '')
            .replaceAll(r'\"', '"');
            
        // 如果清理后的URL以http开头，直接返回
        if (cleaned.startsWith('http')) {
          print('解析JSON后的完整产品图片URL: $cleaned');
          return cleaned;
        }
      } catch (e) {
        print('解析JSON图片URL失败: $e');
      }
    }
    
    // 如果是完整URL，直接返回
    if (relativeUrl.startsWith('http')) {
      print('完整产品图片URL: $relativeUrl');
      return relativeUrl;
    }
    
    // 如果是相对URL，转为完整URL
    final baseUrl = 'https://app.duoshaokankan.com/prod-api';
    
    // 确保baseUrl不以斜杠结尾，relativeUrl以斜杠开头
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanRelativeUrl = relativeUrl.startsWith('/') ? relativeUrl : '/$relativeUrl';
    
    final fullUrl = '$cleanBaseUrl$cleanRelativeUrl';
    print('转换后的完整产品图片URL: $fullUrl');
    return fullUrl;
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