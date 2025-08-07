import 'package:equatable/equatable.dart';
import 'enums/product_status.dart';

/// 商品类别
class ProductCategory extends Equatable {
  /// 类别ID
  final int id;
  
  /// 类别名称
  final String name;

  const ProductCategory({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

/// 商品规格选项值
class ProductOptionValue extends Equatable {
  /// 选项值ID
  final int id;
  
  /// 名称（规格套餐名称）
  final String name;
  
  /// 原选项名称字段（兼容旧代码）
  final String optionName;
  
  /// 原选项值字段（兼容旧代码）
  final String optionValue;
  
  /// 价格
  final double price;
  
  /// 销售价格
  final double sellingPrice;
  
  /// 库存
  final int stock;
  
  /// 交付天数
  final int deliveryDay;
  
  /// 修改次数
  final int editNum;
  
  /// 特性列表 [{key: "学校数量", val: "3", type: "input"}, ...]
  final List<Map<String, String>> feature;

  const ProductOptionValue({
    required this.id,
    this.name = '',
    this.optionName = '',
    this.optionValue = '',
    this.price = 0,
    this.sellingPrice = 0,
    this.stock = 0,
    this.deliveryDay = 3,
    this.editNum = 1,
    this.feature = const [],
  });

  @override
  List<Object?> get props => [id, name, optionName, optionValue, price, sellingPrice, stock, deliveryDay, editNum, feature];
}

/// 商品材料问题
class ProductMaterial extends Equatable {
  /// 问题ID
  final int id;
  
  /// 问题内容
  final String question;
  
  /// 答案/默认值
  final String answer;
  
  /// 问题类型 (TEXT, FILE, PROBLEM, ATTACHMENT 等)
  final String type;

  const ProductMaterial({
    required this.id,
    required this.question,
    this.answer = '',
    required this.type,
  });

  @override
  List<Object?> get props => [id, question, answer, type];
}

/// 卖家管理的商品实体
class SellerManagedProduct extends Equatable {
  /// 商品ID
  final int id;
  
  /// 商品名称
  final String name;
  
  /// 价格
  final double price;
  
  /// 封面图(多图时取第一张)
  final String images;
  
  /// 商品描述
  final String description;
  
  /// 商品状态
  final ProductStatus status;
  
  /// 创建时间
  final DateTime? createTime;
  
  /// 更新时间
  final DateTime? updateTime;
  
  /// 销量
  final int? sales;
  
  /// 商品所属分类
  final ProductCategory? category;
  
  /// 商品规格选项
  final List<ProductOptionValue>? variants;
  
  /// 商品定制材料问题
  final List<ProductMaterial>? productMaterials;
  
  /// 成功案例图片
  final String? winImages;

  const SellerManagedProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.description,
    required this.status,
    this.createTime,
    this.updateTime,
    this.sales,
    this.category,
    this.variants,
    this.productMaterials,
    this.winImages,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    images,
    description,
    status,
    createTime,
    updateTime,
    sales,
    category,
    variants,
    productMaterials,
    winImages,
  ];
  
  /// 创建商品副本，可选择性更新部分字段
  SellerManagedProduct copyWith({
    int? id,
    String? name,
    double? price,
    String? images,
    String? description,
    ProductStatus? status,
    DateTime? createTime,
    DateTime? updateTime,
    int? sales,
    ProductCategory? category,
    List<ProductOptionValue>? variants,
    List<ProductMaterial>? productMaterials,
    String? winImages,
  }) {
    return SellerManagedProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      images: images ?? this.images,
      description: description ?? this.description,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      sales: sales ?? this.sales,
      category: category ?? this.category,
      variants: variants ?? this.variants,
      productMaterials: productMaterials ?? this.productMaterials,
      winImages: winImages ?? this.winImages,
    );
  }
  
  /// 检查商品是否可以编辑
  bool get isEditable => status.isEditable;
  
  /// 检查商品是否可以上架/下架切换
  bool get isSwitchable => status.isSwitchable;
  
  /// 检查商品是否可以发布
  bool get isPublishable => status.isPublishable;
  
  /// 将状态修改为上架
  SellerManagedProduct markAsEnabled() {
    return copyWith(status: ProductStatus.normal);
  }
  
  /// 将状态修改为下架
  SellerManagedProduct markAsDisabled() {
    return copyWith(status: ProductStatus.disabled);
  }
}

/// 商品筛选条件
class SellerProductFilter extends Equatable {
  /// 页码
  final int pageNum;
  
  /// 每页记录数
  final int pageSize;
  
  /// 状态筛选
  final String? state;

  const SellerProductFilter({
    required this.pageNum,
    required this.pageSize,
    this.state,
  });

  @override
  List<Object?> get props => [pageNum, pageSize, state];
}

/// 商品创建数据
class ProductCreationData extends Equatable {
  /// 商品名称
  final String name;
  
  /// 商品图片
  final String images;
  
  /// 商品描述
  final String description;
  
  /// 基础价格
  final double price;
  
  /// 分类ID
  final int? categoryId;
  
  /// 规格选项
  final List<ProductOptionValue>? variants;
  
  /// 自定义材料问题
  final List<ProductMaterial>? productMaterials;
  
  /// 展示图片（win images）
  final String? winImages;
  
  /// 详情图片
  final String? detailImages;
  
  /// 详情内容（富文本HTML）
  final String? detailContent;
  
  /// 商品类型（product: 正式商品, draft: 草稿）
  final String productType;

  const ProductCreationData({
    required this.name,
    required this.images,
    required this.description,
    required this.price,
    this.categoryId,
    this.variants,
    this.productMaterials,
    this.winImages,
    this.detailImages,
    this.detailContent,
    this.productType = 'product', // 默认为正式商品
  });

  @override
  List<Object?> get props => [
    name,
    images,
    description,
    price,
    categoryId,
    variants,
    productMaterials,
    winImages,
    detailImages,
    detailContent,
    productType,
  ];
  
  /// 转换为API参数格式
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'images': images.split(','),  // 将逗号分隔的字符串转为数组
      'productType': productType, // 添加商品类型
    };
    
    // 添加价格字段
    data['sellingPrice'] = price;
    data['originalPrice'] = price;
    
    // 添加成功案例图
    if (winImages != null && winImages!.isNotEmpty) {
      data['winImages'] = winImages!.split(',');
    }
    
    // 添加详情图
    if (detailImages != null && detailImages!.isNotEmpty) {
      data['detailImages'] = detailImages!.split(',');
    }
    
    // 添加详情HTML内容
    if (detailContent != null && detailContent!.isNotEmpty) {
      data['detailContent'] = detailContent;
    }
    
    // 如果没有详情图，使用主图作为详情图
    if ((detailImages == null || detailImages!.isEmpty) && 
        (detailContent == null || detailContent!.isEmpty)) {
      data['detailImages'] = images.split(',');
    }
    
    if (categoryId != null) {
      data['categoryId'] = categoryId;
    }
    
    // 确保variants字段始终存在，即使为空数组
    if (variants != null && variants!.isNotEmpty) {
      data['variants'] = variants!.map((v) => {
        'name': v.name.isNotEmpty ? v.name : v.optionName,
        'sellingPrice': v.sellingPrice > 0 ? v.sellingPrice : v.price,
        'deliveryDay': v.deliveryDay,
        'editNum': v.editNum,
        'feature': v.feature,
      }).toList();
    } else {
      // 提供空数组作为默认值，确保后端能正确处理
      data['variants'] = <Map<String, dynamic>>[];
    }
    
    // 确保productMaterials字段始终存在，即使为空数组
    if (productMaterials != null && productMaterials!.isNotEmpty) {
      data['productMaterials'] = productMaterials!.map((m) => {
        'question': m.question,
        'answer': m.answer,
        'type': m.type,
      }).toList();
    } else {
      // 提供空数组作为默认值，确保后端能正确处理
      data['productMaterials'] = <Map<String, dynamic>>[];
    }
    
    return data;
  }
}

/// 商品更新数据
class ProductUpdateData extends Equatable {
  /// 商品ID
  final int id;
  
  /// 商品名称
  final String? name;
  
  /// 商品图片
  final String? images;
  
  /// 商品描述
  final String? description;
  
  /// 基础价格
  final double? price;
  
  /// 状态
  final String? state;
  
  /// 分类ID
  final int? categoryId;
  
  /// 规格选项
  final List<ProductOptionValue>? variants;
  
  /// 自定义材料问题
  final List<ProductMaterial>? productMaterials;
  
  /// 详情图片
  final String? detailImages;
  
  /// 详情内容（富文本HTML）
  final String? detailContent;
  
  /// 成功案例图片（win images）
  final String? winImages;

  const ProductUpdateData({
    required this.id,
    this.name,
    this.images,
    this.description,
    this.price,
    this.state,
    this.categoryId,
    this.variants,
    this.productMaterials,
    this.detailImages,
    this.detailContent,
    this.winImages,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    images,
    description,
    price,
    state,
    categoryId,
    variants,
    productMaterials,
    detailImages,
    detailContent,
    winImages,
  ];
  
  /// 创建新实例，可选择性更新部分字段
  ProductUpdateData copyWith({
    int? id,
    String? name,
    String? images,
    String? description,
    double? price,
    String? state,
    int? categoryId,
    List<ProductOptionValue>? variants,
    List<ProductMaterial>? productMaterials,
    String? detailImages,
    String? detailContent,
    String? winImages,
  }) {
    return ProductUpdateData(
      id: id ?? this.id,
      name: name ?? this.name,
      images: images ?? this.images,
      description: description ?? this.description,
      price: price ?? this.price,
      state: state ?? this.state,
      categoryId: categoryId ?? this.categoryId,
      variants: variants ?? this.variants,
      productMaterials: productMaterials ?? this.productMaterials,
      detailImages: detailImages ?? this.detailImages,
      detailContent: detailContent ?? this.detailContent,
      winImages: winImages ?? this.winImages,
    );
  }
  
  /// 转换为API参数格式
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
    };
    
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    
    // 修复：确保价格字段正确映射
    if (price != null) {
      data['sellingPrice'] = price; // 后端期望sellingPrice字段
      data['originalPrice'] = price; // 设置原价相同
    }
    
    if (state != null) data['state'] = state;
    if (categoryId != null) data['categoryId'] = categoryId;
    
    // 修复：添加图片，转为数组格式，并设置mainImage
    if (images != null && images!.isNotEmpty) {
      final imageList = images!.split(',').where((img) => img.trim().isNotEmpty).toList();
      if (imageList.isNotEmpty) {
        data['images'] = imageList;
        data['mainImage'] = imageList.first; // 设置主图为第一张图片
      }
    } else {
      // 如果没有图片，提供空数组
      data['images'] = <String>[];
    }
    
    // 添加详情图
    if (detailImages != null && detailImages!.isNotEmpty) {
      data['detailImages'] = detailImages!.split(',').where((img) => img.trim().isNotEmpty).toList();
    }
    
    // 添加详情内容
    if (detailContent != null && detailContent!.isNotEmpty) {
      data['detailContent'] = detailContent;
    }
    
    // 添加成功案例图片
    if (winImages != null && winImages!.isNotEmpty) {
      data['winImages'] = winImages!.split(',').where((img) => img.trim().isNotEmpty).toList();
    }
    
    // 修复：确保variants格式正确
    if (variants != null) {
      data['variants'] = variants!.map((v) => {
        'name': v.name.isNotEmpty ? v.name : v.optionName,
        'sellingPrice': v.sellingPrice > 0 ? v.sellingPrice : v.price,
        'deliveryDay': v.deliveryDay,
        'editNum': v.editNum,
        'feature': v.feature,
      }).toList();
    } else {
      data['variants'] = <Map<String, dynamic>>[];
    }
    
    // 修复：确保productMaterials格式正确
    if (productMaterials != null) {
      data['productMaterials'] = productMaterials!.map((m) => {
        'question': m.question,
        'answer': m.answer,
        'type': m.type,
      }).toList();
    } else {
      data['productMaterials'] = <Map<String, dynamic>>[];
    }
    
    return data;
  }
} 