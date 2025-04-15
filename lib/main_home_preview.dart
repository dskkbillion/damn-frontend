import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/error/failures.dart';
import 'features/home/di/home_preview_di.dart';
import 'features/home/domain/usecases/get_home_feed_usecase.dart';
import 'features/home/domain/usecases/get_home_page_data_usecase.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/navigation/home_navigation_service.dart';
import 'features/home/presentation/navigation/home_preview_router.dart';
import 'features/home/presentation/pages/home_page.dart';

/// 获取依赖注入实例
final sl = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化依赖注入
  await initHomePreviewDi();
  
  runApp(const HomePreviewApp());
}

/// Home 模块预览应用
class HomePreviewApp extends StatelessWidget {
  const HomePreviewApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Home Module Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      routerConfig: HomePreviewRouter.router,
      builder: (context, child) {
        return BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(
            getHomePageData: sl<GetHomePageDataUseCase>(),
            getHomeFeed: sl<GetHomeFeedUseCase>(),
            navigationService: sl<HomeNavigationService>(),
          ),
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              // 添加一个信息按钮在右上角
              Positioned(
                top: 40,
                right: 10,
                child: InfoButton(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 信息按钮组件
class InfoButton extends StatelessWidget {
  const InfoButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: () {
        _showInfoDialog(context);
      },
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.7),
        shape: const CircleBorder(),
      ),
    );
  }

  /// 显示信息对话框
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Home 模块预览'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('这是 Home 模块的预览版本，使用了模拟数据。'),
              SizedBox(height: 8),
              Text('功能说明:'),
              SizedBox(height: 4),
              Text('• 顶部搜索框可以搜索服务'),
              Text('• 下拉刷新首页数据'),
              Text('• 上拉加载更多信息流'),
              Text('• 点击轮播图和商品卡片可以导航到相应页面'),
              Text('• 点击"让ta看看"按钮显示确认对话框'),
              SizedBox(height: 8),
              Text('注意: 模拟数据源有 10% 的概率会随机抛出错误，用于测试错误处理。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('关闭'),
          ),
        ],
      ),
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