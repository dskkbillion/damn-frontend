import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import '../../domain/entities/banner.dart';

/// Banner 模型，用于序列化和反序列化 API 响应
class BannerModel extends Banner {
  const BannerModel({
    required String id,
    required String imageUrl,
    required String targetType,
    required String targetValue,
    required String createTime,
    required String updateTime,
  }) : super(
          id: id,
          imageUrl: imageUrl,
          targetType: targetType,
          targetValue: targetValue,
          createTime: createTime,
          updateTime: updateTime,
        );

  /// 从 JSON 创建 BannerModel 实例
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    AppLogger.d('解析Banner JSON: $json');
    
    // 获取图片URL，可能是image、advImg、mainImage或images字段
    String imageUrl = '';
    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imageUrl = _getFullImageUrl(json['image'].toString());
    } else if (json['advImg'] != null && json['advImg'].toString().isNotEmpty) {
      imageUrl = _getFullImageUrl(json['advImg'].toString());
    } else if (json['mainImage'] != null && json['mainImage'].toString().isNotEmpty) {
      imageUrl = _getFullImageUrl(json['mainImage'].toString());
    } else if (json['images'] != null) {
      if (json['images'] is List && (json['images'] as List).isNotEmpty) {
        imageUrl = _getFullImageUrl((json['images'] as List).first.toString());
      } else if (json['images'] is String && json['images'].toString().isNotEmpty) {
        imageUrl = _getFullImageUrl(json['images'].toString());
      }
    }
    
    AppLogger.d('解析后的图片URL: $imageUrl');
    
    return BannerModel(
      id: json['id']?.toString() ?? '0',
      imageUrl: imageUrl,
      targetType: json['linkType'] ?? json['targetType'] ?? 'none',
      targetValue: json['link'] ?? json['targetValue'] ?? '',
      createTime: json['createTime']?.toString() ?? '',
      updateTime: json['updateTime']?.toString() ?? '',
    );
  }
  
  /// 将相对图片URL转换为完整URL
  static String _getFullImageUrl(String relativeUrl) {
    AppLogger.d('处理图片URL: $relativeUrl');
    
    if (relativeUrl.isEmpty) return '';
    
    // 如果是完整URL，直接返回
    if (relativeUrl.startsWith('http')) {
      AppLogger.d('完整URL: $relativeUrl');
      return relativeUrl;
    }
    
    // 如果是相对URL，转为完整URL
    // 从环境变量获取基础URL，去掉路径部分只保留域名
    String baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      // 如果环境变量未设置，返回原始URL
      return relativeUrl;
    }
    
    // 从完整的backend URL中提取域名部分
    final uri = Uri.parse(baseUrl);
    baseUrl = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
    
    // 确保baseUrl不以斜杠结尾，relativeUrl以斜杠开头
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanRelativeUrl = relativeUrl.startsWith('/') ? relativeUrl : '/$relativeUrl';
    
    final fullUrl = '$cleanBaseUrl$cleanRelativeUrl';
    AppLogger.d('转换后的完整URL: $fullUrl');
    return fullUrl;
  }

  /// 将 BannerModel 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': imageUrl,
      'targetType': targetType,
      'targetValue': targetValue,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  /// 创建一个新的 BannerModel 实例，并替换指定的属性
  BannerModel copyWith({
    String? id,
    String? imageUrl,
    String? targetType,
    String? targetValue,
    String? createTime,
    String? updateTime,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}