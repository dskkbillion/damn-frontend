import 'package:dskk_flutter_refactor/features/orders/domain/entities/address.dart';
import 'package:equatable/equatable.dart';

/// Data Transfer Object (DTO) for Address, matching the API structure.
class AddressModel extends Equatable {
  final String? name; // API: name
  final String? mobile; // API: mobile
  final String? areaCode; // API: areaCode
  final String? detail; // API: detail

  const AddressModel({
    this.name,
    this.mobile,
    this.areaCode,
    this.detail,
  });

  /// Factory constructor to create an AddressModel from a JSON map.
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      name: json['name'] as String?,
      mobile: json['mobile'] as String?,
      areaCode: json['areaCode'] as String?,
      detail: json['detail'] as String?,
    );
  }

  /// Converts this Data Transfer Object to a Domain [Address] entity.
  Address toEntity() {
    return Address(
      recipientName: name ?? '', // Provide default empty string if null
      phone: mobile ?? '',
      areaId: areaCode ?? '', // Map areaCode to areaId
      detailAddress: detail ?? '',
    );
  }

  @override
  List<Object?> get props => [name, mobile, areaCode, detail];
} 