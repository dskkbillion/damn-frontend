part of 'after_sales_bloc.dart'; // Restore part-of
// import 'package:equatable/equatable.dart'; // Remove import

abstract class AfterSalesEvent extends Equatable {
  const AfterSalesEvent();

  @override
  List<Object?> get props => [];
}

// Event to load the list of after-sales applications
class LoadAfterSalesListRequested extends AfterSalesEvent {
  final int page;
  final int pageSize;
  final String? statusFilter; // Optional filter by status

  const LoadAfterSalesListRequested({
    this.page = 1, // Default to first page
    required this.pageSize,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [page, pageSize, statusFilter];
}

// Event triggered when user submits the application form
class ApplyForAfterSalesSubmitted extends AfterSalesEvent {
  final int orderItemId;
  final String refundType;
  final String refundReason;
  final String refundExplain;
  final List<String>? imagePaths; // Paths of images selected by user
  final double? refundAmount; // ADDED: Requested refund amount (optional)

  const ApplyForAfterSalesSubmitted({
    required this.orderItemId,
    required this.refundType,
    required this.refundReason,
    required this.refundExplain,
    this.imagePaths,
    this.refundAmount, // ADDED to constructor
  });

   @override
  List<Object?> get props => [
        orderItemId,
        refundType,
        refundReason,
        refundExplain,
        imagePaths,
        refundAmount, // ADDED to props
      ];
}

// Event to cancel an application
class CancelAfterSalesRequested extends AfterSalesEvent {
  final int refundId;

  const CancelAfterSalesRequested(this.refundId);

   @override
  List<Object?> get props => [refundId];
}

// Event to delete application records (though UI might not directly expose this)
class DeleteAfterSalesRequested extends AfterSalesEvent {
  final List<int> refundIds;

  const DeleteAfterSalesRequested(this.refundIds);

   @override
  List<Object?> get props => [refundIds];
}

// Event to load the details of a specific after-sales application
class LoadAfterSalesDetail extends AfterSalesEvent {
  final String id; // ID passed from the page (likely orderId or refundId as string)

  const LoadAfterSalesDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

// Event to load after-sales detail by order ID (frontend will resolve refund ID)
class LoadAfterSalesDetailByOrderId extends AfterSalesEvent {
  final int orderId; // Order ID to find the corresponding after-sales record

  const LoadAfterSalesDetailByOrderId({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

// TODO: Add events for uploading images if needed as a separate step 