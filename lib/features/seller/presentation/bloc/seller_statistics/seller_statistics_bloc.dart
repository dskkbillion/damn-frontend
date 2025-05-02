import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_upgrade_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_index_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_percent_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_state.dart';

/// 卖家统计模块Bloc
@injectable
class SellerStatisticsBloc extends Bloc<SellerStatisticsEvent, SellerStatisticsState> {
  final GetSellerUpgradeStatisticsUseCase getUpgradeStatistics;
  final GetSellerIndexStatisticsUseCase getIndexStatistics;
  final GetSellerPercentStatisticsUseCase getPercentStatistics;
  
  /// 构造函数，注入用例
  SellerStatisticsBloc(
    this.getUpgradeStatistics,
    this.getIndexStatistics,
    this.getPercentStatistics,
  ) : super(const SellerStatisticsInitial()) {
    on<LoadSellerStatistics>(_onLoadStatistics);
    on<RefreshSellerStatistics>(_onRefreshStatistics);
  }
  
  /// 处理加载统计数据事件
  Future<void> _onLoadStatistics(
    LoadSellerStatistics event,
    Emitter<SellerStatisticsState> emit,
  ) async {
    emit(const SellerStatisticsLoading());
    await _loadStatistics(emit);
  }
  
  /// 处理刷新统计数据事件
  Future<void> _onRefreshStatistics(
    RefreshSellerStatistics event,
    Emitter<SellerStatisticsState> emit,
  ) async {
    emit(const SellerStatisticsLoading());
    await _loadStatistics(emit);
  }
  
  /// 加载统计数据
  Future<void> _loadStatistics(Emitter<SellerStatisticsState> emit) async {
    // 并行获取所有数据
    final upgradeResult = await getUpgradeStatistics(NoParams());
    final indexResult = await getIndexStatistics(NoParams());
    final percentResult = await getPercentStatistics(NoParams());
    
    // 如果有任何一个请求失败，则返回错误
    if (upgradeResult.isLeft() || indexResult.isLeft() || percentResult.isLeft()) {
      upgradeResult.fold(
        (failure) => emit(SellerStatisticsError(failure: failure)),
        (_) => indexResult.fold(
          (failure) => emit(SellerStatisticsError(failure: failure)),
          (_) => percentResult.fold(
            (failure) => emit(SellerStatisticsError(failure: failure)),
            (_) {}, // 不应该到达这里
          ),
        ),
      );
      return;
    }
    
    // 所有请求成功，提取数据
    upgradeResult.fold(
      (_) {}, // 不应该到达这里
      (upgradeStats) => indexResult.fold(
        (_) {}, // 不应该到达这里
        (indexStats) => percentResult.fold(
          (_) {}, // 不应该到达这里
          (percentStats) => emit(SellerStatisticsLoaded(
            upgradeStats: upgradeStats,
            indexStats: indexStats,
            percentStats: percentStats,
          )),
        ),
      ),
    );
  }
} 