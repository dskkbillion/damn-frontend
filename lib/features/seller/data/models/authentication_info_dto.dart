import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';

/// 认证信息DTO
class AuthenticationInfoDto {
  /// 认证ID
  final int? id;
  
  /// 认证类型
  final String? type;
  
  /// 认证状态
  final String? status;
  
  /// 认证名称
  final String? name;
  
  /// 图标
  final String? icon;
  
  /// 说明文字
  final String? remark;
  
  /// 是否启用
  final dynamic enabled;
  
  /// 提交的字段
  final Map<String, dynamic>? fields;
  
  /// 拒绝原因
  final String? rejectionReason;
  
  /// 提交时间
  final String? submittedAt;
  
  /// 构造函数
  AuthenticationInfoDto({
    this.id,
    this.type,
    this.status,
    this.name,
    this.icon,
    this.remark,
    this.enabled,
    this.fields,
    this.rejectionReason,
    this.submittedAt,
  });
  
  /// 从JSON构造
  factory AuthenticationInfoDto.fromJson(Map<String, dynamic> json) {
    return AuthenticationInfoDto(
      id: json['id'],
      type: json['type'],
      status: json['status'],
      name: json['name'],
      icon: json['icon'],
      remark: json['remark'],
      enabled: json['enabled'],
      fields: json['fields'] as Map<String, dynamic>?,
      rejectionReason: json['rejectionReason'],
      submittedAt: json['submittedAt'],
    );
  }
  
  /// 转换为领域实体
  SellerAuthenticationInfo toEntity() {
    // 解析提交时间
    DateTime? parsedSubmittedAt;
    if (submittedAt != null) {
      try {
        parsedSubmittedAt = DateTime.parse(submittedAt!);
      } catch (e) {
        parsedSubmittedAt = null;
      }
    }
    
    // 解析是否启用
    bool isEnabled = false;
    if (enabled != null) {
      if (enabled is bool) {
        isEnabled = enabled;
      } else if (enabled is String) {
        isEnabled = enabled == 'OPEN' || enabled.toLowerCase() == 'true';
      } else if (enabled is num) {
        isEnabled = enabled != 0;
      }
    }
    
    // 解析认证类型
    final authenticationType = AuthenticationType.fromValue(type ?? 'OTHER');
    
    // 解析认证状态
    final authenticationStatus = AuthenticationStatus.fromValue(status);
    
    return SellerAuthenticationInfo(
      authenticationId: id ?? 0,
      type: authenticationType,
      status: authenticationStatus,
      name: name ?? authenticationType.displayName,
      enabled: isEnabled,
      icon: icon,
      remarks: remark,
      fields: fields,
      rejectionReason: rejectionReason,
      submittedAt: parsedSubmittedAt,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (id != null) data['id'] = id;
    if (type != null) data['type'] = type;
    if (status != null) data['status'] = status;
    if (name != null) data['name'] = name;
    if (icon != null) data['icon'] = icon;
    if (remark != null) data['remark'] = remark;
    if (enabled != null) data['enabled'] = enabled;
    if (fields != null) data['fields'] = fields;
    if (rejectionReason != null) data['rejectionReason'] = rejectionReason;
    if (submittedAt != null) data['submittedAt'] = submittedAt;
    
    return data;
  }
}

/// 认证申请提交数据DTO
class AuthenticationApplicationDataDto {
  /// 认证项ID
  final int? authenticationId;
  
  /// 认证类型
  final String? authenticationType;
  
  /// 认证名称
  final String? name;
  
  /// 备注说明
  final String? remark;
  
  /// 图片列表
  final String? images;
  
  /// 附加字段
  final Map<String, dynamic>? feature;
  
  /// 构造函数
  AuthenticationApplicationDataDto({
    this.authenticationId,
    this.authenticationType,
    this.name,
    this.remark,
    this.images,
    this.feature,
  });
  
  /// 从JSON构造
  factory AuthenticationApplicationDataDto.fromJson(Map<String, dynamic> json) {
    return AuthenticationApplicationDataDto(
      authenticationId: json['authenticationId'],
      authenticationType: json['authenticationType'],
      name: json['name'],
      remark: json['remark'],
      images: json['images'],
      feature: json['feature'] as Map<String, dynamic>?,
    );
  }
  
  /// 转换为领域实体
  AuthenticationApplicationData toEntity() {
    return AuthenticationApplicationData(
      authenticationId: authenticationId ?? 0,
      authenticationType: authenticationType ?? 'OTHER',
      name: name ?? '',
      images: images ?? '',
      remark: remark,
      feature: feature,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (authenticationId != null) data['authenticationId'] = authenticationId;
    if (authenticationType != null) data['authenticationType'] = authenticationType;
    if (name != null) data['name'] = name;
    if (remark != null) data['remark'] = remark;
    if (images != null) data['images'] = images;
    if (feature != null) data['feature'] = feature;
    
    return data;
  }
} 