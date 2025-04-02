import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/related_service.dart'; // Adjust import path if needed

part 'related_service_model.freezed.dart';
part 'related_service_model.g.dart';

/// {@template related_service_model}
/// Data Transfer Object (DTO) representing a related service recommendation from the API.
///
/// This model should strictly match the JSON structure returned by the
/// `/recsys/conversation/recommend` endpoint.
/// **Note:** The exact structure of the API response needs confirmation.
/// {@endtemplate}
@freezed
class RelatedServiceModel with _$RelatedServiceModel {
  /// {@macro related_service_model}
  const RelatedServiceModel._(); // Private constructor for implementing methods

  /// Factory constructor for creating a [RelatedServiceModel].
  const factory RelatedServiceModel({
    // Assuming API returns these fields, adjust based on actual response
    required String id,
    String? imageUrl, // Or maybe 'image_url' in JSON?
    String? title,
    double? rating,
    String? price, // Or double? Or maybe 'price_string'?
  }) = _RelatedServiceModel;

  /// Creates a [RelatedServiceModel] from a JSON map.
  factory RelatedServiceModel.fromJson(Map<String, dynamic> json) =>
      _$RelatedServiceModelFromJson(json);

  /// Converts this [RelatedServiceModel] to its corresponding Domain [RelatedService] entity.
  RelatedService toEntity() {
    // Direct mapping assuming field names match or are handled by JsonKey
    return RelatedService(
      id: id,
      imageUrl: imageUrl,
      title: title,
      rating: rating,
      price: price,
    );
  }
} 