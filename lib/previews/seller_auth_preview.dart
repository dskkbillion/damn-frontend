import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 导入页面和 Bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/auth_management/auth_management_bloc.dart';

// 导入 Mock 依赖和 UseCases
import 'package:dskk_flutter_refactor/features/seller/mocks/mock_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_authentication_status_usecase.dart';

// 实例化模拟仓库
final mockSellerRepo = MockSellerRepository();

// 创建 UseCase 实例
final getAuthStatusUseCase = GetSellerAuthenticationStatusUseCase(mockSellerRepo);

// !!! 直接创建 BLoC 实例 !!!
final authManagementBlocInstance = AuthManagementBloc(getAuthStatusUseCase);

void main() {
  runApp(const SellerAuthPreviewApp());
}

class SellerAuthPreviewApp extends StatelessWidget {
  const SellerAuthPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Management Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // TODO: 引入项目主题
      ),
      home: Builder(
        builder: (materialAppContext) {
          // !!! 使用 BlocProvider.value 提供已创建的实例 !!!
          return BlocProvider.value(
            value: authManagementBlocInstance, // 传入已存在的 BLoC 实例
            child: const AuthManagementPage(),
          );
        },
      ),
    );
  }
} 
 