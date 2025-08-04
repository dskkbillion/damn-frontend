import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Domain
import '../domain/repositories/i_exchange_rate_repository.dart';
import '../domain/services/currency_service.dart';

// Data
import '../data/repositories/exchange_rate_repository_impl.dart';
import '../data/datasources/exchange_rate_remote_data_source.dart';
import '../data/datasources/exchange_rate_local_data_source.dart';

// Presentation
import '../presentation/cubit/currency_cubit.dart';

/// 多币种模块依赖注入配置
class CurrencyDI {
  static Future<void> init(GetIt getIt) async {
    // Data Sources
    getIt.registerLazySingleton<IExchangeRateRemoteDataSource>(
      () => ExchangeRateRemoteDataSource(getIt<Dio>()),
    );
    
    getIt.registerLazySingleton<IExchangeRateLocalDataSource>(
      () => ExchangeRateLocalDataSource(getIt<SharedPreferences>()),
    );
    
    // Repository
    getIt.registerLazySingleton<IExchangeRateRepository>(
      () => ExchangeRateRepositoryImpl(
        getIt<IExchangeRateRemoteDataSource>(),
        getIt<IExchangeRateLocalDataSource>(),
        getIt<Connectivity>(),
      ),
    );
    
    // Domain Service
    getIt.registerLazySingleton<CurrencyService>(
      () => CurrencyService(getIt<IExchangeRateRepository>()),
    );
    
    // Presentation
    getIt.registerFactory<CurrencyCubit>(
      () => CurrencyCubit(getIt<CurrencyService>()),
    );
  }
  
  /// 注册核心依赖（如果还未注册）
  static Future<void> registerCoreDependencies(GetIt getIt) async {
    // Dio
    if (!getIt.isRegistered<Dio>()) {
      getIt.registerLazySingleton<Dio>(() {
        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 10);
        dio.options.receiveTimeout = const Duration(seconds: 10);
        return dio;
      });
    }
    
    // SharedPreferences
    if (!getIt.isRegistered<SharedPreferences>()) {
      final prefs = await SharedPreferences.getInstance();
      getIt.registerLazySingleton<SharedPreferences>(() => prefs);
    }
    
    // Connectivity
    if (!getIt.isRegistered<Connectivity>()) {
      getIt.registerLazySingleton<Connectivity>(() => Connectivity());
    }
  }
}