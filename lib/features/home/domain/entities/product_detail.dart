import 'package:equatable/equatable.dart';

/// 商品详情实体类
class ProductDetail extends Equatable {
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
  final List<ProductVariant>? variants;
  final List<ProductMaterial>? materials;
  final int sales;
  final int views;
  final String status;
  final String selectionMode;
  final DateTime createTime;
  final DateTime updateTime;
  final int evaluateNum;
  final String score;

  const ProductDetail({
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
}

/// 商品变体实体类
class ProductVariant extends Equatable {
  final int id;
  final String name;
  final double sellingPrice;
  final int deliveryDay;
  final int editNum;
  final List<Map<String, dynamic>>? features;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.sellingPrice,
    required this.deliveryDay,
    required this.editNum,
    this.features,
  });

  @override
  List<Object?> get props => [id, name, sellingPrice, deliveryDay, editNum, features];
}

/// 商品材料问题实体类
class ProductMaterial extends Equatable {
  final int id;
  final String question;
  final String? answer;
  final String type;

  const ProductMaterial({
    required this.id,
    required this.question,
    this.answer,
    required this.type,
  });

  @override
  List<Object?> get props => [id, question, answer, type];
} 