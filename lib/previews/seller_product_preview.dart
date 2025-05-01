import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 导入页面和 Bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/product_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_management/product_management_bloc.dart';

// 导入 Mock 依赖和 UseCases
import 'package:dskk_flutter_refactor/features/seller/mocks/mock_seller_repository.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/mocks/mock_navigation_service.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_product_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_draft_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_product_status_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/delete_product_usecase.dart';

// 实例化模拟服务和仓库
final mockSellerRepo = MockSellerRepository();
final mockNavigationService = MockNavigationService();

// 创建 UseCase 实例 (注入 Mock Repository)
final getSellerProductListUseCase = GetSellerProductListUseCase(mockSellerRepo);
final getSellerDraftListUseCase = GetSellerDraftListUseCase(mockSellerRepo);
final updateProductStatusUseCase = UpdateProductStatusUseCase(mockSellerRepo);
final deleteProductUseCase = DeleteProductUseCase(mockSellerRepo);

void main() {
  runApp(const SellerProductPreviewApp());
}

class SellerProductPreviewApp extends StatelessWidget {
  const SellerProductPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductManagementBloc(
        getSellerProductListUseCase,
        getSellerDraftListUseCase,
        updateProductStatusUseCase,
        deleteProductUseCase,
        mockNavigationService,
      ),
      child: MaterialApp(
        title: 'Product Management Preview',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // TODO: 引入项目主题
        ),
        home: const ProductManagementPage(),
      ),
    );
  }
} 