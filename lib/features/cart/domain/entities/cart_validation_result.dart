import 'package:equatable/equatable.dart';

/// 购物车整体校验结果
class CartValidationResult extends Equatable {
  /// 是否有效可以进行结算
  final bool isValidForCheckout;
  
  /// 全局提示 (如"部分商品已失效")
  final List<String> globalMessages;
  
  /// 各项商品的校验结果，key为cartItemId，value为该商品的错误消息列表
  final Map<String, List<String>>? itemValidationResults;

  const CartValidationResult({
    required this.isValidForCheckout,
    required this.globalMessages,
    this.itemValidationResults,
  });

  /// 创建一个有效的校验结果
  factory CartValidationResult.valid() {
    return const CartValidationResult(
      isValidForCheckout: true,
      globalMessages: [],
    );
  }

  /// 创建一个无效的校验结果，带有全局错误消息
  factory CartValidationResult.invalid({
    required List<String> messages,
    Map<String, List<String>>? itemResults,
  }) {
    return CartValidationResult(
      isValidForCheckout: false,
      globalMessages: messages,
      itemValidationResults: itemResults,
    );
  }

  /// 获取特定商品的验证消息
  List<String> getItemMessages(String cartItemId) {
    return itemValidationResults?[cartItemId] ?? [];
  }

  /// 检查特定商品是否有验证错误
  bool hasItemErrors(String cartItemId) {
    return (itemValidationResults?[cartItemId]?.isNotEmpty ?? false);
  }

  @override
  List<Object?> get props => [isValidForCheckout, globalMessages, itemValidationResults];
}