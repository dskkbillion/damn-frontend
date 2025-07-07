import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';

/// 商品分类DTO
class ProductCategoryDto {
  /// 分类ID
  final int? id;
  
  /// 分类名称
  final String? name;
  
  /// 构造函数
  ProductCategoryDto({
    this.id,
    this.name,
  });
  
  /// 从JSON构造
  factory ProductCategoryDto.fromJson(Map<String, dynamic> json) {
    return ProductCategoryDto(
      id: json['id'],
      name: json['name'],
    );
  }
  
  /// 转换为领域实体
  ProductCategory toEntity() {
    return ProductCategory(
      id: id ?? 0,
      name: name ?? '',
    );
  }
}

/// 商品规格选项值DTO
class ProductOptionValueDto {
  /// 选项ID
  final int? id;
  
  /// 选项名称
  final String? optionName;
  
  /// 选项值
  final String? optionValue;
  
  /// 额外价格
  final double? price;
  
  /// 库存
  final int? stock;
  
  /// 构造函数
  ProductOptionValueDto({
    this.id,
    this.optionName,
    this.optionValue,
    this.price,
    this.stock,
  });
  
  /// 从JSON构造
  factory ProductOptionValueDto.fromJson(Map<String, dynamic> json) {
    return ProductOptionValueDto(
      id: json['id'],
      optionName: json['optionName'],
      optionValue: json['optionValue'],
      price: json['price'] != null 
          ? double.tryParse(json['price'].toString()) 
          : null,
      stock: json['stock'],
    );
  }
  
  /// 转换为领域实体
  ProductOptionValue toEntity() {
    return ProductOptionValue(
      id: id ?? 0,
      optionName: optionName ?? '',
      optionValue: optionValue ?? '',
      price: price ?? 0.0,
      stock: stock ?? 0,
    );
  }
}

/// 商品材料问题DTO
class ProductMaterialDto {
  /// 问题ID
  final int? id;
  
  /// 问题内容
  final String? question;
  
  /// 问题类型
  final String? type;
  
  /// 构造函数
  ProductMaterialDto({
    this.id,
    this.question,
    this.type,
  });
  
  /// 从JSON构造
  factory ProductMaterialDto.fromJson(Map<String, dynamic> json) {
    return ProductMaterialDto(
      id: json['id'],
      question: json['question'],
      type: json['type'],
    );
  }
  
  /// 转换为领域实体
  ProductMaterial toEntity() {
    return ProductMaterial(
      id: id ?? 0,
      question: question ?? '',
      type: type ?? 'TEXT',
    );
  }
}

/// 卖家管理商品DTO模型
class SellerManagedProductDto {
  /// 商品ID
  final int? id;
  
  /// 商品名称
  final String? name;
  
  /// 价格
  final double? price;
  
  /// 商品图片(逗号分隔的URL)
  final String? images;
  
  /// 商品描述
  final String? description;
  
  /// 商品状态
  final String? state;
  
  /// 商品类型 (用于区分草稿和正式商品)
  final String? productType;
  
  /// 创建时间
  final String? createTime;
  
  /// 更新时间
  final String? updateTime;
  
  /// 销量
  final int? sales;
  
  /// 分类
  final Map<String, dynamic>? category;
  
  /// 规格选项
  final List<dynamic>? variants;
  
  /// 定制材料问题
  final List<dynamic>? productMaterials;

  /// 构造函数
  SellerManagedProductDto({
    this.id,
    this.name,
    this.price,
    this.images,
    this.description,
    this.state,
    this.productType,
    this.createTime,
    this.updateTime,
    this.sales,
    this.category,
    this.variants,
    this.productMaterials,
  });

  /// 从JSON构造
  factory SellerManagedProductDto.fromJson(Map<String, dynamic> json) {
    return SellerManagedProductDto(
      id: json['id'],
      name: json['name'],
      price: json['price'] != null 
          ? double.tryParse(json['price'].toString()) 
          : null,
      images: json['images'],
      description: json['description'],
      state: json['state'],
      productType: json['productType'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
      sales: json['sales'],
      category: json['category'] != null 
          ? Map<String, dynamic>.from(json['category']) 
          : null,
      variants: json['variants'] as List<dynamic>?,
      productMaterials: json['productMaterials'] as List<dynamic>?,
    );
  }

  /// 转换为领域实体
  SellerManagedProduct toEntity() {
    // 解析创建时间
    DateTime? parsedCreateTime;
    if (createTime != null) {
      try {
        parsedCreateTime = DateTime.parse(createTime!);
      } catch (e) {
        parsedCreateTime = null;
      }
    }

    // 解析更新时间
    DateTime? parsedUpdateTime;
    if (updateTime != null) {
      try {
        parsedUpdateTime = DateTime.parse(updateTime!);
      } catch (e) {
        parsedUpdateTime = null;
      }
    }

    // 解析分类
    ProductCategory? productCategory;
    if (category != null) {
      productCategory = ProductCategoryDto.fromJson(category!).toEntity();
    }

    // 解析规格选项
    List<ProductOptionValue>? productVariants;
    if (variants != null && variants!.isNotEmpty) {
      productVariants = variants!
          .map((v) => ProductOptionValueDto.fromJson(v as Map<String, dynamic>).toEntity())
          .toList();
    }

    // 解析材料问题
    List<ProductMaterial>? materials;
    if (productMaterials != null && productMaterials!.isNotEmpty) {
      materials = productMaterials!
          .map((m) => ProductMaterialDto.fromJson(m as Map<String, dynamic>).toEntity())
          .toList();
    }

    // 根据productType和state确定商品状态
    ProductStatus productStatus;
    if (productType != null && productType!.toLowerCase() == 'draft') {
      // 如果productType为draft，则强制设为草稿状态
      print('SellerManagedProductDto: 检测到productType="$productType"，强制设为草稿状态');
      productStatus = ProductStatus.draft;
    } else {
      // 否则使用state字段
      print('SellerManagedProductDto: 使用state="$state"字段解析状态');
      productStatus = ProductStatus.fromValue(state ?? 'UNKNOWN');
    }

    return SellerManagedProduct(
      id: id ?? 0,
      name: name ?? '',
      price: price ?? 0.0,
      images: images ?? '',
      description: description ?? '',
      status: productStatus,
      createTime: parsedCreateTime,
      updateTime: parsedUpdateTime,
      sales: sales,
      category: productCategory,
      variants: productVariants,
      productMaterials: materials,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;
    if (price != null) data['price'] = price;
    if (images != null) data['images'] = images;
    if (description != null) data['description'] = description;
    if (state != null) data['state'] = state;
    if (productType != null) data['productType'] = productType;
    if (createTime != null) data['createTime'] = createTime;
    if (updateTime != null) data['updateTime'] = updateTime;
    if (sales != null) data['sales'] = sales;
    if (category != null) data['category'] = category;
    if (variants != null) data['variants'] = variants;
    if (productMaterials != null) data['productMaterials'] = productMaterials;
    
    return data;
  }
} 