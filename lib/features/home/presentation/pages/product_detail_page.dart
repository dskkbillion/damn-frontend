import 'package:flutter/material.dart';

/// Placeholder page for Product Details.
class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
      ),
      body: Center(
        child: Text('Product Detail Page for ID: $productId'),
      ),
    );
  }
} 