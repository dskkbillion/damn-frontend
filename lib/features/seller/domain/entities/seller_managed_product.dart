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
  
  /// 选项名称
  final String optionName;
  
  /// 选项值
  final String optionValue;
  
  /// 价格
  final double price;
  
  /// 库存
  final int stock;

  const ProductOptionValue({
    required this.id,
    required this.optionName,
    required this.optionValue,
    required this.price,
    required this.stock,
  });

  @override
  List<Object?> get props => [id, optionName, optionValue, price, stock];
}

/// 商品材料问题
class ProductMaterial extends Equatable {
  /// 问题ID
  final int id;
  
  /// 问题内容
  final String question;
  
  /// 问题类型 (TEXT, FILE 等)
  final String type;

  const ProductMaterial({
    required this.id,
    required this.question,
    required this.type,
  });

  @override
  List<Object?> get props => [id, question, type];
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

  const ProductCreationData({
    required this.name,
    required this.images,
    required this.description,
    required this.price,
    this.categoryId,
    this.variants,
    this.productMaterials,
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
  ];
  
  /// 转换为API参数格式
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'images': images,
      'description': description,
      'price': price,
      if (categoryId != null) 'categoryId': categoryId,
      if (variants != null) 'variants': variants!.map((v) => {
        'optionName': v.optionName,
        'optionValue': v.optionValue,
        'price': v.price,
        'stock': v.stock,
      }).toList(),
      if (productMaterials != null) 'productMaterials': productMaterials!.map((m) => {
        'question': m.question,
        'type': m.type,
      }).toList(),
    };
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
  ];
  
  /// 转换为API参数格式
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
    };
    
    if (name != null) data['name'] = name;
    if (images != null) data['images'] = images;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (state != null) data['state'] = state;
    if (categoryId != null) data['categoryId'] = categoryId;
    
    if (variants != null) {
      data['variants'] = variants!.map((v) => {
        'optionName': v.optionName,
        'optionValue': v.optionValue,
        'price': v.price,
        'stock': v.stock,
      }).toList();
    }
    
    if (productMaterials != null) {
      data['productMaterials'] = productMaterials!.map((m) => {
        'question': m.question,
        'type': m.type,
      }).toList();
    }
    
    return data;
  }
} 