import 'package:equatable/equatable.dart';

/// {@template related_service_entity}
/// Represents a related service recommendation in the domain layer.
/// Updated based on actual API response.
/// {@endtemplate}
class RelatedServiceEntity extends Equatable {
  final int id; // Changed type to int
  final String imageUrl;
  final String title;
  // rating field removed as it's not in the API response
  final double price; // Changed type to double
  final bool allocationStatusRecorded; // 🆕 新增字段
  final int tenantId; // 商家/卖家ID

  /// {@macro related_service_entity}
  const RelatedServiceEntity({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.allocationStatusRecorded = false, // 默认值
    required this.tenantId,
  });

  @override
  // Updated props list
  List<Object?> get props => [id, imageUrl, title, price, allocationStatusRecorded, tenantId]; 
} 