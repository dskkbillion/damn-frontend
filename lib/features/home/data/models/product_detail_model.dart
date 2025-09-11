import 'dart:convert';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product_detail.dart';

/// 商品详情模型
class ProductDetailModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final double sellingPrice;
  final String mainImage;
  final List<String> images;
  final List<String>? detailImages;
  final String? detailContent;
  final List<String>? winImages;
  final int categoryId;
  final String categoryName;
  final int sellerId;
  final String sellerName;
  final String? sellerAvatar;
  final String? sellerRemarks;
  final bool? recoverFlag;
  final String? recoverContent;
  final List<ProductVariantModel>? variants;
  final List<ProductMaterialModel>? materials;
  final int sales;
  final int views;
  final String status;
  final String selectionMode;
  final DateTime createTime;
  final DateTime updateTime;
  final int evaluateNum;
  final String score;

  const ProductDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sellingPrice,
    required this.mainImage,
    required this.images,
    this.detailImages,
    this.detailContent,
    this.winImages,
    required this.categoryId,
    required this.categoryName,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatar,
    this.sellerRemarks,
    this.recoverFlag,
    this.recoverContent,
    this.variants,
    this.materials,
    required this.sales,
    required this.views,
    required this.status,
    required this.selectionMode,
    required this.createTime,
    required this.updateTime,
    required this.evaluateNum,
    required this.score,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        sellingPrice,
        mainImage,
        images,
        detailImages,
        detailContent,
        winImages,
        categoryId,
        categoryName,
        sellerId,
        sellerName,
        sellerAvatar,
        sellerRemarks,
        recoverFlag,
        recoverContent,
        variants,
        materials,
        sales,
        views,
        status,
        selectionMode,
        createTime,
        updateTime,
        evaluateNum,
        score,
      ];

  /// 处理服务器返回的复杂图片URL格式
  /// 
  /// 服务器可能返回嵌套的JSON字符串作为图片URL，例如:
  /// ["[\"https://example.com/image.jpg\"]"]
  static List<String> _parseImageUrls(dynamic imagesJson) {
    List<String> result = [];
    
    if (imagesJson == null) return result;
    
    try {
      if (imagesJson is List) {
        for (var item in imagesJson) {
          if (item is String) {
            // 处理嵌套JSON字符串情况，如 "[\"https://example.com/image.jpg\"]"
            if (item.startsWith('[') && item.endsWith(']')) {
              try {
                // 尝试解析JSON字符串
                final dynamic parsedJson = jsonDecode(item);
                if (parsedJson is List) {
                  for (var url in parsedJson) {
                    if (url is String && url.isNotEmpty) {
                      result.add(url);
                    }
                  }
                } else if (parsedJson is String && parsedJson.isNotEmpty) {
                  result.add(parsedJson);
                }
              } catch (e) {
                print('解析嵌套JSON图片URL失败: $e，使用替代方法');
                // 如果JSON解析失败，尝试简单地清理字符串
                final String cleaned = item
                    .replaceAll(r'\"', '"')  // 替换转义的引号
                    .replaceAll(r'[', '')    // 移除左方括号
                    .replaceAll(r']', '')    // 移除右方括号
                    .replaceAll('"', '');    // 移除引号
                
                if (cleaned.isNotEmpty) {
                  if (cleaned.contains(',')) {
                    // 如果清理后的字符串包含逗号，可能是多个URL
                    result.addAll(cleaned.split(',').where((url) => url.isNotEmpty));
                  } else {
                    result.add(cleaned);
                  }
                }
              }
            } else {
              // 正常的URL字符串
              result.add(item);
            }
          }
        }
      } else if (imagesJson is String) {
        // 单个字符串，可能是单个URL或JSON字符串
        if (imagesJson.startsWith('[') && imagesJson.endsWith(']')) {
          try {
            final dynamic parsedJson = jsonDecode(imagesJson);
            if (parsedJson is List) {
              for (var url in parsedJson) {
                if (url is String && url.isNotEmpty) {
                  result.add(url);
                }
              }
            }
          } catch (e) {
            print('解析JSON字符串失败: $e');
            // 失败后，尝试作为单个URL添加
            result.add(imagesJson);
          }
        } else {
          result.add(imagesJson);
        }
      }
    } catch (e) {
      print('处理图片URL时发生异常: $e');
    }
    
    print('解析后的图片URLs: $result');
    return result;
  }

  /// 从JSON创建商品详情模型
  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    // 处理图片列表 - 使用新的解析方法
    final List<String> imagesList = _parseImageUrls(json['images']);
    
    // 处理成功案例图片列表
    final List<String>? winImagesList = json['winImages'] != null 
        ? _parseImageUrls(json['winImages']) 
        : null;

    // 处理详情图片列表
    final List<String>? detailImagesList = json['detailImages'] != null 
        ? _parseImageUrls(json['detailImages']) 
        : null;

    // 处理变体列表
    List<ProductVariantModel>? variantsList;
    if (json['variants'] != null) {
      variantsList = (json['variants'] as List)
          .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 处理材料问题列表
    List<ProductMaterialModel>? materialsList;
    if (json['productMaterials'] != null) {
      materialsList = (json['productMaterials'] as List)
          .map((e) => ProductMaterialModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 处理日期
    DateTime createTime = DateTime.now();
    if (json['createTime'] != null) {
      createTime = DateTime.tryParse(json['createTime']) ?? DateTime.now();
    }

    DateTime updateTime = DateTime.now();
    if (json['updateTime'] != null) {
      updateTime = DateTime.tryParse(json['updateTime']) ?? DateTime.now();
    }

    // 处理卖家信息
    int sellerId = 0;
    String sellerName = '';
    String? sellerAvatar;
    String? sellerRemarks;
    bool? recoverFlag;
    String? recoverContent;

    if (json['tenant'] != null && json['tenant'] is Map<String, dynamic>) {
      final tenant = json['tenant'] as Map<String, dynamic>;
      sellerId = tenant['id'] ?? 0;
      sellerName = tenant['nickName'] ?? '';
      sellerAvatar = tenant['avatar'];
      sellerRemarks = tenant['remarks'];
      recoverFlag = tenant['recoverFlag'];
      recoverContent = tenant['recoverContent'];
    }

    // 如果主图不存在，则使用第一张图片作为主图
    final mainImage = imagesList.isNotEmpty ? imagesList.first : '';

    return ProductDetailModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      sellingPrice: variantsList != null && variantsList.isNotEmpty 
          ? variantsList.first.sellingPrice 
          : 0.0,
      mainImage: mainImage,
      images: imagesList,
      detailImages: detailImagesList,
      detailContent: json['detailContent'],
      winImages: winImagesList,
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      sellerId: sellerId,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      sellerRemarks: sellerRemarks,
      recoverFlag: recoverFlag,
      recoverContent: recoverContent,
      variants: variantsList,
      materials: materialsList,
      sales: json['salesNum'] ?? 0,
      views: json['views'] ?? 0,
      status: json['state'] ?? 'normal',
      selectionMode: json['selectionMode'] ?? 'customize',
      createTime: createTime,
      updateTime: updateTime,
      evaluateNum: json['evaluateNum'] ?? 0,
      score: json['score'] ?? '0',
    );
  }

  /// 转换为领域实体
  ProductDetail toEntity() {
    List<ProductVariant>? domainVariants;
    if (variants != null) {
      domainVariants = variants!.map((variant) => variant.toEntity()).toList();
    }

    List<ProductMaterial>? domainMaterials;
    if (materials != null) {
      domainMaterials = materials!.map((material) => material.toEntity()).toList();
    }

    return ProductDetail(
      id: id,
      name: name,
      description: description,
      sellingPrice: sellingPrice,
      mainImage: mainImage,
      images: images,
      detailImages: detailImages,
      detailContent: detailContent,
      categoryId: categoryId,
      categoryName: categoryName,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      variants: domainVariants,
      materials: domainMaterials,
      sales: sales,
      views: views,
      status: status,
      createTime: createTime,
      updateTime: updateTime,
      evaluateNum: evaluateNum,
      score: score,
      winImages: winImages,
      selectionMode: selectionMode,
      sellerRemarks: sellerRemarks,
      recoverFlag: recoverFlag,
      recoverContent: recoverContent,
    );
  }
}

/// 商品变体模型
class ProductVariantModel extends Equatable {
  final int id;
  final String name;
  final double sellingPrice;
  final int? deliveryDay;
  final int? editNum;
  final List<Map<String, dynamic>>? features;

  const ProductVariantModel({
    required this.id,
    required this.name,
    required this.sellingPrice,
    this.deliveryDay,
    this.editNum,
    this.features,
  });

  @override
  List<Object?> get props => [id, name, sellingPrice, deliveryDay, editNum, features];

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>>? featuresList;
    if (json['feature'] != null) {
      featuresList = (json['feature'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }

    return ProductVariantModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sellingPrice: (json['sellingPrice'] ?? 0.0).toDouble(),
      deliveryDay: json['deliveryDay'],
      editNum: json['editNum'],
      features: featuresList,
    );
  }

  /// 转换为领域实体
  ProductVariant toEntity() {
    return ProductVariant(
      id: id,
      name: name,
      sellingPrice: sellingPrice,
      deliveryDay: deliveryDay,
      editNum: editNum,
      features: features,
    );
  }
}

/// 商品材料问题模型
class ProductMaterialModel extends Equatable {
  final int id;
  final String question;
  final String? answer;
  final String type;

  const ProductMaterialModel({
    required this.id,
    required this.question,
    this.answer,
    required this.type,
  });

  @override
  List<Object?> get props => [id, question, answer, type];

  factory ProductMaterialModel.fromJson(Map<String, dynamic> json) {
    return ProductMaterialModel(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'],
      type: json['type'] ?? 'text',
    );
  }

  /// 转换为领域实体
  ProductMaterial toEntity() {
    return ProductMaterial(
      id: id,
      question: question,
      answer: answer,
      type: type,
    );
  }
} 