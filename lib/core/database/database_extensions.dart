import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_price_summary.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_payment_info.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_shipping_info.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/address.dart';

import 'app_database.dart'; // Import the generated OrderCache class

// Extension to add mapping logic from Drift data classes to Domain entities
extension OrderCacheMapping on OrderCache {
  /// Maps the OrderCache data class to the Order domain entity.
  /// Note: This mapping is simplified as OrderCache only stores summary info.
  /// Details like items, full address, etc., are missing.
  Order toEntity() {
    return Order(
      id: id,
      orderSn: orderSn ?? '', // Provide default value
      state: OrderStatus.fromString(state), // Convert string state back to enum
      // --- Fields NOT available in OrderCache (use defaults or placeholders) ---
      orderType: 'normal', // Placeholder
      items: [
        // Create a placeholder OrderItem based on cached summary info
        OrderItem(
          id: 0, // Placeholder ID
          orderId: id,
          productId: 0, // Placeholder ID
          productName: firstItemName ?? 'N/A',
          skuId: 0, // Placeholder ID
          skuName: '', // Placeholder
          imageUrl: firstItemImage ?? '',
          quantity: 1, // Placeholder
          price: 0.0, // Placeholder
          totalPrice: 0.0, // Placeholder
        ),
      ],
      shippingAddress: Address.empty,
      priceSummary: OrderPriceSummary.fromTotalPriceString(totalPrice), // Keep static method call
      paymentInfo: OrderPaymentInfo.empty,
      shippingInfo: OrderShippingInfo.empty,
      createdAt: createdAt ?? DateTime.now(), // Provide default value
      // other fields like completeTime, cancelTime, buyerRemark etc. are missing
    );
  }
}

// Helper extension for OrderPriceSummary (if needed)
extension OrderPriceSummaryHelper on OrderPriceSummary {
  static OrderPriceSummary fromTotalPriceString(String? priceString) {
    final double price = double.tryParse(priceString ?? '') ?? 0.0;
    return OrderPriceSummary(
      totalPrice: price,
      discountPrice: 0.0, // Placeholder
      deliveryPrice: 0.0, // Placeholder
      payPrice: price, // Assume payPrice is same as totalPrice for summary
    );
  }
} 