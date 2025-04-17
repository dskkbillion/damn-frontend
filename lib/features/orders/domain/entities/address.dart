import 'package:equatable/equatable.dart';

/// 表示订单的收货地址信息。
class Address extends Equatable {
  /// 收件人姓名。
  final String recipientName;

  /// 联系电话。
  final String phone;

  /// 地区 ID (可能需要结合其他服务或本地数据转换为省市区文本)。
  final String areaId;

  /// 详细街道地址。
  final String detailAddress;

  /// 创建一个 [Address] 实例。
  const Address({
    required this.recipientName,
    required this.phone,
    required this.areaId,
    required this.detailAddress,
  });

  // Add an empty factory constructor or static constant
  static const Address empty = Address(
    recipientName: '',
    phone: '',
    areaId: '0',
    detailAddress: '',
  );

  @override
  List<Object?> get props => [recipientName, phone, areaId, detailAddress];

  // 可选：添加一个简单的 getter 用于显示完整地址字符串
  String get fullAddress => '$recipientName, $phone, Area $areaId, $detailAddress'; // 实际展示可能需要更复杂的格式化
} 