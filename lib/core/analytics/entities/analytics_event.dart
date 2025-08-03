import 'dart:convert';

import 'package:equatable/equatable.dart';

/// 用户行为分析事件实体
/// 对应后端 dskk_dau 表的数据结构
class AnalyticsEvent extends Equatable {
  /// 页面路径，如"/item_from_homepage"
  final String? path;

  /// 业务类型，如"pv", "click", "cart"等
  final String businessType;

  /// 业务ID，根据businessType的不同有不同含义
  final int? businessId;

  /// 业务扩展数据（JSON格式）
  final Map<String, dynamic>? feature;

  /// 设备信息
  final Map<String, dynamic>? deviceInfo;

  /// 用户标识符（包括登录用户和游客）
  final dynamic userSign;

  /// 停留时间（单位：秒）
  final int? interval;

  /// 事件创建时间
  final DateTime timestamp;

  AnalyticsEvent({
    this.path,
    required this.businessType,
    this.businessId,
    this.feature,
    this.deviceInfo,
    this.userSign,
    this.interval,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 转换为API请求格式
  Map<String, dynamic> toApiJson() {
    final json = <String, dynamic>{
      'businessType': businessType,
    };

    if (path != null) json['path'] = path;
    if (businessId != null) json['businessId'] = businessId;
    if (feature != null) json['feature'] = feature;
    // 后端期望 deviceInfo 是字符串类型，需要将对象序列化为 JSON 字符串
    if (deviceInfo != null) {
      json['deviceInfo'] = jsonEncode(deviceInfo);
    }
    if (userSign != null) json['userSign'] = userSign;
    if (interval != null) json['interval'] = interval;

    return json;
  }

  /// 从JSON创建实例（用于本地存储）
  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      path: json['path'] as String?,
      businessType: json['businessType'] as String,
      businessId: json['businessId'] as int?,
      feature: json['feature'] as Map<String, dynamic>?,
      deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
      userSign: json['userSign'],
      interval: json['interval'] as int?,
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
    );
  }

  /// 转换为JSON（用于本地存储）
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'businessType': businessType,
      'businessId': businessId,
      'feature': feature,
      'deviceInfo': deviceInfo,
      'userSign': userSign,
      'interval': interval,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [
        path,
        businessType,
        businessId,
        feature,
        deviceInfo,
        userSign,
        interval,
        timestamp,
      ];

  AnalyticsEvent copyWith({
    String? path,
    String? businessType,
    int? businessId,
    Map<String, dynamic>? feature,
    Map<String, dynamic>? deviceInfo,
    dynamic userSign,
    int? interval,
    DateTime? timestamp,
  }) {
    return AnalyticsEvent(
      path: path ?? this.path,
      businessType: businessType ?? this.businessType,
      businessId: businessId ?? this.businessId,
      feature: feature ?? this.feature,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      userSign: userSign ?? this.userSign,
      interval: interval ?? this.interval,
      timestamp: timestamp ?? this.timestamp,
    );
  }
} 