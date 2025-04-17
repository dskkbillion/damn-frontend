import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Import GetIt instance
import 'package:dskk_flutter_refactor/features/after_sales/presentation/bloc/after_sales_bloc.dart';
import '../../domain/entities/after_sales_application.dart'; // Import entity for list item

const int _defaultListPageSize = 10; // Define page size constant here

/// A page that displays a list of after-sales applications.
class AfterSalesListPage extends StatefulWidget {
  const AfterSalesListPage({super.key});

  @override
  State<AfterSalesListPage> createState() => _AfterSalesListPageState();
}

class _AfterSalesListPageState extends State<AfterSalesListPage> {

  @override
  void initState() {
    super.initState();
    // Initial load
    // Consider using context.read if Bloc is provided above, or handle creation/access
     // For simplicity, assuming it's accessible via context.read for now
     // This still requires a BlocProvider higher up.
    // context.read<AfterSalesBloc>().add(const LoadAfterSalesListRequested(pageSize: 10));
    // TODO: Ensure Bloc is provided before calling context.read
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('售后列表'),
        // TODO: Potentially add filter/search actions
      ),
      // Provide the Bloc if not already provided higher up
      // body: BlocProvider(
      //   create: (context) => getIt<AfterSalesBloc>()..add(const LoadAfterSalesListRequested(pageSize: 10)),
      body: BlocBuilder<AfterSalesBloc, AfterSalesState>(
        builder: (context, state) {
          // Handle Loading State
          if (state is AfterSalesListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle Error State
          if (state is AfterSalesListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: ${state.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                       context.read<AfterSalesBloc>().add(const LoadAfterSalesListRequested(pageSize: 10));
                    },
                    child: const Text('重试'),
                  ),
                ],
              )
            );
          }

          // Handle Loaded State
          if (state is AfterSalesListLoaded) {
             if (state.applications.isEmpty) {
                return const Center(child: Text('暂无售后申请记录'));
             }
            // TODO: Implement pagination/infinite scroll later
            return _buildApplicationsList(context, state.applications);
          }

          // Handle Initial State or other unhandled states
          return const Center(child: Text('请稍候...'));
        },
      ),
    );
  }

  // Helper method to build the list view
  Widget _buildApplicationsList(BuildContext context, List<AfterSalesApplication> applications) {
    // TODO: Add logic for pagination (hasReachedMax, bottom loader)
    return ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
           final application = applications[index];
           // TODO: Create a dedicated AfterSalesItemCard widget
           return ListTile(
              leading: application.productImage != null
                ? Image.network(application.productImage!, width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 50),
              title: Text(application.productName ?? '未知商品'),
              subtitle: Text('状态: ${application.refundStateText ?? application.refundState}\n申请时间: ${application.createTime?.toLocal()}'),
              trailing: Text('￥${application.refundPrice?.toStringAsFixed(2) ?? 'N/A'}'),
              isThreeLine: true,
              onTap: () {
                 // TODO: Navigate to AfterSalesDetailPage
                 // context.go('/afterSalesDetail/${application.id}');
                 print('Tapped on AfterSales application ID: ${application.id}');
              },
           );
        },
    );
  }
} 