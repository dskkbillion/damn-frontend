import '../../domain/entities/cart_validation_result.dart';

/// 购物车整体校验结果模型
class CartValidationResultModel extends CartValidationResult {
  const CartValidationResultModel({
    required bool isValidForCheckout,
    required List<String> globalMessages,
    Map<String, List<String>>? itemValidationResults,
  }) : super(
          isValidForCheckout: isValidForCheckout,
          globalMessages: globalMessages,
          itemValidationResults: itemValidationResults,
        );

  /// 从JSON映射创建模型
  factory CartValidationResultModel.fromJson(Map<String, dynamic> json) {
    return CartValidationResultModel(
      isValidForCheckout: json['isValidForCheckout'] as bool? ?? true,
      globalMessages: (json['globalMessages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      itemValidationResults: (json['itemValidationResults'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((e) => e as String).toList(),
        ),
      ),
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'isValidForCheckout': isValidForCheckout,
      'globalMessages': globalMessages,
      'itemValidationResults': itemValidationResults,
    };
  }

  /// 从实体创建模型
  factory CartValidationResultModel.fromEntity(CartValidationResult entity) {
    return CartValidationResultModel(
      isValidForCheckout: entity.isValidForCheckout,
      globalMessages: entity.globalMessages,
      itemValidationResults: entity.itemValidationResults,
    );
  }

  /// 从购物车数据生成校验结果
  factory CartValidationResultModel.validate(Map<String, dynamic> cartData) {
    bool isValid = true;
    List<String> globalMessages = [];
    Map<String, List<String>> itemResults = {};

    // 检查是否有无效商品
    if (cartData.containsKey('invalidList') && 
        cartData['invalidList'] is List && 
        (cartData['invalidList'] as List).isNotEmpty) {
      isValid = false;
      globalMessages.add('部分商品已失效或库存不足');
    }

    // 检查正常商品列表
    if (cartData.containsKey('normalList') && cartData['normalList'] is List) {
      List<dynamic> normalItems = cartData['normalList'] as List;
      
      for (var item in normalItems) {
        String itemId = item['id'].toString();
        List<String> messages = [];
        
        // 检查库存
        if (item['product'] != null && 
            item['product']['inventory'] != null && 
            item['number'] > item['product']['inventory']) {
          isValid = false;
          messages.add('库存不足');
        }
        
        // 检查商品状态
        if (item['state'] != 'NORMAL') {
          isValid = false;
          messages.add('商品已下架或失效');
        }
        
        if (messages.isNotEmpty) {
          itemResults[itemId] = messages;
        }
      }
    }

    return CartValidationResultModel(
      isValidForCheckout: isValid,
      globalMessages: globalMessages,
      itemValidationResults: itemResults.isEmpty ? null : itemResults,
    );
  }
}