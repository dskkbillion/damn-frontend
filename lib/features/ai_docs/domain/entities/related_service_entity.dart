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

  /// {@macro related_service_entity}
  const RelatedServiceEntity({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
  });

  @override
  // Updated props list
  List<Object?> get props => [id, imageUrl, title, price]; 
} 