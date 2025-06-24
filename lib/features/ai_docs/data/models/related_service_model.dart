import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/related_service_entity.dart';

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
    // Updated fields and types based on actual API response.
    // Added @JsonKey annotations for mapping.
    required int id, // Changed to int
    @JsonKey(name: 'mainImage') required String imageUrl, 
    @JsonKey(name: 'name') required String title,
    // rating field removed
    @JsonKey(name: 'sellingPrice') required double price, // Changed to double
    @JsonKey(name: 'allocation_status_recorded') @Default(false) bool allocationStatusRecorded,
    // Add other fields from API if needed (e.g., originalPrice, tenantId, etc.)
    // Consider adding them as optional if not used by the domain.
  }) = _RelatedServiceModel;

  /// Creates a [RelatedServiceModel] from a JSON map.
  factory RelatedServiceModel.fromJson(Map<String, dynamic> json) =>
      _$RelatedServiceModelFromJson(json);

  /// Converts this [RelatedServiceModel] to its corresponding Domain [RelatedService] entity.
  RelatedServiceEntity toEntity() {
    // Updated mapping based on new entity structure.
    return RelatedServiceEntity(
      id: id,
      imageUrl: imageUrl,
      title: title,
      price: price,
      allocationStatusRecorded: allocationStatusRecorded,
      // rating is removed
    );
  }
} 