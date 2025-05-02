import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/i_seller_statistics_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/seller_statistics_data_source_impl.dart';
import 'package:dskk_flutter_refactor/features/seller/data/repositories/seller_statistics_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_statistics_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_upgrade_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_index_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_percent_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_bloc.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';

/// 卖家数据统计模块依赖注入
class SellerStatisticsDI {
  /// 注册卖家数据统计模块的所有依赖
  static void init(GetIt sl) {
    // 数据源
    if (!sl.isRegistered<ISellerStatisticsDataSource>()) {
      sl.registerLazySingleton<ISellerStatisticsDataSource>(
        () => SellerStatisticsDataSourceImpl(sl()),
      );
    }
    
    // 仓库
    if (!sl.isRegistered<ISellerStatisticsRepository>()) {
      sl.registerLazySingleton<ISellerStatisticsRepository>(
        () => SellerStatisticsRepositoryImpl(
          sl<ISellerStatisticsDataSource>(),
          sl<NetworkInfo>(),
        ),
      );
    }
    
    // 用例
    if (!sl.isRegistered<GetSellerUpgradeStatisticsUseCase>()) {
      sl.registerLazySingleton(
        () => GetSellerUpgradeStatisticsUseCase(sl<ISellerStatisticsRepository>()),
      );
    }
    
    if (!sl.isRegistered<GetSellerIndexStatisticsUseCase>()) {
      sl.registerLazySingleton(
        () => GetSellerIndexStatisticsUseCase(sl<ISellerStatisticsRepository>()),
      );
    }
    
    if (!sl.isRegistered<GetSellerPercentStatisticsUseCase>()) {
      sl.registerLazySingleton(
        () => GetSellerPercentStatisticsUseCase(sl<ISellerStatisticsRepository>()),
      );
    }
    
    // Bloc
    if (!sl.isRegistered<SellerStatisticsBloc>()) {
      sl.registerFactory(
        () => SellerStatisticsBloc(
          sl<GetSellerUpgradeStatisticsUseCase>(),
          sl<GetSellerIndexStatisticsUseCase>(),
          sl<GetSellerPercentStatisticsUseCase>(),
        ),
      );
    }
  }
} 