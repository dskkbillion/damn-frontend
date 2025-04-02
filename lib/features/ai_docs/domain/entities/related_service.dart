import 'package:equatable/equatable.dart';

/// {@template related_service}
/// Represents a service recommendation related to an AI conversation.
/// Structure based on API `/recsys/conversation/recommend` response (needs confirmation).
/// {@endtemplate}
class RelatedService extends Equatable {
  /// {@macro related_service}
  const RelatedService({
    required this.id, // Assuming an ID field exists
    this.imageUrl,
    this.title,
    this.rating,
    this.price,
    // Add other fields based on actual API response
  });

  final String id;
  final String? imageUrl;
  final String? title;
  final double? rating;
  final String? price; // Or double?

  @override
  List<Object?> get props => [id, imageUrl, title, rating, price];
} 