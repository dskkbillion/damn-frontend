import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 导入页面和 Bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/after_sales_review_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/after_sales_review/after_sales_review_bloc.dart';

// 导入统一主题
import 'package:dskk_flutter_refactor/core/config/theme/app_theme.dart';

// 导入 Mock 依赖和 UseCases
import 'package:dskk_flutter_refactor/features/seller/mocks/mock_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_tenant_audit_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/audit_refund_usecase.dart';

// 实例化模拟仓库
final mockSellerRepo = MockSellerRepository();

// 创建 UseCase 实例
final getTenantAuditListUseCase = GetTenantAuditListUseCase(mockSellerRepo);
final auditRefundUseCase = AuditRefundUseCase(mockSellerRepo);

void main() {
  runApp(const SellerAfterSalesPreviewApp());
}

class SellerAfterSalesPreviewApp extends StatelessWidget {
  const SellerAfterSalesPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AfterSalesReviewBloc(
        getTenantAuditListUseCase,
        auditRefundUseCase,
      ),
      child: MaterialApp(
        title: 'After-Sales Review Preview',
        theme: AppTheme.lightTheme,
        home: const AfterSalesReviewPage(),
      ),
    );
  }
} 