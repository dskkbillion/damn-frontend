import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../core/error/failures.dart';
import '../../core/storage/secure_storage_repository.dart';
import '../../core/storage/secure_storage_repository_impl.dart';
import '../../features/home/di/home_di.dart';
import '../../features/home/domain/usecases/get_home_feed_usecase.dart';
import '../../features/home/domain/usecases/get_home_page_data_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/navigation/home_navigation_service.dart';
import '../../features/home/presentation/navigation/home_router.dart';

// 导入统一主题
import '../../core/config/theme/app_theme.dart';

/// 获取依赖注入实例
final sl = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 加载环境变量 - Use default assets loading
  await dotenv.load();
  
  // 初始化安全存储
  final secureStorage = const FlutterSecureStorage();
  final secureStorageRepository = SecureStorageRepositoryImpl(secureStorage);
  sl.registerLazySingleton<ISecureStorageRepository>(() => secureStorageRepository);
  
  // 初始化依赖注入
  await initHomeDi();
  
  runApp(const HomeApp());
}

/// Home 模块应用
class HomeApp extends StatelessWidget {
  const HomeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Home Module',
      theme: AppTheme.lightTheme,
      routerConfig: HomeRouter.router,
      builder: (context, child) {
        return BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(
            getHomePageData: sl<GetHomePageDataUseCase>(),
            getHomeFeed: sl<GetHomeFeedUseCase>(),
            navigationService: sl<HomeNavigationService>(),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// 全局错误处理
class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('Bloc Error: $error');
    print('Stack Trace: $stackTrace');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    print('Bloc Change: $change');
    super.onChange(bloc, change);
  }
}

/// 将 Failure 映射为错误消息
String mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return (failure as ServerFailure).message ?? '服务器错误';
    case CacheFailure:
      return '缓存错误';
    default:
      return '未知错误';
  }
}