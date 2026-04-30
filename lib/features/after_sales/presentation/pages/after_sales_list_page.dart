import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import GetIt instance
import 'package:dskk_flutter_refactor/features/after_sales/presentation/bloc/after_sales_bloc.dart';
import '../../domain/entities/after_sales_application.dart'; // Import entity for list item
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
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