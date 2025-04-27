import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 导入页面和 Bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/time_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/time_management/time_management_bloc.dart';

// 导入 Mock 依赖和 UseCases
import 'package:dskk_flutter_refactor/features/seller/mocks/mock_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_time_settings_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_time_settings_usecase.dart';

// 实例化模拟仓库
final mockSellerRepo = MockSellerRepository();

// 创建 UseCase 实例
final getTimeSettingsUseCase = GetTimeSettingsUseCase(mockSellerRepo);
final updateTimeSettingsUseCase = UpdateTimeSettingsUseCase(mockSellerRepo);

void main() {
  runApp(const SellerTimePreviewApp());
}

class SellerTimePreviewApp extends StatelessWidget {
  const SellerTimePreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimeManagementBloc(
        getTimeSettingsUseCase,
        updateTimeSettingsUseCase,
      ),
      child: MaterialApp(
        title: 'Time Management Preview',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // TODO: 引入项目主题
        ),
        home: const TimeManagementPage(),
      ),
    );
  }
} 