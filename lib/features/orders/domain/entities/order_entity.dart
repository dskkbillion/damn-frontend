import 'package:equatable/equatable.dart';

// Define basic order status enum (adjust as needed)
enum OrderStatus { pending, processing, shipped, delivered, cancelled, completed }

/// Represents a basic order entity in the domain layer.
/// Fields should be added based on actual API response or requirements.
class OrderEntity extends Equatable {
  final int id; // Assuming order ID is an int
  final String orderSn; // Order serial number
  final OrderStatus status; // Order status
  final double totalAmount; // Example: Total price
  final DateTime createdAt; // Example: Creation date
  // Add other relevant fields like items, shipping address, user info etc.

  const OrderEntity({
    required this.id,
    required this.orderSn,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    // Initialize other fields
  });

  @override
  List<Object?> get props => [
        id,
        orderSn,
        status,
        totalAmount,
        createdAt,
        // Add other fields to props
      ];
} 