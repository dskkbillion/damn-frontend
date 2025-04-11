import 'package:equatable/equatable.dart';

/// Represents the core data of an after-sales (refund) application.
/// Maps to the `OrderRefund` object from the backend API.
class AfterSalesApplication extends Equatable {
  final int id;
  final int? buyerId;
  final int? tenantId;
  final int orderId;
  final int orderItemId;
  final int? productId;
  final int? variantId;
  final String? productName;
  final String? variantName;
  final String? productImage;
  final String? refundSn;
  final String refundType; // e.g., "ONLY_MONEY", "MONEY_AND_PRODUCT"
  final String? refundReason;
  final String? refundExplain;
  final List<String>? refundImage; // List of image URLs
  final int? refundNumber; // Quantity for return
  final double? refundPrice;
  final String refundState; // e.g., "WAIT_AUDIT", "AUDIT_PASS", etc.
  final String? finalState; // e.g., "IN_PROGRESS", "PASS", etc.
  final String? refundAddress; // Return address provided by seller
  final String? auditRemark; // Audit notes / rejection reason
  final DateTime? auditTime;
  final DateTime? shipTime; // Buyer's shipping time for returns
  final DateTime? confirmTime; // Seller's confirmation time for returns
  final DateTime? cancelTime;
  final String? memberType; // "buyer" or "seller"
  final String? auditType; // "platform" or "seller"
  final String? refundStateText; // Display text for state
  final String? refundTypeText; // Display text for type
  final DateTime? createTime;
  final DateTime? updateTime;
  // TODO: Potentially add associated Order or OrderItem objects if needed later

  const AfterSalesApplication({
    required this.id,
    this.buyerId,
    this.tenantId,
    required this.orderId,
    required this.orderItemId,
    this.productId,
    this.variantId,
    this.productName,
    this.variantName,
    this.productImage,
    this.refundSn,
    required this.refundType,
    this.refundReason,
    this.refundExplain,
    this.refundImage,
    this.refundNumber,
    this.refundPrice,
    required this.refundState,
    this.finalState,
    this.refundAddress,
    this.auditRemark,
    this.auditTime,
    this.shipTime,
    this.confirmTime,
    this.cancelTime,
    this.memberType,
    this.auditType,
    this.refundStateText,
    this.refundTypeText,
    this.createTime,
    this.updateTime,
  });

  // Helper factory for creating from JSON (implementation will be in data layer)
  // factory AfterSalesApplication.fromJson(Map<String, dynamic> json) { ... }

  // Helper method for converting to JSON (implementation will be in data layer)
  // Map<String, dynamic> toJson() { ... }


  @override
  List<Object?> get props => [
        id,
        buyerId,
        tenantId,
        orderId,
        orderItemId,
        productId,
        variantId,
        productName,
        variantName,
        productImage,
        refundSn,
        refundType,
        refundReason,
        refundExplain,
        refundImage,
        refundNumber,
        refundPrice,
        refundState,
        finalState,
        refundAddress,
        auditRemark,
        auditTime,
        shipTime,
        confirmTime,
        cancelTime,
        memberType,
        auditType,
        refundStateText,
        refundTypeText,
        createTime,
        updateTime,
      ];
} 