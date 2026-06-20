import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// Import GetIt instance
import 'package:dskk_flutter_refactor/features/after_sales/presentation/bloc/after_sales_bloc.dart';
import '../../domain/entities/after_sales_application.dart'; // Import entity for list item
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';

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
    // #399: 触发首屏加载。Bloc 由 /afterSales 路由的 BlocProvider 注入，此处可安全 read。
    context
        .read<AfterSalesBloc>()
        .add(const LoadAfterSalesListRequested(pageSize: _defaultListPageSize));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).after_sales_list_title),
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
                  Text(AppLocalizations.of(context).after_sales_list_load_failed(state.errorMessage ?? '')),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                       context.read<AfterSalesBloc>().add(const LoadAfterSalesListRequested(pageSize: 10));
                    },
                    child: Text(AppLocalizations.of(context).retry),
                  ),
                ],
              )
            );
          }

          // Handle Loaded State
          if (state is AfterSalesListLoaded) {
             if (state.applications.isEmpty) {
                return Center(child: Text(AppLocalizations.of(context).after_sales_list_empty));
             }
            // TODO: Implement pagination/infinite scroll later
            return _buildApplicationsList(context, state.applications);
          }

          // Handle Initial State or other unhandled states
          return Center(child: Text(AppLocalizations.of(context).after_sales_list_loading));
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
                ? AppNetworkImage(imageUrl: application.productImage!, width: 50, height: 50)
                : const Icon(Icons.image, size: 50),
              title: Text(application.productName ?? AppLocalizations.of(context).after_sales_list_unknown_product),
              subtitle: Text('${AppLocalizations.of(context).after_sales_list_status(application.refundStateText ?? application.refundState)}\n${AppLocalizations.of(context).after_sales_list_apply_time(application.createTime?.toLocal().toString() ?? '-')}'),
              trailing: Text(application.refundPrice != null ? RegionConfig.formatPrice(application.refundPrice!) : 'N/A'),
              isThreeLine: true,
              onTap: () {
                 // #399: 详情页路由 :id 期望 order.id（详情页用 LoadAfterSalesDetailByOrderId 反查），
                 // 不是 refund.id。历史注释代码传 application.id 是错的。
                 context.push('/afterSalesDetail/${application.orderId}');
              },
           );
        },
    );
  }
} 