import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_detail_use_case.dart';
// TODO: Import seller action UseCases later

part 'seller_order_detail_event.dart';
part 'seller_order_detail_state.dart';

@injectable
class SellerOrderDetailBloc extends Bloc<SellerOrderDetailEvent, SellerOrderDetailState> {
  final GetOrderDetailUseCase _getOrderDetailUseCase;
  // TODO: Inject seller action UseCases later
  // final ConfirmOrderAcceptanceUseCase _confirmOrderAcceptanceUseCase;
  // final RejectOrderUseCase _rejectOrderUseCase;
  // ...

  SellerOrderDetailBloc(
    this._getOrderDetailUseCase,
    // TODO: Add other use cases to constructor
  ) : super(SellerOrderDetailInitial()) {
    on<LoadSellerOrderDetail>(_onLoadSellerOrderDetail);
    // TODO: Register handlers for seller actions later
  }

  Future<void> _onLoadSellerOrderDetail(
    LoadSellerOrderDetail event,
    Emitter<SellerOrderDetailState> emit,
  ) async {
    emit(SellerOrderDetailLoading(loadingOrderId: event.orderId));
    final result = await _getOrderDetailUseCase(event.orderId);
    result.fold(
      (failure) => emit(SellerOrderDetailLoadFailure(
        failedOrderId: event.orderId,
        message: failure.toString(), // Or provide a more user-friendly message
      )),
      (order) => emit(SellerOrderDetailLoadSuccess(order: order)),
    );
  }

  // TODO: Implement handlers for seller actions later
  // Future<void> _onConfirmAcceptanceRequested(...) async { ... }
  // Future<void> _onRejectRequested(...) async { ... }
  // ...
}
