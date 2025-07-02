import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 导入 BlocProvider
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/seller_home_page.dart'; // 修正包名
import 'package:dskk_flutter_refactor/features/seller/mocks/mock_seller_repository.dart'; // 更新路径到 lib 下
// 导入 Bloc, UseCases 和 Mock NavigationService
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_dashboard_data_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_store_profile_usecase.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/mocks/mock_navigation_service.dart';

// 导入统一主题
import 'package:dskk_flutter_refactor/core/config/theme/app_theme.dart';

// 实例化模拟仓库和导航服务
final mockSellerRepo = MockSellerRepository();
final mockNavigationService = MockNavigationService();

// 创建 UseCase 实例 (注入 Mock Repository)
final getDashboardDataUseCase = GetSellerDashboardDataUseCase(mockSellerRepo);
final getStoreProfileUseCase = GetStoreProfileUseCase(mockSellerRepo);

void main() {
  // TODO: 如果 SellerHomePage 使用了依赖注入 (如 get_it)，在这里设置模拟依赖
  // setupMockDependencies();
  runApp(const SellerHomePreviewApp());
}

class SellerHomePreviewApp extends StatelessWidget {
  const SellerHomePreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // 创建 SellerHomeBloc 实例并注入依赖
      create: (context) => SellerHomeBloc(
        getDashboardDataUseCase,
        getStoreProfileUseCase,
        mockNavigationService,
      ),
      child: MaterialApp(
        title: 'Seller Home Preview',
        theme: AppTheme.lightTheme,
        home: const SellerHomePage(), // 不再需要传递仓库
      ),
    );
  }
}

// 可选：设置模拟依赖注入的函数
// void setupMockDependencies() {
//   final getIt = GetIt.instance;
//   // 注册模拟仓库
//   if (!getIt.isRegistered<ISellerRepository>()) {
//      getIt.registerSingleton<ISellerRepository>(mockSellerRepo);
//   }
//   // TODO: 注册其他 SellerHomePage 可能需要的模拟仓库
//   // if (!getIt.isRegistered<IOrderRepository>()) {
//   //   getIt.registerSingleton<IOrderRepository>(MockOrderRepository());
//   // }
// } 