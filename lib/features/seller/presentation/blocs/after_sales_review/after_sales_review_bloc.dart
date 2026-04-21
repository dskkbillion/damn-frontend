import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/order_refund.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_tenant_audit_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/audit_refund_usecase.dart';

part 'after_sales_review_event.dart';
part 'after_sales_review_state.dart';

/// 售后审核Bloc
@injectable
class AfterSalesReviewBloc extends Bloc<AfterSalesReviewEvent, AfterSalesReviewState> {
  final GetTenantAuditListUseCase _getTenantAuditListUseCase;
  final AuditRefundUseCase _auditRefundUseCase;

  /// 构造函数
  AfterSalesReviewBloc(
    this._getTenantAuditListUseCase,
    this._auditRefundUseCase,
  ) : super(AfterSalesReviewInitial()) {
    on<LoadAfterSalesList>(_onLoadAfterSalesList);
    on<AuditAfterSalesRequest>(_onAuditAfterSalesRequest);
    on<ReloadAfterSalesList>(_onReloadAfterSalesList);
    on<LoadMoreAfterSalesList>(_onLoadMoreAfterSalesList);
  }

  /// 加载售后列表
  Future<void> _onLoadAfterSalesList(
    LoadAfterSalesList event,
    Emitter<AfterSalesReviewState> emit,
  ) async {
    emit(AfterSalesReviewLoading());
    
    final result = await _getTenantAuditListUseCase(const GetTenantAuditListParams(
      pageNum: 1,
      pageSize: 10,
    ));
    
    _emitListResult(result, emit, isFirstPage: true);
  }

  /// 审核售后申请
  Future<void> _onAuditAfterSalesRequest(
    AuditAfterSalesRequest event,
    Emitter<AfterSalesReviewState> emit,
  ) async {
    // 保存当前列表状态
    final currentState = state;
    if (currentState is AfterSalesReviewLoaded) {
      emit(AfterSalesReviewAuditing(
        refunds: currentState.refunds,
        hasMore: currentState.hasMore,
        currentPage: currentState.currentPage,
        auditingId: event.refundId,
      ));
      
      final result = await _auditRefundUseCase(AuditRefundParams(
        id: event.refundId,
        state: event.approved ? RefundAuditState.pass : RefundAuditState.reject,
        auditRemark: event.refusalReason,
      ));
      
      result.fold(
        (failure) => emit(AfterSalesReviewError(
          message: failure.message,
          refunds: currentState.refunds,
          hasMore: currentState.hasMore,
          currentPage: currentState.currentPage,
        )),
        (_) => add(ReloadAfterSalesList()),
      );
    }
  }

  /// 重新加载售后列表
  Future<void> _onReloadAfterSalesList(
    ReloadAfterSalesList event,
    Emitter<AfterSalesReviewState> emit,
  ) async {
    emit(AfterSalesReviewLoading());
    
    final result = await _getTenantAuditListUseCase(const GetTenantAuditListParams(
      pageNum: 1,
      pageSize: 10,
    ));
    
    _emitListResult(result, emit, isFirstPage: true);
  }

  /// 加载更多售后列表
  Future<void> _onLoadMoreAfterSalesList(
    LoadMoreAfterSalesList event,
    Emitter<AfterSalesReviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is AfterSalesReviewLoaded && currentState.hasMore) {
      emit(AfterSalesReviewLoadingMore(
        refunds: currentState.refunds,
        hasMore: currentState.hasMore,
        currentPage: currentState.currentPage,
      ));
      
      final nextPage = currentState.currentPage + 1;
      final result = await _getTenantAuditListUseCase(GetTenantAuditListParams(
        pageNum: nextPage,
        pageSize: 10,
      ));
      
      _emitListResult(result, emit, isFirstPage: false, currentRefunds: currentState.refunds, currentPage: nextPage - 1);
    }
  }

  /// 处理列表结果并触发相应状态
  void _emitListResult(
    Either<Failure, PaginatedList<OrderRefund>> result,
    Emitter<AfterSalesReviewState> emit, {
    required bool isFirstPage,
    List<OrderRefund> currentRefunds = const [],
    int currentPage = 0,
  }) {
    result.fold(
      (failure) => emit(AfterSalesReviewError(
        message: failure.message,
        refunds: isFirstPage ? [] : currentRefunds,
        hasMore: false,
        currentPage: currentPage,
      )),
      (paginatedList) {
        final refunds = paginatedList.items ?? [];
        final hasMore = (paginatedList.items.length ?? 0) >= 10;
        final newList = isFirstPage ? refunds : [...currentRefunds, ...refunds];
        
        if (newList.isEmpty) {
          emit(AfterSalesReviewEmpty());
        } else {
          emit(AfterSalesReviewLoaded(
            refunds: newList,
            hasMore: hasMore,
            currentPage: isFirstPage ? 1 : currentPage + 1,
          ));
        }
      },
    );
  }
} 