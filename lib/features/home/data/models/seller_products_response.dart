import 'package:dskk_flutter_refactor/features/home/domain/entities/seller_product.dart';

class SellerProductsResponse {
  final int total;
  final List<SellerProduct> products;

  SellerProductsResponse({
    required this.total,
    required this.products,
  });

  factory SellerProductsResponse.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'] as List<dynamic>;
    return SellerProductsResponse(
      total: json['total'] ?? 0,
      products: rows.map((product) => SellerProduct.fromJson(product)).toList(),
    );
  }
} 