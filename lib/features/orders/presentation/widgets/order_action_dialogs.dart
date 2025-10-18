import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_materials.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_delivery.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_requirement_submission_form.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

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
              child: const Text('取消'),
              onPressed: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            TextButton(
              child: const Text('确定'),
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
        const SnackBar(content: Text('数据未加载完成，请稍后再试')),
      );
      return;
    }
    
    final deliveries = state.deliveries;
    final materials = state.materials;
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('查看交付'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('卖家交付内容：'),
                  const SizedBox(height: 16),
                  _buildDeliveryDialogContent(deliveries),
                  const SizedBox(height: 16),
                  const Text('买家提交的材料：'),
                  const SizedBox(height: 8),
                  _buildMaterialsDialogContent(materials),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('关闭'),
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
    
    final Map<String, String> reasonTypes = {
      'communication': '沟通问题',
      'quality': '质量争议', 
      'delivery': '交付问题',
      'refund': '退款纠纷',
      'service': '服务态度',
      'other': '其他问题',
    };

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('申请平台介入'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('遇到无法解决的争议？平台客服会在24小时内介入处理。'),
                      const SizedBox(height: 16),
                      const Text('问题类型:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedReasonType,
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
                      const Text('问题描述:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: reasonController,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: const InputDecoration(
                          hintText: '请详细描述遇到的问题...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入问题描述';
                          }
                          if (value.trim().length < 10) {
                            return '问题描述至少需要10个字符';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Text(
                          '提示：申请提交后无法撤销，每个订单最多可申请2次。',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('取消'),
                  onPressed: () => Navigator.of(dialogContext).canPop() ? Navigator.of(dialogContext).pop() : null,
                ),
                ElevatedButton(
                  child: const Text('提交申请'),
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
    
    // Define reasons based on demand type
    final Map<String, Map<String, String>> demandReasons = {
      'replenishment': {
        'incomplete': '信息不完整',
        'unclear': '要求不明确',
        'additional': '需要补充说明',
        'reference': '需要参考资料',
        'other': '其他原因',
      },
      'reform': {
        'quality': '质量不满意',
        'requirement': '不符合要求',
        'incomplete': '内容不完整',
        'error': '存在错误',
        'other': '其他原因',
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
                title: Text(demandType == 'replenishment' ? '申请补充材料' : '申请重做'),
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
                              ? '如果需要卖家补充更多材料或说明，请详细描述您的需求。'
                              : '如果对交付结果不满意，可以申请重做。请说明具体问题。'),
                          const SizedBox(height: 16),
                          const Text('问题类型:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedReasonValue,
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
                          const Text('详细说明:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: reasonController,
                            maxLines: 3,
                            maxLength: 300,
                            decoration: InputDecoration(
                              hintText: demandType == 'replenishment' 
                                  ? '请详细说明需要补充的材料或信息...'
                                  : '请详细说明需要重做的原因和要求...',
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '请输入详细说明';
                              }
                              if (value.trim().length < 10) {
                                return '说明至少需要10个字符';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  demandType == 'replenishment' 
                                      ? '提示：卖家会在收到申请后24小时内回复并补充相关材料。'
                                      : '提示：重做申请提交后，卖家会重新处理您的订单。',
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
                    child: const Text('取消'),
                    onPressed: () => Navigator.of(dialogContext).canPop() ? Navigator.of(dialogContext).pop() : null,
                  ),
                  ElevatedButton(
                    child: const Text('提交申请'),
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
                  color: Colors.grey[300],
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
                    const Expanded(
                      child: Text(
                        '提交材料',
                        style: TextStyle(
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
              Divider(height: 1, color: Colors.grey[200]),
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

  Widget _buildDeliveryDialogContent(List<OrderDelivery>? deliveries) {
    if (deliveries == null || deliveries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Text(
          '卖家暂未交付内容',
          style: TextStyle(color: Colors.grey),
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
            Text('交付说明: ${delivery.content}'),
            if (delivery.files.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('交付文件:', style: TextStyle(fontWeight: FontWeight.bold)),
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
  
  Widget _buildMaterialsDialogContent(List<OrderMaterials>? materials) {
    if (materials == null || materials.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Text(
          '暂无买家提交的材料',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Column(
      children: materials.map((material) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
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
              const Text('附件:', style: TextStyle(fontWeight: FontWeight.bold)),
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
    
    String infoText = '';
    IconData iconData = Icons.info_outline;
    Color iconColor = AppColors.primary;
    
    if (currentDeliveryCount < editNum) {
      // Can be auto-approved
      infoText = '当前已交付 $currentDeliveryCount 次，剩余 ${editNum - currentDeliveryCount} 次免费修改机会（自动通过）';
      iconData = Icons.check_circle_outline;
      iconColor = Colors.green;
    } else {
      // Needs seller approval
      infoText = '当前已交付 $currentDeliveryCount 次，已用完免费修改机会，需要卖家审批';
      iconData = Icons.access_time;
      iconColor = Colors.orange;
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
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在提交申请...')),
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
          content: Text('申请失败：$e'),
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
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('正在提交${type == 'replenishment' ? '补充材料' : '重做'}申请...')),
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
          content: Text('申请失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}