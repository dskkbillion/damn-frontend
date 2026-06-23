import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_materials.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_delivery.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_requirement_submission_form.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 订单操作相关的对话框集合
class OrderActionDialogs {
  final Order order;
  
  const OrderActionDialogs({required this.order});

  // --- Helper function for confirmation dialog ---
  Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).order_dialog_cancel),
              onPressed: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).order_dialog_confirm),
              onPressed: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Helper function for delivery dialog ---
  Future<void> showDeliveryDialog(BuildContext context) async {
    // Get the current state from BLoC before showing dialog
    final state = context.read<OrderDetailBloc>().state;
    if (state is! OrderDetailLoaded) {
      // Show error if state is not loaded
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).order_dialog_data_not_loaded)),
      );
      return;
    }
    
    final deliveries = state.deliveries;
    final materials = state.materials;
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).order_dialog_view_delivery_title),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).order_dialog_seller_delivery_content),
                  const SizedBox(height: 16),
                  _buildDeliveryDialogContent(context, deliveries),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context).order_dialog_buyer_materials),
                  const SizedBox(height: 8),
                  _buildMaterialsDialogContent(context, materials),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).order_dialog_close),
              onPressed: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // --- Helper function for platform intervention dialog ---
  Future<void> showPlatformInterventionDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String selectedReasonType = 'communication';
    
    final l10n = AppLocalizations.of(context);
    final Map<String, String> reasonTypes = {
      'communication': l10n.order_intervention_reason_communication,
      'quality': l10n.order_intervention_reason_quality,
      'delivery': l10n.order_intervention_reason_delivery,
      'refund': l10n.order_intervention_reason_refund,
      'service': l10n.order_intervention_reason_service,
      'other': l10n.order_intervention_reason_other,
    };

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.order_intervention_title),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.order_intervention_desc),
                      const SizedBox(height: 16),
                      Text(l10n.order_intervention_problem_type, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedReasonType,
                        items: reasonTypes.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedReasonType = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.order_intervention_problem_desc, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: reasonController,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: InputDecoration(
                          hintText: l10n.order_intervention_problem_hint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.order_intervention_validation_empty;
                          }
                          if (value.trim().length < 10) {
                            return l10n.order_intervention_validation_min;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Text(
                          l10n.order_intervention_tip,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(l10n.order_dialog_cancel),
                  onPressed: () => Navigator.of(dialogContext).canPop() ? Navigator.of(dialogContext).pop() : null,
                ),
                ElevatedButton(
                  child: Text(l10n.order_dialog_submit),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext).canPop() ? Navigator.of(dialogContext).pop() : null;
                      _submitPlatformIntervention(
                        context,
                        selectedReasonType,
                        reasonTypes[selectedReasonType]!,
                        reasonController.text.trim(),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Helper function for order demand dialog ---
  Future<void> showOrderDemandDialog(BuildContext context, String demandType) async {
    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String selectedReasonValue = '';

    // Save the outer context reference
    final outerContext = context;
    final l10n = AppLocalizations.of(context);

    // Define reasons based on demand type
    final Map<String, Map<String, String>> demandReasons = {
      'replenishment': {
        'incomplete': l10n.order_demand_reason_incomplete,
        'unclear': l10n.order_demand_reason_unclear,
        'additional': l10n.order_demand_reason_additional,
        'reference': l10n.order_demand_reason_reference,
        'other': l10n.order_demand_reason_other,
      },
      'reform': {
        'quality': l10n.order_demand_reason_quality,
        'requirement': l10n.order_demand_reason_requirement,
        'incomplete': l10n.order_demand_reason_content_incomplete,
        'error': l10n.order_demand_reason_error,
        'other': l10n.order_demand_reason_other,
      },
    };

    final currentReasons = demandReasons[demandType] ?? {};
    selectedReasonValue = currentReasons.keys.first;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                // Dismiss keyboard when tapping outside
                FocusScope.of(context).unfocus();
              },
              child: AlertDialog(
                title: Text(demandType == 'replenishment' ? l10n.order_demand_replenishment_title : l10n.order_demand_reform_title),
                content: GestureDetector(
                  onTap: () {
                    // Dismiss keyboard when tapping on content area
                    FocusScope.of(context).unfocus();
                  },
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(demandType == 'replenishment'
                              ? l10n.order_demand_replenishment_desc
                              : l10n.order_demand_reform_desc),
                          const SizedBox(height: 16),
                          Text(l10n.order_intervention_problem_type, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedReasonValue,
                            items: currentReasons.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedReasonValue = value!;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(l10n.order_demand_detail_label, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: reasonController,
                            maxLines: 3,
                            maxLength: 300,
                            decoration: InputDecoration(
                              hintText: demandType == 'replenishment'
                                  ? l10n.order_demand_replenishment_hint
                                  : l10n.order_demand_reform_hint,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.order_demand_validation_empty;
                              }
                              if (value.trim().length < 10) {
                                return l10n.order_demand_validation_min;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.info.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  demandType == 'replenishment'
                                      ? l10n.order_demand_replenishment_tip
                                      : l10n.order_demand_reform_tip,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                                ),
                                if (demandType == 'reform' && order.items.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  _buildEditNumInfo(context),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text(l10n.order_dialog_cancel),
                    onPressed: () => Navigator.of(dialogContext).canPop() ? Navigator.of(dialogContext).pop() : null,
                  ),
                  ElevatedButton(
                    child: Text(l10n.order_dialog_submit),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // First dismiss the dialog
                        if (Navigator.of(dialogContext).canPop()) {
                          Navigator.of(dialogContext).pop();
                        }
                        // Then submit using the outer context
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _submitOrderDemand(
                            outerContext,
                            demandType,
                            selectedReasonValue,
                            currentReasons[selectedReasonValue]!,
                            reasonController.text.trim(),
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Helper function to show requirement submission dialog ---
  Future<void> showRequirementSubmissionDialog(BuildContext context) async {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // 顶部拖动条
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题栏
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(bottomSheetContext).canPop() ? Navigator.of(bottomSheetContext).pop() : null,
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).order_action_submit_materials,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // 平衡左侧图标
                  ],
                ),
              ),
              const Divider(height: 1),
              // 表单内容
              Expanded(
                child: BlocProvider.value(
                  value: context.read<OrderDetailBloc>(),
                  child: OrderRequirementSubmissionForm(order: order),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Private helper methods

  Widget _buildDeliveryDialogContent(BuildContext context, List<OrderDelivery>? deliveries) {
    final l10n = AppLocalizations.of(context);
    if (deliveries == null || deliveries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.backgroundSecondary),
        ),
        child: Text(
          l10n.order_dialog_no_seller_delivery,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: deliveries.map((delivery) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.order_dialog_delivery_note(delivery.content)),
            if (delivery.files.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l10n.order_dialog_delivery_files, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...delivery.files.map((fileUrl) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 16),
                    const SizedBox(width: 4),
                    Expanded(child: Text(_extractFileName(fileUrl))),
                  ],
                ),
              )),
            ],
          ],
        ),
      )).toList(),
    );
  }
  
  Widget _buildMaterialsDialogContent(BuildContext context, List<OrderMaterials>? materials) {
    final l10n = AppLocalizations.of(context);
    if (materials == null || materials.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.backgroundSecondary),
        ),
        child: Text(
          l10n.order_dialog_no_buyer_materials,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: materials.map((material) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.info.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (material.features.isNotEmpty) ...[
              ...material.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${feature.question}: ${feature.answer}'),
              )),
            ],
            if (material.files.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l10n.order_dialog_delivery_files, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...material.files.map((fileUrl) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 16),
                    const SizedBox(width: 4),
                    Expanded(child: Text(_extractFileName(fileUrl))),
                  ],
                ),
              )),
            ],
          ],
        ),
      )).toList(),
    );
  }
  
  String _extractFileName(String fileUrl) {
    if (fileUrl.contains('/')) {
      return fileUrl.split('/').last;
    }
    return fileUrl;
  }

  Widget _buildEditNumInfo(BuildContext context) {
    final bloc = context.read<OrderDetailBloc>();
    final state = bloc.state;
    
    if (state is! OrderDetailLoaded || order.items.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final firstItem = order.items.first;
    final editNum = firstItem.editNum ?? 0;
    final currentDeliveryCount = state.deliveries?.length ?? 0;
    
    final l10n = AppLocalizations.of(context);
    String infoText = '';
    IconData iconData = Icons.info_outline;
    Color iconColor = AppColors.primary;

    if (currentDeliveryCount < editNum) {
      // Can be auto-approved
      infoText = l10n.order_demand_edit_info_auto(currentDeliveryCount, editNum - currentDeliveryCount);
      iconData = Icons.check_circle_outline;
      iconColor = Colors.green;
    } else {
      // Needs seller approval
      infoText = l10n.order_demand_edit_info_approval(currentDeliveryCount);
      iconData = Icons.access_time;
      iconColor = AppColors.warning;
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(iconData, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            infoText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: iconColor),
          ),
        ),
      ],
    );
  }

  // Submit methods
  Future<void> _submitPlatformIntervention(
    BuildContext context,
    String reasonValue,
    String reasonLabel,
    String description,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.order_intervention_submitting)),
      );

      // 调用BLoC处理平台介入
      context.read<OrderDetailBloc>().add(
        PlatformInterventionRequested(
          orderId: order.id,
          reasonValue: reasonValue,
          reasonLabel: reasonLabel,
          description: description,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.order_intervention_failed(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitOrderDemand(
    BuildContext context,
    String type,
    String reasonValue,
    String reasonLabel,
    String description,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(type == 'replenishment' ? l10n.order_demand_submitting_replenishment : l10n.order_demand_submitting_reform)),
      );

      // 调用BLoC处理订单需求
      context.read<OrderDetailBloc>().add(
        OrderDemandRequested(
          orderId: order.id,
          type: type,
          reasonValue: reasonValue,
          reasonLabel: reasonLabel,
          description: description,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.order_demand_failed(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}