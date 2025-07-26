import 'package:bloc/bloc.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart'; // Import Failure
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_list_use_case.dart';
import 'package:equatable/equatable.dart' hide Order; // Import dartz (hide Order) and Equatable
import 'package:injectable/injectable.dart' hide Order; // Import & hide Order
import 'package:dartz/dartz.dart' hide Order; // Re-add dartz import
import 'package:stream_transform/stream_transform.dart'; // Import for debounce/throttle
import 'package:bloc_concurrency/bloc_concurrency.dart'; // Import for concurrency control

part 'order_list_state.dart'; // Declare the state file as a part

// Define a duration for throttling load more events
const throttleDuration = Duration(milliseconds: 100);

/// Transformer for throttling events.
EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

/// Manages the state for the Order List page.
@injectable
class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  final GetOrderListUseCase _getOrderListUseCase;
  final int _pageSize = 10; // Define page size
  int currentPage = 1; // Track current page
  OrderStatus? currentStatus; // Track current filter status
  String? currentSearchQuery; // Track current search query

  OrderListBloc({required GetOrderListUseCase getOrderListUseCase})
      : _getOrderListUseCase = getOrderListUseCase,
        super(OrderListInitial()) { // Initial state
    on<LoadOrders>(_onLoadOrders);
    // Use throttleDroppable to prevent spamming load more requests
    on<OrderListLoadMore>(
      _onOrderListLoadMore,
      transformer: throttleDroppable(throttleDuration),
    );
    on<SearchOrders>(_onSearchOrders);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderListState> emit) async {
    print('[OrderListBloc _onLoadOrders] Received event with status: ${event.status}');
    
    currentPage = 1; // Reset page for new filter/refresh
    currentStatus = event.status;
    emit(OrderListLoading()); // Indicate loading
    
    final params = GetOrderListParams(
      page: currentPage,
      limit: _pageSize,
      status: currentStatus == OrderStatus.unknown ? null : currentStatus,
      userRole: 'buyer', // Pass 'buyer' role
    );
    final Either<Failure, List<Order>> result = await _getOrderListUseCase(params);

    result.fold(
      (failure) => emit(OrderListError(message: 'Failed to load orders: ${failure.toString()}')),
      (orders) => emit(OrderListLoaded(
          orders: orders,
          // If the number of items loaded is less than page size, we've reached the max
          hasReachedMax: orders.length < _pageSize,
      )),
    );
  }

  Future<void> _onOrderListLoadMore(
      OrderListLoadMore event, Emitter<OrderListState> emit) async {
    // Check if the current state allows loading more (must be loaded and not already at max)
    if (state is OrderListLoaded && !(state as OrderListLoaded).hasReachedMax) {
      final currentState = state as OrderListLoaded;
      currentPage++; // Increment page number

      print('[OrderListBloc] Loading page $currentPage...');

      final params = GetOrderListParams(
        page: currentPage,
        limit: _pageSize,
        status: currentStatus == OrderStatus.unknown ? null : currentStatus,
        userRole: 'buyer', // Pass 'buyer' role
      );
      final Either<Failure, List<Order>> result = await _getOrderListUseCase(params);

      result.fold(
        (failure) {
           print('[OrderListBloc] Failed to load more orders: ${failure.toString()}');
           // Optionally emit an error state specific to load more, or keep current state
           // For simplicity, we keep the current state but might show a snackbar in UI
           // Revert page number if load failed?
           currentPage--; // Revert page increment on failure
        },
        (newOrders) {
          final bool newHasReachedMax = newOrders.length < _pageSize;
          emit(currentState.copyWith(
            orders: List.of(currentState.orders)..addAll(newOrders), // Append new orders
            hasReachedMax: newHasReachedMax, // Update hasReachedMax status
          ));
           print('[OrderListBloc] Loaded page $currentPage successfully. HasReachedMax: $newHasReachedMax');
        },
      );
    } else {
       print('[OrderListBloc] Cannot load more. State: ${state.runtimeType}, hasReachedMax: ${(state is OrderListLoaded ? (state as OrderListLoaded).hasReachedMax : 'N/A')}');
    }
  }
  
  Future<void> _onSearchOrders(SearchOrders event, Emitter<OrderListState> emit) async {
    print('[OrderListBloc _onSearchOrders] Search query: ${event.query}');
    
    currentPage = 1; // Reset page for new search
    currentSearchQuery = event.query.trim();
    emit(OrderListLoading()); // Indicate loading
    
    // If search query is empty, load all orders for current status
    if (currentSearchQuery?.isEmpty ?? true) {
      final params = GetOrderListParams(
        page: currentPage,
        limit: _pageSize,
        status: currentStatus == OrderStatus.unknown ? null : currentStatus,
        userRole: 'buyer',
      );
      
      final result = await _getOrderListUseCase(params);
      result.fold(
        (failure) => emit(OrderListError(message: failure.message)),
        (orders) => emit(OrderListLoaded(
          orders: orders,
          hasReachedMax: orders.length < _pageSize,
        )),
      );
      return;
    }
    
    // Perform search - filter by order number or product name
    // Note: This is a client-side search implementation
    // For production, you'd want to add server-side search support
    final params = GetOrderListParams(
      page: 1, // Load all for client-side filtering
      limit: 100, // Load more items for search
      status: currentStatus == OrderStatus.unknown ? null : currentStatus,
      userRole: 'buyer',
    );
    
    final result = await _getOrderListUseCase(params);
    result.fold(
      (failure) => emit(OrderListError(message: failure.message)),
      (allOrders) {
        // Client-side filtering
        final filteredOrders = allOrders.where((order) {
          final query = currentSearchQuery!.toLowerCase();
          // Search in order number
          if (order.orderSn.toLowerCase().contains(query)) return true;
          // Search in product names
          for (final item in order.items) {
            if (item.productName.toLowerCase().contains(query)) return true;
          }
          return false;
        }).toList();
        
        emit(OrderListLoaded(
          orders: filteredOrders,
          hasReachedMax: true, // No pagination for search results
        ));
      },
    );
  }
}

// --- Events ---
abstract class OrderListEvent extends Equatable {
  const OrderListEvent();
  @override
  List<Object?> get props => [];
}

/// Event to load the initial list of orders, potentially with a filter.
class LoadOrders extends OrderListEvent {
  final OrderStatus? status; // Optional status filter
  const LoadOrders({this.status});
    @override
  List<Object?> get props => [status];
}

/// Event to load the next page of orders.
class OrderListLoadMore extends OrderListEvent {}

/// Event to search orders by query
class SearchOrders extends OrderListEvent {
  final String query;
  const SearchOrders({required this.query});
  
  @override
  List<Object?> get props => [query];
} 