import 'package:equatable/equatable.dart';

/// 已分发商品记录(#347 已分发服务追溯入口)。
///
/// 后端 GET /model/chat/allocations/list 返回的一条记录。
/// Redis 保留期由 ALLOCATION_STATUS_TTL 决定,超期记录不会出现在列表里。
class AllocatedItemEntity extends Equatable {
  /// 商品 ID(后端 stringified,这里保持 String)
  final String itemId;

  /// 商家(卖家)ID
  final int? merchantId;

  /// Unix 时间戳(秒)。后端使用 int(time.time())
  final int? allocatedAt;

  /// 后端默认 "allocated"
  final String status;

  const AllocatedItemEntity({
    required this.itemId,
    this.merchantId,
    this.allocatedAt,
    this.status = 'allocated',
  });

  /// 从后端 JSON 反序列化。容错:itemId 缺失时回退到空串。
  factory AllocatedItemEntity.fromJson(Map<String, dynamic> json) {
    return AllocatedItemEntity(
      itemId: (json['itemId'] ?? json['item_id'] ?? '').toString(),
      merchantId: (json['merchantId'] ?? json['merchant_id']) as int?,
      allocatedAt: (json['allocatedAt'] ?? json['allocated_at']) as int?,
      status: (json['status'] as String?) ?? 'allocated',
    );
  }

  @override
  List<Object?> get props => [itemId, merchantId, allocatedAt, status];
}
