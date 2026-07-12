
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/seller_page_skeleton.dart';
import 'package:dskk_flutter_refactor/core/widgets/loading_indicator.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/order_delivery/order_delivery_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/file_selection_widget.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

/// 订单交付页面
class OrderDeliveryPage extends StatelessWidget {
  /// 路由名称
  static const routeName = '/seller/orders/:id/delivery';

  /// 订单ID
  final int orderId;

  /// 订单编号（用于显示）
  final String? orderSn;

  /// 构造函数
  const OrderDeliveryPage({
    super.key, 
    required this.orderId,
    this.orderSn,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<OrderDeliveryBloc>()..add(InitOrderDelivery(orderId: orderId)),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(
              orderSn != null
                ? l10n.order_delivery_title_with_sn(orderSn!) ?? 'Order Delivery: $orderSn'
                : l10n.order_delivery_title ?? 'Order Delivery'
              ),
            ),
            body: const _OrderDeliveryForm(),
          );
        },
      ),
    );
  }
}

/// 订单交付表单组件
class _OrderDeliveryForm extends StatefulWidget {
  const _OrderDeliveryForm();

  @override
  _OrderDeliveryFormState createState() => _OrderDeliveryFormState();
}

class _OrderDeliveryFormState extends State<_OrderDeliveryForm> {
  final TextEditingController _contentController = TextEditingController();
  
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderDeliveryBloc, OrderDeliveryState>(
      listener: (context, state) {
        if (state is OrderDeliveryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is OrderDeliverySuccess) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.order_delivery_submit_success ?? 'Delivery content submitted successfully')),
          );
          Navigator.of(context).pop(true); // 返回true表示提交成功
        }
      },
      builder: (context, state) {
        if (state is OrderDeliveryInitial) {
          return const SellerPageSkeleton(variant: SellerSkeletonVariant.form);
        }
        
        if (state is OrderDeliveryFormState) {
          return _buildForm(context, state);
        }
        
        if (state is OrderDeliverySubmitting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoadingIndicator(),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).order_delivery_submitting ?? 'Submitting delivery content...'),
              ],
            ),
          );
        }
        
        final l10n = AppLocalizations.of(context);
        return Center(child: Text(l10n.order_delivery_load_failed ?? 'Load failed, please try again'));
      },
    );
  }
  
  /// 构建表单
  Widget _buildForm(BuildContext context, OrderDeliveryFormState state) {
    // 初始化文本控制器（仅在首次加载时）
    if (_contentController.text.isEmpty && state.content.isNotEmpty) {
      _contentController.text = state.content;
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 表单说明
          GlassCard(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(12),
            tintOpacity: 0.62,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).order_delivery_instruction_title ?? 'Delivery Instructions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).order_delivery_instruction_content ?? 'Please submit your delivery content for this order. You can provide detailed instructions and attach relevant files to ensure the buyer clearly understands the services or products you provide.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          
          // 交付内容输入
          Text(
            AppLocalizations.of(context).order_delivery_content_label ?? 'Delivery Content Description:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).order_delivery_content_hint ?? 'Please describe your delivery content...',
              border: const OutlineInputBorder(),
            ),
            maxLines: 5,
            onChanged: (value) {
              context.read<OrderDeliveryBloc>().add(ContentChanged(content: value));
            },
          ),
          
          const SizedBox(height: 24),
          
          // 文件上传
          Text(
            AppLocalizations.of(context).order_delivery_attachments_label ?? 'Attachment Files:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          FileSelectionWidget(
            selectedFiles: state.files,
            onFileSelected: (filePath) {
              context.read<OrderDeliveryBloc>().add(AddFile(filePath: filePath));
            },
            onFileRemoved: (index) {
              context.read<OrderDeliveryBloc>().add(RemoveFile(index: index));
            },
          ),
          
          const SizedBox(height: 32),
          
          // 提交按钮
          ElevatedButton(
            onPressed: () {
              // 验证表单
              if (_contentController.text.trim().isEmpty) {
                final l10n = AppLocalizations.of(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.order_delivery_content_required ?? 'Please enter delivery content description')),
                );
                return;
              }
              
              // 提交表单
              context.read<OrderDeliveryBloc>().add(SubmitOrderDelivery());
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.onPrimary,
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              AppLocalizations.of(context).order_delivery_submit_button ?? 'Submit Delivery',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
