import 'package:equatable/equatable.dart';

/// 钱包交易记录数据传输对象
class TransactionDto extends Equatable {
  /// 交易ID
  final String id;

  /// 交易金额（正数为收入，负数为支出）
  final double amount;

  /// 交易类型（income: 收入, outcome: 支出）
  final String type;

  /// 交易描述
  final String description;

  /// 交易日期时间
  final DateTime date;

  /// 交易状态（completed: 已完成, pending: 处理中, failed: 失败）
  final String status;

  /// 构造函数
  const TransactionDto({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    required this.status,
  });

  /// 从JSON映射创建TransactionDto实例
  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] ?? '',
      amount: _parseDouble(json['amount']) ?? 0.0,
      type: json['type'] ?? 'unknown',
      description: json['description'] ?? '',
      date: json['date'] is String
          ? DateTime.parse(json['date'])
          : (json['date'] is DateTime ? json['date'] : DateTime.now()),
      status: json['status'] ?? 'completed',
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, amount, type, description, date, status];

  /// 解析数字类型值，处理字符串和数字类型
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
