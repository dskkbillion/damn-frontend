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
      price: SellerManagedProductDto._parsePrice(json['price']),
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
  
  /// 答案/默认值
  final String? answer;
  
  /// 问题类型
  final String? type;
  
  /// 构造函数
  ProductMaterialDto({
    this.id,
    this.question,
    this.answer,
    this.type,
  });
  
  /// 从JSON构造
  factory ProductMaterialDto.fromJson(Map<String, dynamic> json) {
    return ProductMaterialDto(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      type: json['type'],
    );
  }
  
  /// 转换为领域实体
  ProductMaterial toEntity() {
    return ProductMaterial(
      id: id ?? 0,
      question: question ?? '',
      answer: answer ?? '',
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
  
  /// 审核状态
  final String? statusAudit;
  
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
  
  /// 成功案例图片
  final String? winImages;

  /// 构造函数
  SellerManagedProductDto({
    this.id,
    this.name,
    this.price,
    this.images,
    this.description,
    this.state,
    this.productType,
    this.statusAudit,
    this.createTime,
    this.updateTime,
    this.sales,
    this.category,
    this.variants,
    this.productMaterials,
    this.winImages,
  });

  /// 安全解析价格字段
  static double? _parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }
  
  /// 处理成功案例图片
  static String? _processWinImages(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.where((img) => img != null && img.toString().isNotEmpty)
          .map((img) => img.toString())
          .join(',');
    }
    if (value is String) return value;
    return null;
  }

  /// 从JSON构造
  factory SellerManagedProductDto.fromJson(Map<String, dynamic> json) {
    // 处理images字段 - API返回数组，但DTO需要字符串
    String? imagesString;
    
    // 优先使用mainImage字段（如果存在）
    if (json['mainImage'] != null && json['mainImage'] is String && json['mainImage'].toString().trim().isNotEmpty) {
      imagesString = json['mainImage'].toString().trim();
      if (json['productType'] == 'draft' || json['state'] == 'draft') {
        print('[SellerManagedProductDto] Draft product ${json['id']} using mainImage: "$imagesString"');
      }
    }
    // 如果没有mainImage，再使用images字段
    else if (json['images'] != null) {
      if (json['images'] is List) {
        // 将数组转换为逗号分隔的字符串
        final imageList = json['images'] as List;
        // 过滤并处理每个图片URL
        final processedImages = imageList
            .where((img) => img != null)
            .map((img) => img.toString().trim())
            .where((img) => img.isNotEmpty && img != 'null')
            .toList();
        
        if (processedImages.isNotEmpty) {
          imagesString = processedImages.join(',');
        }
        
        if (json['productType'] == 'draft' || json['state'] == 'draft') {
          print('[SellerManagedProductDto] Draft product ${json['id']} images: $imageList -> "$imagesString"');
        }
      } else if (json['images'] is String) {
        final imgStr = json['images'].toString().trim();
        if (imgStr.isNotEmpty && imgStr != 'null') {
          imagesString = imgStr;
        }
        if (json['productType'] == 'draft' || json['state'] == 'draft') {
          print('[SellerManagedProductDto] Draft product ${json['id']} images string: "$imagesString"');
        }
      }
    }
    
    // 调试日志
    if ((json['productType'] == 'draft' || json['state'] == 'draft') && imagesString == null) {
      print('[SellerManagedProductDto] Draft product ${json['id']} has no valid images');
    }
    
    return SellerManagedProductDto(
      id: json['id'],
      name: json['name'],
      price: _parsePrice(json['sellingPrice'] ?? json['price']),
      images: imagesString,
      description: json['description'],
      state: json['state'],
      productType: json['productType'],
      statusAudit: json['statusAudit'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
      sales: json['sales'],
      category: json['category'] != null 
          ? Map<String, dynamic>.from(json['category']) 
          : null,
      variants: json['variants'] as List<dynamic>?,
      productMaterials: json['productMaterials'] as List<dynamic>?,
      winImages: _processWinImages(json['winImages']),
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
      productVariants = variants!.map((v) {
        final variantMap = v as Map<String, dynamic>;
        
        // 直接从API数据映射到ProductOptionValue
        return ProductOptionValue(
          id: variantMap['id'] ?? 0,
          name: variantMap['name'] ?? '',
          optionName: variantMap['name'] ?? '', // 兼容性
          optionValue: variantMap['name'] ?? '', // 兼容性
          price: _parsePrice(variantMap['sellingPrice']) ?? 0.0,
          sellingPrice: _parsePrice(variantMap['sellingPrice']) ?? 0.0,
          stock: 999, // API没有库存字段，使用默认值
          deliveryDay: variantMap['deliveryDay'],  // Keep null if not provided
          editNum: variantMap['editNum'],  // Keep null if not provided
          feature: (variantMap['feature'] as List?)?.map((f) => {
            'key': f['key'] ?? '',
            'val': f['value'] ?? f['val'] ?? '',
          }).toList().cast<Map<String, String>>() ?? [],
        );
      }).toList();
    }

    // 解析材料问题
    List<ProductMaterial>? materials;
    if (productMaterials != null && productMaterials!.isNotEmpty) {
      print('[SellerManagedProductDto] Converting ${productMaterials!.length} productMaterials to entities');
      materials = productMaterials!
          .map((m) {
            final material = ProductMaterialDto.fromJson(m as Map<String, dynamic>).toEntity();
            print('[SellerManagedProductDto] Material: type=${material.type}, question="${material.question}", answer="${material.answer}"');
            return material;
          })
          .toList();
    }

    // 根据productType、state和statusAudit确定商品状态
    ProductStatus productStatus;
    if (productType != null && productType!.toLowerCase() == 'draft') {
      // 如果productType为draft，则强制设为草稿状态
      productStatus = ProductStatus.draft;
    } else if (statusAudit == 'WAIT' || statusAudit == 'REVIEWING') {
      // 如果审核状态为等待审核，则设为审核中状态
      productStatus = ProductStatus.reviewing;
    } else if (statusAudit == 'FAIL' || statusAudit == 'REJECTED') {
      // 如果审核失败，则设为审核拒绝状态
      productStatus = ProductStatus.rejected;
    } else {
      // 否则使用state字段
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
      winImages: winImages,
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
    if (statusAudit != null) data['statusAudit'] = statusAudit;
    if (createTime != null) data['createTime'] = createTime;
    if (updateTime != null) data['updateTime'] = updateTime;
    if (sales != null) data['sales'] = sales;
    if (category != null) data['category'] = category;
    if (variants != null) data['variants'] = variants;
    if (productMaterials != null) data['productMaterials'] = productMaterials;
    
    return data;
  }
} 