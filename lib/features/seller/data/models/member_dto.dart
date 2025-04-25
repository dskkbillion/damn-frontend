import 'package:dskk_flutter_refactor/features/seller/domain/entities/auto_reply_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';

/// Member DTO模型 - 用于解析API响应
class MemberDto {
  /// 会员ID
  final int? id;
  
  /// 昵称
  final String? nickName;
  
  /// 状态
  final String? status;
  
  /// 真实姓名
  final String? trueName;
  
  /// 头像URL
  final String? avatar;
  
  /// 手机号
  final String? mobile;
  
  /// 性别
  final String? gender;
  
  /// 省份
  final String? province;
  
  /// 城市
  final String? city;
  
  /// 区县
  final String? county;
  
  /// 地址
  final String? address;
  
  /// 租户ID
  final int? tenantId;
  
  /// 会员类型
  final String? type;
  
  /// 最近登录时间
  final String? loginTime;
  
  /// 会员等级ID
  final int? levelId;
  
  /// 是否自动回复
  final bool? recoverFlag;
  
  /// 自动回复内容
  final String? recoverContent;
  
  /// 成为当前等级时间
  final String? levelTime;
  
  /// 发布商品数量
  final int? productNum;
  
  /// 接单数量
  final int? orderNum;
  
  /// 购买数量
  final int? buyOrderNum;
  
  /// 是否实名认证
  final bool? realNameFlag;
  
  /// 余额
  final double? balance;
  
  /// 积分
  final double? integral;
  
  /// 创建时间
  final String? createTime;
  
  /// 更新时间
  final String? updateTime;
  
  /// 在线状态标志
  final bool? onlineFlag;
  
  /// 构造函数
  MemberDto({
    this.id,
    this.nickName,
    this.status,
    this.trueName,
    this.avatar,
    this.mobile,
    this.gender,
    this.province,
    this.city,
    this.county,
    this.address,
    this.tenantId,
    this.type,
    this.loginTime,
    this.levelId,
    this.recoverFlag,
    this.recoverContent,
    this.levelTime,
    this.productNum,
    this.orderNum,
    this.buyOrderNum,
    this.realNameFlag,
    this.balance,
    this.integral,
    this.createTime,
    this.updateTime,
    this.onlineFlag,
  });

  /// 从JSON构造
  factory MemberDto.fromJson(Map<String, dynamic> json) {
    return MemberDto(
      id: json['id'],
      nickName: json['nickName'],
      status: json['status'],
      trueName: json['trueName'],
      avatar: json['avatar'],
      mobile: json['mobile'],
      gender: json['gender'],
      province: json['province'],
      city: json['city'],
      county: json['county'],
      address: json['address'],
      tenantId: json['tenantId'],
      type: json['type'],
      loginTime: json['loginTime'],
      levelId: json['levelId'],
      recoverFlag: json['recoverFlag'],
      recoverContent: json['recoverContent'],
      levelTime: json['levelTime'],
      productNum: json['productNum'],
      orderNum: json['orderNum'],
      buyOrderNum: json['buyOrderNum'],
      realNameFlag: json['realNameFlag'],
      balance: json['balance'] != null ? double.tryParse(json['balance'].toString()) : null,
      integral: json['integral'] != null ? double.tryParse(json['integral'].toString()) : null,
      createTime: json['createTime'],
      updateTime: json['updateTime'],
      onlineFlag: json['onlineFlag'],
    );
  }
  
  /// 将DTO转换为AutoReplySettings实体
  AutoReplySettings toAutoReplySettings() {
    if (recoverFlag == null) {
      return AutoReplySettings.defaultSettings();
    }
    
    return AutoReplySettings(
      isEnabled: recoverFlag!,
      content: recoverContent,
    );
  }
  
  /// 将DTO转换为TimeSettings实体
  TimeSettings toTimeSettings() {
    return TimeSettings(
      isOnline: onlineFlag ?? false,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (id != null) data['id'] = id;
    if (nickName != null) data['nickName'] = nickName;
    if (status != null) data['status'] = status;
    if (trueName != null) data['trueName'] = trueName;
    if (avatar != null) data['avatar'] = avatar;
    if (mobile != null) data['mobile'] = mobile;
    if (gender != null) data['gender'] = gender;
    if (province != null) data['province'] = province;
    if (city != null) data['city'] = city;
    if (county != null) data['county'] = county;
    if (address != null) data['address'] = address;
    if (tenantId != null) data['tenantId'] = tenantId;
    if (type != null) data['type'] = type;
    if (loginTime != null) data['loginTime'] = loginTime;
    if (levelId != null) data['levelId'] = levelId;
    if (recoverFlag != null) data['recoverFlag'] = recoverFlag;
    if (recoverContent != null) data['recoverContent'] = recoverContent;
    if (levelTime != null) data['levelTime'] = levelTime;
    if (productNum != null) data['productNum'] = productNum;
    if (orderNum != null) data['orderNum'] = orderNum;
    if (buyOrderNum != null) data['buyOrderNum'] = buyOrderNum;
    if (realNameFlag != null) data['realNameFlag'] = realNameFlag;
    if (balance != null) data['balance'] = balance;
    if (integral != null) data['integral'] = integral;
    if (createTime != null) data['createTime'] = createTime;
    if (updateTime != null) data['updateTime'] = updateTime;
    if (onlineFlag != null) data['onlineFlag'] = onlineFlag;
    
    return data;
  }
} 