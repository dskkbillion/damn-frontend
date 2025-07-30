import 'package:get_it/get_it.dart';
import '../presentation/bloc/after_sales_bloc.dart';
import '../domain/usecases/get_after_sales_list_use_case.dart';
import '../domain/usecases/get_after_sales_detail_use_case.dart';
import '../domain/usecases/apply_for_after_sales_use_case.dart';
import '../domain/usecases/cancel_after_sales_use_case.dart';
import '../domain/usecases/delete_after_sales_use_case.dart';
import '../domain/usecases/get_refund_id_by_order_id_use_case.dart';
import '../domain/repositories/i_after_sales_repository.dart';
import '../data/repositories/after_sales_repository_impl.dart';
import '../data/datasources/i_after_sales_remote_data_source.dart';
import '../data/datasources/after_sales_remote_data_source.dart';

/// 售后模块依赖注入配置
class AfterSalesDI {
  static Future<void> init(GetIt getIt) async {
    // 注册数据源
    getIt.registerLazySingleton<IAfterSalesRemoteDataSource>(
      () => AfterSalesRemoteDataSource(getIt()),
    );

    // 注册仓库
    getIt.registerLazySingleton<IAfterSalesRepository>(
      () => AfterSalesRepositoryImpl(
        remoteDataSource: getIt<IAfterSalesRemoteDataSource>(),
      ),
    );

    // 注册用例
    getIt.registerLazySingleton<GetAfterSalesListUseCase>(
      () => GetAfterSalesListUseCase(getIt()),
    );

    getIt.registerLazySingleton<GetAfterSalesDetailUseCase>(
      () => GetAfterSalesDetailUseCase(getIt()),
    );

    getIt.registerLazySingleton<ApplyForAfterSalesUseCase>(
      () => ApplyForAfterSalesUseCase(getIt()),
    );

    getIt.registerLazySingleton<CancelAfterSalesUseCase>(
      () => CancelAfterSalesUseCase(getIt()),
    );

    getIt.registerLazySingleton<DeleteAfterSalesUseCase>(
      () => DeleteAfterSalesUseCase(getIt()),
    );

    getIt.registerLazySingleton<GetRefundIdByOrderIdUseCase>(
      () => GetRefundIdByOrderIdUseCase(getIt()),
    );

    // 注册BLoC
    getIt.registerFactory<AfterSalesBloc>(
      () => AfterSalesBloc(
        getIt<GetAfterSalesListUseCase>(),
        getIt<GetAfterSalesDetailUseCase>(),
        getIt<ApplyForAfterSalesUseCase>(),
        getIt<CancelAfterSalesUseCase>(),
        getIt<DeleteAfterSalesUseCase>(),
        getIt<GetRefundIdByOrderIdUseCase>(),
      ),
    );

    print('[AfterSalesDI] 售后模块依赖注入配置完成');
  }
}