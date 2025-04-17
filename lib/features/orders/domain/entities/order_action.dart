/// 表示用户可以对订单执行的操作。
///
/// 注意：实际可用的操作取决于订单的当前状态 (`OrderStatus`)，
/// 这个判断逻辑通常在 Presentation 层根据业务规则实现。
enum OrderAction {
  /// 去支付 (通常导航到支付流程)
  pay,

  /// 取消订单
  cancel,

  /// 提交材料 (特定订单类型可能需要)
  submitMaterials,

  /// 重新提交材料 (如果上次提交有问题)
  repostMaterials,

  /// 确认收货
  confirmReceipt,

  /// 查看物流 (可能仅展示单号或导航)
  viewTracking,

  /// 申请售后/退款 (通常导航到售后流程)
  requestRefund,

  /// 申请平台介入 (如果发生争议)
  requestMediation,

  /// 评价晒单 (通常导航到评价流程)
  evaluate,

  /// 删除订单 (逻辑删除或物理删除，取决于业务)
  delete,

  /// 再次购买 (通常将商品重新加入购物车)
  rebuy,

  /// 联系卖家 (通常导航到聊天界面)
  contactSeller,

  /// 未知或不支持的操作
  unknown,
} 