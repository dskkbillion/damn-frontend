import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Import the injectable setup
import 'package:dskk_flutter_refactor/core/aftersale/repositories/i_aftersale_repository.dart';
import 'package:dskk_flutter_refactor/core/aftersale/repositories/mocks/mock_aftersale_repository.dart';
import 'package:dskk_flutter_refactor/core/auth/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/auth/repositories/mocks/mock_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/logistics/repositories/i_logistics_repository.dart';
import 'package:dskk_flutter_refactor/core/logistics/repositories/mocks/mock_logistics_repository.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/mocks/mock_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/mocks/mock_payment_service.dart';
import 'package:dskk_flutter_refactor/core/rating/repositories/i_rating_repository.dart';
import 'package:dskk_flutter_refactor/core/rating/repositories/mocks/mock_rating_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/data/repositories/mocks/mock_order_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/cancel_order_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/confirm_order_receipt_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/delete_order_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_detail_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_list_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/pages/order_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_theme.dart';
import 'package:dskk_flutter_refactor/core/router/app_router.dart';

// Remove GetIt instance creation here, rely on the one from injection_container.dart
// final sl = GetIt.instance;

/// Orders 模块的独立预览入口点。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Remove call to manual setup
  // await setupLocatorForPreview();

  // Keep ONLY the call to injectable setup
  await configureDependencies();

  // --- Override IOrderRepository with Mock for Preview ---
  // Allow GetIt to override the previous registration
  getIt.allowReassignment = true;
  getIt.registerLazySingleton<IOrderRepository>(() => MockOrderRepository(), dispose: null);

  print('[main_orders_preview] Overrode IOrderRepository with MockOrderRepository.');

  runApp(const OrdersPreviewApp());
}

class OrdersPreviewApp extends StatelessWidget {
  const OrdersPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderListBloc>(
          // Use getIt from the imported injection_container.dart
          create: (_) => getIt<OrderListBloc>()..add(const LoadOrders()),
        ),
        // TODO: Add BlocProvider for AfterSalesBloc if needed globally for preview?
        // Or provide it locally in pages like AfterSalesDetailPage
      ],
      child: MaterialApp.router(
        title: 'Orders Module Preview',
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme, // Optional dark theme
        // Use the main AppRouter configuration
        routeInformationProvider: AppRouter.router.routeInformationProvider,
        routeInformationParser: AppRouter.router.routeInformationParser,
        routerDelegate: AppRouter.router.routerDelegate,
        // routerConfig: _previewRouter, // OLD: Using local router
      ),
    );
  }
} 