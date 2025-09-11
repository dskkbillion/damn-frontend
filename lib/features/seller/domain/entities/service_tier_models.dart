/// 服务档位相关的数据模型
/// 从product_edit_page.dart中提取出来以减少代码复杂度

import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';

/// 服务档位枚举
enum ServiceTier {
  basic('Lite', 'Lite'),      // 轻量咨询
  standard('Pro', 'Pro'),      // 专业咨询
  premium('Deep', 'Deep');     // 深度咨询
  
  const ServiceTier(this.apiName, this.displayName);
  final String apiName;
  final String displayName;
}

/// 服务特性
class ServiceFeature {
  final String id;
  String key;   // 特性名称，如"学校数量"
  String value; // 特性值，如"3"
  String type;  // 特性类型，如"input"
  
  ServiceFeature({
    String? id,
    required this.key,
    required this.value,
    this.type = 'input',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  // 从JSON创建
  factory ServiceFeature.fromJson(Map<String, dynamic> json) {
    return ServiceFeature(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      key: json['key'] ?? '',
      value: json['val'] ?? json['value'] ?? '',
      type: json['type'] ?? 'input',
    );
  }
  
  // 转换为JSON
  Map<String, String> toJson() {
    return {
      'key': key,
      'val': value,
      'type': type,
    };
  }
}

/// 商品属性类型枚举
enum ProductAttributeType {
  input('input', '文本输入'),
  boolean('boolean', '是/否');
  
  const ProductAttributeType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 商品属性模板（定义属性结构，不包含值）
class ProductAttributeTemplate {
  final String id;
  String name;                    // 用户自定义的属性名称
  ProductAttributeType type;      // 属性类型
  List<String> options;           // 选择类型的选项列表（用户自定义）
  bool isRequired;                // 是否必填
  String placeholder;             // 占位符文本
  
  ProductAttributeTemplate({
    String? id,
    required this.name,
    this.type = ProductAttributeType.input,
    this.options = const [],
    this.isRequired = false,
    this.placeholder = '',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  // 从JSON创建
  factory ProductAttributeTemplate.fromJson(Map<String, dynamic> json) {
    return ProductAttributeTemplate(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['key'] ?? json['name'] ?? '',
      type: ProductAttributeType.values.firstWhere(
        (e) => e.value == (json['type'] ?? 'input'),
        orElse: () => ProductAttributeType.input,
      ),
      options: List<String>.from(json['options'] ?? []),
      isRequired: json['isRequired'] ?? false,
      placeholder: json['placeholder'] ?? '',
    );
  }
  
  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'options': options,
      'isRequired': isRequired,
      'placeholder': placeholder,
    };
  }
  
  // 复制模板（用于编辑）
  ProductAttributeTemplate copyWith({
    String? name,
    ProductAttributeType? type,
    List<String>? options,
    bool? isRequired,
    String? placeholder,
  }) {
    return ProductAttributeTemplate(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      options: options ?? List<String>.from(this.options),
      isRequired: isRequired ?? this.isRequired,
      placeholder: placeholder ?? this.placeholder,
    );
  }
}

/// 商品自定义属性
class ProductAttribute {
  final String id;
  String name;                    // 用户自定义的属性名称
  String value;                   // 属性值
  ProductAttributeType type;      // 属性类型
  List<String> options;           // 选择类型的选项列表（用户自定义）
  bool isRequired;                // 是否必填
  String placeholder;             // 占位符文本
  
  ProductAttribute({
    String? id,
    required this.name,
    this.value = '',
    this.type = ProductAttributeType.input,
    this.options = const [],
    this.isRequired = false,
    this.placeholder = '',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  
  // 从JSON创建
  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['key'] ?? json['name'] ?? '',
      value: json['val'] ?? json['value'] ?? '',
      type: ProductAttributeType.values.firstWhere(
        (e) => e.value == (json['type'] ?? 'input'),
        orElse: () => ProductAttributeType.input,
      ),
      options: List<String>.from(json['options'] ?? []),
      isRequired: json['isRequired'] ?? false,
      placeholder: json['placeholder'] ?? '',
    );
  }
  
  // 转换为JSON（兼容后端格式）
  Map<String, dynamic> toJson() {
    return {
      'key': name,
      'val': value,
      'type': type.value,
      'options': options,
      'isRequired': isRequired,
      'placeholder': placeholder,
    };
  }
  
  // 转换为后端兼容的JSON格式（仅包含key, val, type）
  Map<String, String> toBackendJson() {
    return {
      'key': name,
      'val': value,
      'type': type.value,
    };
  }
  
  // 复制属性（用于编辑）
  ProductAttribute copyWith({
    String? name,
    String? value,
    ProductAttributeType? type,
    List<String>? options,
    bool? isRequired,
    String? placeholder,
  }) {
    return ProductAttribute(
      id: id,
      name: name ?? this.name,
      value: value ?? this.value,
      type: type ?? this.type,
      options: options ?? List<String>.from(this.options),
      isRequired: isRequired ?? this.isRequired,
      placeholder: placeholder ?? this.placeholder,
    );
  }
}

/// 服务档位配置
class ServiceTierConfig {
  final ServiceTier tier;
  double price;
  int deliveryDay;
  int editNum;
  
  // 档位特定的属性值（key: 属性模板ID, value: 属性值）
  final Map<String, String> attributeValues;
  
  // 控制器
  late final TextEditingController priceController;
  late final TextEditingController deliveryController;
  late final TextEditingController editNumController;
  
  ServiceTierConfig({
    required this.tier,
    this.price = 0,
    this.deliveryDay = 1,  // 轻咨询模式：默认1天（即时服务）
    this.editNum = 1,      // 轻咨询模式：默认1次（一次性服务）
    Map<String, String>? attributeValues,
  }) : attributeValues = attributeValues ?? {} {
    priceController = TextEditingController(text: price > 0 ? price.toString() : '');
    // 不设置默认值的文本，让用户看到空白输入框
    deliveryController = TextEditingController(text: deliveryDay > 1 ? deliveryDay.toString() : '');
    editNumController = TextEditingController(text: editNum > 1 ? editNum.toString() : '');
  }

  // 从ProductOptionValue创建ServiceTierConfig
  factory ServiceTierConfig.fromProductOptionValue(ProductOptionValue value) {
    ServiceTier tier;
    switch (value.name) {
      case 'Basic Tier':
        tier = ServiceTier.basic;
        break;
      case 'Standard Tier':
        tier = ServiceTier.standard;
        break;
      case 'Premium Tier':
        tier = ServiceTier.premium;
        break;
      default:
        tier = ServiceTier.basic;
    }
    
    // 从feature中提取属性值
    Map<String, String> attributeValues = {};
    for (var feature in value.feature) {
      String? key = feature['key'];
      String? val = feature['val'];
      if (key != null && val != null) {
        attributeValues[key] = val;
      }
    }
    
    return ServiceTierConfig(
      tier: tier,
      price: value.sellingPrice > 0 ? value.sellingPrice : value.price,
      deliveryDay: value.deliveryDay ?? 1,  // 如果为null，使用默认值1
      editNum: value.editNum ?? 1,  // 如果为null，使用默认值1
      attributeValues: attributeValues,
    );
  }

  // 转换为ProductOptionValue（需要传入属性模板）
  ProductOptionValue toProductOptionValue(List<ProductAttributeTemplate> attributeTemplates) {
    // 将模板和当前档位的值组合成feature列表
    List<Map<String, String>> features = [];
    for (var template in attributeTemplates) {
      features.add({
        'key': template.name,
        'val': attributeValues[template.id] ?? '', // 使用档位特定的值
        'type': template.type.value,
      });
    }
    
    return ProductOptionValue(
      id: 0, // 新建规格ID为0，后端会分配真实ID
      name: tier.apiName,
      optionName: tier.apiName,
      sellingPrice: price,
      deliveryDay: deliveryDay > 1 ? deliveryDay : null,  // 只有大于1时才传值
      editNum: editNum > 1 ? editNum : null,  // 只有大于1时才传值
      feature: features,
    );
  }
  
  // 更新属性值
  void updateAttributeValue(String templateId, String value) {
    attributeValues[templateId] = value;
  }
  
  // 获取属性值
  String getAttributeValue(String templateId) {
    return attributeValues[templateId] ?? '';
  }
  
  // 更新价格（不修改controller文本，避免输入中断）
  void updatePrice(double newPrice) {
    price = newPrice;
  }
  
  // 设置价格并更新controller文本（仅用于初始化或外部设置）
  void setPriceWithController(double newPrice) {
    price = newPrice;
    priceController.text = newPrice > 0 ? newPrice.toString() : '';
  }
  
  // 更新交付天数
  void updateDeliveryDay(int newDay) {
    deliveryDay = newDay;
    deliveryController.text = newDay.toString();
  }
  
  // 更新修改次数
  void updateEditNum(int newNum) {
    editNum = newNum;
    editNumController.text = newNum.toString();
  }
  
  // 销毁控制器
  void dispose() {
    priceController.dispose();
    deliveryController.dispose();
    editNumController.dispose();
  }
}

/// 产品服务档位管理
class ProductServiceTiers {
  final ServiceTierConfig basic;
  final ServiceTierConfig standard;
  final ServiceTierConfig premium;
  
  /// 商品属性模板（所有档位共享的属性结构）
  final List<ProductAttributeTemplate> attributeTemplates;
  
  /// 临时向后兼容：提供productAttributes访问器
  /// TODO: 完成迁移后删除此属性
  List<ProductAttribute> get productAttributes {
    // 将模板转换为ProductAttribute，使用当前选中档位的值
    // 注意：这需要访问_selectedTier，但这是在ProductServiceTiers类内部，
    // 我们需要通过参数传递或其他方式获取当前选中的档位
    return attributeTemplates.map((template) {
      return ProductAttribute(
        id: template.id,
        name: template.name,
        value: '', // 使用空值，具体的值管理将通过新的方法处理
        type: template.type,
        options: template.options,
        isRequired: template.isRequired,
        placeholder: template.placeholder,
      );
    }).toList();
  }
  
  ProductServiceTiers({
    ServiceTierConfig? basic,
    ServiceTierConfig? standard,
    ServiceTierConfig? premium,
    List<ProductAttributeTemplate>? attributeTemplates,
  }) : basic = basic ?? ServiceTierConfig(tier: ServiceTier.basic),
       standard = standard ?? ServiceTierConfig(tier: ServiceTier.standard),
       premium = premium ?? ServiceTierConfig(tier: ServiceTier.premium),
       attributeTemplates = attributeTemplates ?? [];
  
  // 从ProductOptionValue列表创建
  factory ProductServiceTiers.fromProductOptionValues(List<ProductOptionValue> variants) {
    ServiceTierConfig? basic;
    ServiceTierConfig? standard;
    ServiceTierConfig? premium;
    List<ProductAttributeTemplate> attributeTemplates = [];
    
    for (var variant in variants) {
      switch (variant.name) {
        case 'Basic Tier':
          basic = ServiceTierConfig.fromProductOptionValue(variant);
          // 使用第一个档位的特性创建属性模板（只创建一次）
          if (attributeTemplates.isEmpty && variant.feature.isNotEmpty) {
            attributeTemplates = variant.feature.map((f) {
              return ProductAttributeTemplate(
                name: f['key'] ?? '',
                type: ProductAttributeType.values.firstWhere(
                  (e) => e.value == (f['type'] ?? 'input'),
                  orElse: () => ProductAttributeType.input,
                ),
              );
            }).toList();
          }
          break;
        case 'Standard Tier':
          standard = ServiceTierConfig.fromProductOptionValue(variant);
          break;
        case 'Premium Tier':
          premium = ServiceTierConfig.fromProductOptionValue(variant);
          break;
      }
    }
    
    return ProductServiceTiers(
      basic: basic,
      standard: standard,
      premium: premium,
      attributeTemplates: attributeTemplates,
    );
  }
  
  // 获取指定档位的配置
  ServiceTierConfig getTierConfig(ServiceTier tier) {
    switch (tier) {
      case ServiceTier.basic:
        return basic;
      case ServiceTier.standard:
        return standard;
      case ServiceTier.premium:
        return premium;
    }
  }
  
  // 转换为ProductOptionValue列表
  List<ProductOptionValue> toProductOptionValues() {
    return [
      basic.toProductOptionValue(attributeTemplates),
      standard.toProductOptionValue(attributeTemplates),
      premium.toProductOptionValue(attributeTemplates),
    ];
  }
  
  // 添加属性模板
  void addAttributeTemplate(ProductAttributeTemplate template) {
    attributeTemplates.add(template);
    // 为所有档位初始化空值
    basic.attributeValues[template.id] = '';
    standard.attributeValues[template.id] = '';
    premium.attributeValues[template.id] = '';
  }
  
  // 删除属性模板
  void removeAttributeTemplate(String templateId) {
    attributeTemplates.removeWhere((template) => template.id == templateId);
    // 从所有档位中删除对应的值
    basic.attributeValues.remove(templateId);
    standard.attributeValues.remove(templateId);
    premium.attributeValues.remove(templateId);
  }
  
  // 更新属性模板
  void updateAttributeTemplate(String templateId, ProductAttributeTemplate newTemplate) {
    final index = attributeTemplates.indexWhere((template) => template.id == templateId);
    if (index != -1) {
      attributeTemplates[index] = newTemplate;
      // 如果类型改变，清空所有档位的值
      if (attributeTemplates[index].type != newTemplate.type) {
        basic.attributeValues[templateId] = '';
        standard.attributeValues[templateId] = '';
        premium.attributeValues[templateId] = '';
      }
    }
  }
  
  // 获取指定档位的属性值列表（用于UI显示）
  List<ProductAttribute> getAttributesForTier(ServiceTier tier) {
    final tierConfig = getTierConfig(tier);
    return attributeTemplates.map((template) {
      return ProductAttribute(
        id: template.id,
        name: template.name,
        value: tierConfig.getAttributeValue(template.id),
        type: template.type,
        options: template.options,
        isRequired: template.isRequired,
        placeholder: template.placeholder,
      );
    }).toList();
  }
  
  // 销毁所有控制器
  void dispose() {
    basic.dispose();
    standard.dispose();
    premium.dispose();
  }
} 