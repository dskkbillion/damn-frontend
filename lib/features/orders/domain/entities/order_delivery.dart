/// 订单交付实体
class OrderDelivery {
  final int id;
  final int orderId;
  final String content; // 交付说明文本
  final List<String> files; // 交付文件URL列表
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderDelivery({
    required this.id,
    required this.orderId,
    required this.content,
    required this.files,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderDelivery &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orderId == other.orderId;

  @override
  int get hashCode => id.hashCode ^ orderId.hashCode;

  @override
  String toString() {
    return 'OrderDelivery{id: $id, orderId: $orderId, content: $content, files: $files}';
  }
}