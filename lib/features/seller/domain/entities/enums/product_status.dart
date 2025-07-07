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
  soldOut('SOLD_OUT', '已售罄'),

  /// 未知状态
  unknown('UNKNOWN', '未知状态');

  /// 状态的API值
  final String value;
  
  /// 状态的显示名称
  final String displayName;

  const ProductStatus(this.value, this.displayName);

  /// 从API值获取枚举
  static ProductStatus fromValue(String value) {
    print('ProductStatus.fromValue: 尝试解析状态值 "$value"');
    
    // 首先尝试精确匹配
    for (final status in ProductStatus.values) {
      if (status.value == value) {
        print('ProductStatus.fromValue: 找到精确匹配 "$value" -> ${status.name}');
        return status;
      }
    }
    
    // 如果没有精确匹配，尝试大小写不敏感匹配
    final normalizedValue = value.toUpperCase();
    for (final status in ProductStatus.values) {
      if (status.value.toUpperCase() == normalizedValue) {
        print('ProductStatus.fromValue: 找到大小写不敏感匹配 "$value" -> ${status.name}');
        return status;
      }
    }
    
    // 特殊处理一些常见的状态值映射
    switch (normalizedValue) {
      case 'NORMAL':
      case 'ON_SALE':
      case 'PUBLISHED':
        print('ProductStatus.fromValue: 映射 "$value" -> normal');
        return ProductStatus.normal;
      case 'DISABLED':
      case 'OFF_SALE':
      case 'OFFLINE':
        print('ProductStatus.fromValue: 映射 "$value" -> disabled');
        return ProductStatus.disabled;
      case 'DRAFT':
      case 'UNPUBLISHED':
        print('ProductStatus.fromValue: 映射 "$value" -> draft');
        return ProductStatus.draft;
      case 'UNKNOWN':
      case '':
        print('ProductStatus.fromValue: 映射 "$value" -> unknown');
        return ProductStatus.unknown;
    }
    
    // 如果都没有匹配，默认返回draft而不是normal，避免误判为上架状态
    print('ProductStatus.fromValue: 警告！未知状态值 "$value"，默认返回 draft');
    return ProductStatus.draft;
  }
  
  /// 是否为可编辑状态
  bool get isEditable => 
    this == ProductStatus.normal || 
    this == ProductStatus.disabled || 
    this == ProductStatus.draft ||
    this == ProductStatus.unknown; // 未知状态可以编辑来修正状态
  
  /// 是否为可发布状态
  bool get isPublishable => 
    this == ProductStatus.draft || 
    this == ProductStatus.rejected ||
    this == ProductStatus.unknown; // 未知状态可以重新发布
  
  /// 是否为可上架/下架切换状态
  bool get isSwitchable => 
    this == ProductStatus.normal || 
    this == ProductStatus.disabled;
} 