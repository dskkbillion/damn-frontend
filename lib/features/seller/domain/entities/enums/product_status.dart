/// 商品状态枚举
enum ProductStatus {
  /// 正常/已上架
  normal('normal', '已上架'),

  /// 已下架
  disabled('disabled', '已下架'),

  /// 草稿
  draft('draft', '草稿'),

  /// 审核中
  reviewing('REVIEWING', '审核中'),

  /// 审核拒绝
  rejected('REJECTED', '审核拒绝'),

  /// 已售罄
  soldOut('SOLD_OUT', '已售罄');

  /// 状态的API值
  final String value;
  
  /// 状态的显示名称
  final String displayName;

  const ProductStatus(this.value, this.displayName);

  /// 从API值获取枚举
  static ProductStatus fromValue(String value) {
    return ProductStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProductStatus.normal,
    );
  }
  
  /// 是否为可编辑状态
  bool get isEditable => 
    this == ProductStatus.normal || 
    this == ProductStatus.disabled || 
    this == ProductStatus.draft;
  
  /// 是否为可发布状态
  bool get isPublishable => 
    this == ProductStatus.draft || 
    this == ProductStatus.rejected;
  
  /// 是否为可上架/下架切换状态
  bool get isSwitchable => 
    this == ProductStatus.normal || 
    this == ProductStatus.disabled;
} 