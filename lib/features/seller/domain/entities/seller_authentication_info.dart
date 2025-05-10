import 'package:equatable/equatable.dart';

/// 认证类型枚举
enum AuthenticationType {
  /// 身份证认证
  idCard('real_name', '实名认证', '上传身份证正反面进行认证'),
  
  /// 学历认证
  education('background', '学历认证', '上传学历证明进行认证'),
  
  /// 职业认证
  profession('other', '职业认证', '上传职业资格证书进行认证'),
  
  /// 公司认证
  company('corporation', '公司认证', '上传营业执照等进行认证'),
  
  /// 其他认证
  other('other', '其他认证', '');

  /// 认证类型的API值
  final String value;
  
  /// 认证类型的显示名称
  final String displayName;
  
  /// 认证类型的描述
  final String description;

  const AuthenticationType(this.value, this.displayName, this.description);

  /// 从API值获取枚举
  static AuthenticationType fromValue(String value) {
    return AuthenticationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AuthenticationType.other,
    );
  }
}

/// 认证状态枚举
enum AuthenticationStatus {
  /// 待认证 (未提交)
  notSubmitted('NOT_SUBMITTED', '未提交'),
  
  /// 认证中 (审核中)
  pending('PENDING', '审核中'),
  
  /// 已认证 (审核通过)
  approved('APPROVED', '已认证'),
  
  /// 认证拒绝 (审核不通过)
  rejected('REJECTED', '未通过');

  /// 认证状态的API值
  final String value;
  
  /// 认证状态的显示名称
  final String displayName;

  const AuthenticationStatus(this.value, this.displayName);

  /// 从API值获取枚举
  static AuthenticationStatus fromValue(String? value) {
    if (value == null) return AuthenticationStatus.notSubmitted;
    
    return AuthenticationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AuthenticationStatus.notSubmitted,
    );
  }
  
  /// 检查是否可以提交/重新提交认证
  bool get canSubmit => 
    this == AuthenticationStatus.notSubmitted || 
    this == AuthenticationStatus.rejected;
}

/// 卖家认证信息实体
class SellerAuthenticationInfo extends Equatable {
  /// 认证项ID
  final int authenticationId;
  
  /// 认证类型
  final AuthenticationType type;
  
  /// 认证状态
  final AuthenticationStatus status;
  
  /// 认证名称
  final String name;
  
  /// 图标
  final String? icon;
  
  /// 说明文字
  final String? remarks;
  
  /// 是否启用 (OPEN/SHUT)
  final bool enabled;
  
  /// 提交的字段 (键值对形式，依赖于认证类型)
  final Map<String, dynamic>? fields;
  
  /// 拒绝原因
  final String? rejectionReason;
  
  /// 提交时间
  final DateTime? submittedAt;

  const SellerAuthenticationInfo({
    required this.authenticationId,
    required this.type,
    required this.status,
    required this.name,
    required this.enabled,
    this.icon,
    this.remarks,
    this.fields,
    this.rejectionReason,
    this.submittedAt,
  });

  @override
  List<Object?> get props => [
    authenticationId,
    type,
    status,
    name,
    enabled,
    icon,
    remarks,
    fields,
    rejectionReason,
    submittedAt,
  ];
  
  /// 检查是否可以提交/重新提交认证
  bool get canSubmit => enabled && status.canSubmit;
  
  /// 检查是否已认证通过
  bool get isApproved => status == AuthenticationStatus.approved;
  
  /// 检查是否处于待审核状态
  bool get isPending => status == AuthenticationStatus.pending;
}

/// 认证申请提交数据
class AuthenticationApplicationData extends Equatable {
  /// 认证项ID
  final int authenticationId;
  
  /// 认证类型
  final String authenticationType;
  
  /// 认证名称 (申请人姓名/公司名称等)
  final String? name;
  
  /// 备注说明
  final String? remark;
  
  /// 图片列表 (逗号分隔的图片URL)
  final String? images;
  
  /// 附加字段 (JSON对象)
  final Map<String, dynamic>? feature;

  const AuthenticationApplicationData({
    required this.authenticationId,
    required this.authenticationType,
    this.name,
    this.images,
    this.remark,
    this.feature,
  });

  @override
  List<Object?> get props => [
    authenticationId,
    authenticationType,
    name,
    remark,
    images,
    feature,
  ];
  
  /// 转换为API参数格式
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'authenticationId': authenticationId,
    };
    
    // 添加图片数组 - 将逗号分隔的字符串拆分为数组
    if (images != null && images!.isNotEmpty) {
      data['images'] = images!.split(',').where((s) => s.isNotEmpty).toList();
    } else {
      data['images'] = [];
    }
    
    // 根据认证类型添加不同字段
    final authType = authenticationType;
    
    if (authType == 'real_name') {
      // 实名认证只需要基本字段
    } else if (authType == 'background') {
      // 学校认证需要备注
      if (remark != null) data['remarks'] = remark;
      if (feature != null) data['feature'] = feature;
    } else if (authType == 'corporation') {
      // 公司认证需要名称
      if (name != null) data['name'] = name;
      if (feature != null) data['feature'] = feature;
    } else {
      // 其他类型认证
      if (name != null) data['name'] = name;
      if (remark != null) data['remarks'] = remark;
      if (feature != null) data['feature'] = feature;
    }
    
    return data;
  }
} 