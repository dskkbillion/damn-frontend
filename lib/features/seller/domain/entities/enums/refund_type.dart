
/// 退款类型枚举
///
/// 基于后端API退款类型值映射
enum RefundType {
  /// 仅退款
  onlyMoney('ONLY_MONEY', '仅退款'),

  /// 退货退款
  moneyAndProduct('MONEY_AND_PRODUCT', '退货退款'),

  /// 未知类型
  unknown('UNKNOWN', '未知类型');

  /// 类型的API值
  final String value;

  /// 用于显示的类型名称
  final String displayName;

  const RefundType(this.value, this.displayName);

  /// 根据API返回的值获取对应的枚举值
  static RefundType fromValue(String? value) {
    final normalized = value?.trim().toUpperCase().replaceAll('-', '_');
    return RefundType.values.firstWhere(
      (type) => type.value == normalized,
      orElse: () => RefundType.unknown,
    );
  }

  /// 是否需要处理物流
  bool get needsLogistics => this == RefundType.moneyAndProduct;
}
