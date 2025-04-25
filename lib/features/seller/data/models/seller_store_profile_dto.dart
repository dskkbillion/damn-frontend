import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';

/// 联系信息DTO
class ContactInfoDto {
  /// 联系电话
  final String? phone;
  
  /// 电子邮箱
  final String? email;
  
  /// 构造函数
  ContactInfoDto({
    this.phone,
    this.email,
  });
  
  /// 从JSON构造
  factory ContactInfoDto.fromJson(Map<String, dynamic> json) {
    return ContactInfoDto(
      phone: json['phone'],
      email: json['email'],
    );
  }
  
  /// 转换为领域实体
  ContactInfo toEntity() {
    return ContactInfo(
      phone: phone,
      email: email,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    
    return data;
  }
}

/// 店铺政策DTO
class StorePoliciesDto {
  /// 退款政策
  final String? refundPolicy;
  
  /// 交付政策
  final String? deliveryPolicy;
  
  /// 修改政策
  final String? revisionPolicy;
  
  /// 构造函数
  StorePoliciesDto({
    this.refundPolicy,
    this.deliveryPolicy,
    this.revisionPolicy,
  });
  
  /// 从JSON构造
  factory StorePoliciesDto.fromJson(Map<String, dynamic> json) {
    return StorePoliciesDto(
      refundPolicy: json['refundPolicy'],
      deliveryPolicy: json['deliveryPolicy'],
      revisionPolicy: json['revisionPolicy'],
    );
  }
  
  /// 转换为领域实体
  StorePolicies toEntity() {
    return StorePolicies(
      refundPolicy: refundPolicy,
      deliveryPolicy: deliveryPolicy,
      revisionPolicy: revisionPolicy,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (refundPolicy != null) data['refundPolicy'] = refundPolicy;
    if (deliveryPolicy != null) data['deliveryPolicy'] = deliveryPolicy;
    if (revisionPolicy != null) data['revisionPolicy'] = revisionPolicy;
    
    return data;
  }
}

/// 卖家店铺资料DTO
class SellerStoreProfileDto {
  /// 店铺/卖家ID
  final String? id;
  
  /// 店铺名称
  final String? nickName;
  
  /// 店铺别名
  final String? storeName;
  
  /// 店铺Logo
  final String? avatar;
  
  /// 店铺描述
  final String? description;
  
  /// 联系方式
  final Map<String, dynamic>? contactInfo;
  
  /// 店铺政策
  final Map<String, dynamic>? policies;
  
  /// 在线状态
  final bool? onlineFlag;
  
  /// 加入时间
  final String? joinTime;
  
  /// 完成率
  final double? completionRate;
  
  /// 平均评分
  final double? averageRating;
  
  /// 认证标签
  final List<String>? certifications;
  
  /// 构造函数
  SellerStoreProfileDto({
    this.id,
    this.nickName,
    this.storeName,
    this.avatar,
    this.description,
    this.contactInfo,
    this.policies,
    this.onlineFlag,
    this.joinTime,
    this.completionRate,
    this.averageRating,
    this.certifications,
  });
  
  /// 从JSON构造
  factory SellerStoreProfileDto.fromJson(Map<String, dynamic> json) {
    return SellerStoreProfileDto(
      id: json['id']?.toString(),
      nickName: json['nickName'],
      storeName: json['storeName'] ?? json['nickName'],
      avatar: json['avatar'],
      description: json['description'],
      contactInfo: json['contactInfo'] as Map<String, dynamic>?,
      policies: json['policies'] as Map<String, dynamic>?,
      onlineFlag: json['onlineFlag'],
      joinTime: json['joinTime'],
      completionRate: json['completionRate'] != null
          ? double.tryParse(json['completionRate'].toString())
          : null,
      averageRating: json['averageRating'] != null
          ? double.tryParse(json['averageRating'].toString())
          : null,
      certifications: json['certifications'] != null
          ? (json['certifications'] as List<dynamic>).cast<String>()
          : null,
    );
  }
  
  /// 转换为领域实体
  SellerStoreProfile toEntity() {
    // 解析加入时间
    DateTime? parsedJoinTime;
    if (joinTime != null) {
      try {
        parsedJoinTime = DateTime.parse(joinTime!);
      } catch (e) {
        parsedJoinTime = null;
      }
    }
    
    // 解析联系方式
    ContactInfo? contact;
    if (contactInfo != null) {
      contact = ContactInfoDto.fromJson(contactInfo!).toEntity();
    }
    
    // 解析店铺政策
    StorePolicies? storePolicy;
    if (policies != null) {
      storePolicy = StorePoliciesDto.fromJson(policies!).toEntity();
    }
    
    // 使用当前DTO的值构建实体对象
    return SellerStoreProfile(
      storeId: id ?? '',
      storeName: storeName ?? nickName ?? '',
      logoUrl: avatar,
      description: description,
      contactInfo: contact,
      policies: storePolicy,
      onlineFlag: onlineFlag,
      joinTime: parsedJoinTime,
      completionRate: completionRate,
      averageRating: averageRating,
      certifications: certifications,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (id != null) data['id'] = id;
    if (nickName != null) data['nickName'] = nickName;
    if (storeName != null) data['storeName'] = storeName;
    if (avatar != null) data['avatar'] = avatar;
    if (description != null) data['description'] = description;
    if (contactInfo != null) data['contactInfo'] = contactInfo;
    if (policies != null) data['policies'] = policies;
    if (onlineFlag != null) data['onlineFlag'] = onlineFlag;
    if (joinTime != null) data['joinTime'] = joinTime;
    if (completionRate != null) data['completionRate'] = completionRate;
    if (averageRating != null) data['averageRating'] = averageRating;
    if (certifications != null) data['certifications'] = certifications;
    
    return data;
  }
} 