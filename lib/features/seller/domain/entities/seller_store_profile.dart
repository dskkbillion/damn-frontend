import 'package:equatable/equatable.dart';

/// 联系信息
class ContactInfo extends Equatable {
  /// 联系电话
  final String? phone;
  
  /// 电子邮箱
  final String? email;

  const ContactInfo({
    this.phone,
    this.email,
  });

  @override
  List<Object?> get props => [phone, email];
}

/// 店铺政策
class StorePolicies extends Equatable {
  /// 退款政策
  final String? refundPolicy;
  
  /// 交付政策
  final String? deliveryPolicy;
  
  /// 修改政策
  final String? revisionPolicy;

  const StorePolicies({
    this.refundPolicy,
    this.deliveryPolicy,
    this.revisionPolicy,
  });

  @override
  List<Object?> get props => [refundPolicy, deliveryPolicy, revisionPolicy];
}

/// 卖家店铺公开信息
class SellerStoreProfile extends Equatable {
  /// 店铺唯一标识
  final String storeId;
  
  /// 店铺名称
  final String storeName;
  
  /// 店铺Logo URL
  final String? logoUrl;
  
  /// 店铺描述
  final String? description;
  
  /// 联系方式
  final ContactInfo? contactInfo;
  
  /// 店铺政策
  final StorePolicies? policies;
  
  /// 卖家在线状态
  final bool? onlineFlag;
  
  /// 加入时间
  final DateTime? joinTime;
  
  /// 订单完成率
  final double? completionRate;
  
  /// 平均评分
  final double? averageRating;
  
  /// 认证标签列表
  final List<String>? certifications;

  const SellerStoreProfile({
    required this.storeId,
    required this.storeName,
    this.logoUrl,
    this.description,
    this.contactInfo,
    this.policies,
    this.onlineFlag,
    this.joinTime,
    this.completionRate,
    this.averageRating,
    this.certifications,
  });

  @override
  List<Object?> get props => [
    storeId,
    storeName,
    logoUrl,
    description,
    contactInfo,
    policies,
    onlineFlag,
    joinTime,
    completionRate,
    averageRating,
    certifications,
  ];
  
  /// 创建更新数据对象
  StoreProfileUpdateData toUpdateData() {
    return StoreProfileUpdateData(
      storeName: storeName,
      logoUrl: logoUrl,
      description: description,
      contactInfo: contactInfo,
      policies: policies,
    );
  }
}

/// 店铺资料更新数据
class StoreProfileUpdateData extends Equatable {
  /// 店铺名称
  final String? storeName;
  
  /// 店铺Logo URL
  final String? logoUrl;
  
  /// 店铺描述
  final String? description;
  
  /// 联系方式
  final ContactInfo? contactInfo;
  
  /// 店铺政策
  final StorePolicies? policies;

  const StoreProfileUpdateData({
    this.storeName,
    this.logoUrl,
    this.description,
    this.contactInfo,
    this.policies,
  });

  @override
  List<Object?> get props => [
    storeName,
    logoUrl,
    description,
    contactInfo,
    policies,
  ];
} 