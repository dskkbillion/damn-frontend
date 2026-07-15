import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// Import GetIt instance
import 'package:dskk_flutter_refactor/features/after_sales/presentation/bloc/after_sales_bloc.dart';
import '../../domain/entities/after_sales_application.dart'; // Import entity for list item
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

const int _defaultListPageSize = 10; // Define page size constant here

/// A page that displays a list of after-sales applications.
class AfterSalesListPage extends StatefulWidget {
  const AfterSalesListPage({super.key});

  @override
  State<AfterSalesListPage> createState() => _AfterSalesListPageState();
}

class _AfterSalesListPageState extends State<AfterSalesListPage> {

  String _localizeRefundState(BuildContext context, String state) {
    final s = AppLocalizations.of(context);
    switch (state.trim().toUpperCase()) {
      case 'WAIT_AUDIT':
        return s.after_sales_status_wait_audit;
      case 'AUDIT_PASS':
        return s.after_sales_status_audit_pass;
      case 'AUDIT_REFUSED':
        return s.after_sales_status_refused;
      case 'CANCEL':
      case 'CANCELED':
        return s.after_sales_status_canceled;
      default:
        return s.after_sales_status_unknown;
    }
  }

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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: GlassCard(
                        padding: const EdgeInsets.all(40.0),
                        borderRadius: BorderRadius.circular(12.0),
                        tintOpacity: 0.62,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).after_sales_list_empty,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                    ),
                  ),
                );
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // TODO: Add logic for pagination (hasReachedMax, bottom loader)
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: applications.length,
        itemBuilder: (context, index) {
           final application = applications[index];
           return GlassCard(
             margin: const EdgeInsets.symmetric(vertical: 8.0),
             padding: EdgeInsets.zero,
             borderRadius: BorderRadius.circular(12.0),
             tintOpacity: 0.62,
             child: InkWell(
               borderRadius: BorderRadius.circular(12.0),
               onTap: () {
                 // #399: 详情页路由 :id 期望 order.id（详情页用 LoadAfterSalesDetailByOrderId 反查），
                 // 不是 refund.id。历史注释代码传 application.id 是错的。
                 context.push('/afterSalesDetail/${application.orderId}');
               },
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // 商品图片
                     ClipRRect(
                       borderRadius: BorderRadius.circular(8.0),
                       child: application.productImage != null
                         ? AppNetworkImage(
                             imageUrl: application.productImage!,
                             width: 64,
                             height: 64,
                             fit: BoxFit.cover,
                           )
                         : Container(
                             width: 64,
                             height: 64,
                             color: colorScheme.surfaceContainerHighest,
                             child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                           ),
                     ),
                     const SizedBox(width: 12),
                     // 文字信息
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             application.productName ?? AppLocalizations.of(context).after_sales_list_unknown_product,
                             style: textTheme.titleSmall,
                             maxLines: 2,
                             overflow: TextOverflow.ellipsis,
                           ),
                           const SizedBox(height: 6),
                           Text(
                             AppLocalizations.of(context).after_sales_list_status(_localizeRefundState(context, application.refundState)),
                             style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                           ),
                           const SizedBox(height: 2),
                           Text(
                             AppLocalizations.of(context).after_sales_list_apply_time(application.createTime?.toLocal().toString() ?? '-'),
                             style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                           ),
                         ],
                       ),
                     ),
                     // 退款金额
                     Text(
                       application.refundPrice != null ? RegionConfig.formatPrice(application.refundPrice!) : 'N/A',
                       style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                     ),
                   ],
                 ),
               ),
             ),
           );
        },
    );
  }
}
