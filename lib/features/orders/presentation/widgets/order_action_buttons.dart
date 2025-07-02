import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

/// 根据订单状态显示【订单详情页】可用操作按钮的 Widget
class OrderDetailActionButtons extends StatelessWidget {
  final Order order;
  // TODO: 添加按钮点击的回调函数，例如 onCancel, onConfirmReceipt, onDelete 等

  const OrderDetailActionButtons({
    super.key,
    required this.order,
  });

  // --- Helper function for confirmation dialog ---
  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView( // Use SingleChildScrollView in case content is long
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
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                onConfirm(); // Execute the confirmation action
              },
            ),
          ],
        );
      },
    );
  }

  // --- Helper function for platform intervention dialog ---
  Future<void> _showPlatformInterventionDialog(BuildContext context) async {
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
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: const Text('提交申请'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext).pop();
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

  // --- Helper function to submit platform intervention ---
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

      // TODO: 这里需要实现实际的API调用
      // 现在使用模拟的延迟来演示流程
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟成功提交
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('申请已提交，平台客服会在24小时内联系您'),
          backgroundColor: Colors.green,
        ),
      );

      // TODO: 刷新订单状态
      // context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: order.id));
      
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

  // --- Helper function for order demand dialog ---
  Future<void> _showOrderDemandDialog(BuildContext context, String demandType) async {
    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String selectedReasonValue = '';
    
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
            return AlertDialog(
              title: Text(demandType == 'replenishment' ? '申请补充材料' : '申请重做'),
              content: Form(
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
                        child: Text(
                          demandType == 'replenishment' 
                              ? '提示：卖家会在收到申请后24小时内回复并补充相关材料。'
                              : '提示：重做申请提交后，卖家会重新处理您的订单。',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('取消'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: const Text('提交申请'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext).pop();
                      _submitOrderDemand(
                        context,
                        demandType,
                        selectedReasonValue,
                        currentReasons[selectedReasonValue]!,
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

  // --- Helper function to submit order demand ---
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

      // TODO: 这里需要实现实际的API调用
      // 现在使用模拟的延迟来演示流程
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟成功提交
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('申请已提交，卖家会在24小时内回复处理结果'),
          backgroundColor: Colors.green,
        ),
      );

      // TODO: 刷新订单状态
      // context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: order.id));
      
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
  // --- End Helper function ---

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];
    Widget? primaryButton;

    // 使用 order_status.dart 中定义的实际枚举值
    switch (order.state) {
      case OrderStatus.awaitingPayment: // 待付款
        buttons.add(_buildButton(context, '取消订单', () {
           _showConfirmationDialog(
             context: context,
             title: '取消订单',
             content: '您确定要取消这个订单吗？',
             onConfirm: () {
               // Use correct parameter name 'action'
               context.read<OrderDetailBloc>().add(OrderActionRequested(action: OrderAction.cancel, orderId: order.id.toString()));
             },
           );
        }));
        primaryButton = _buildButton(context, '去支付', () {
          context.read<OrderDetailBloc>().add(GoToPayment(orderId: order.id));
        }, isPrimary: true);
        break;
      // 待发货/待交付，允许取消和提醒
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
        buttons.add(_buildButton(context, '提醒发货', () {
          // TODO: Implement reminder logic (if any) - maybe a snackbar?
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已提醒卖家发货')));
        }));
        buttons.add(_buildButton(context, '平台介入', () {
          _showPlatformInterventionDialog(context);
        }));
        buttons.add(_buildButton(context, '取消订单', () { // 假设这些状态可以取消
           _showConfirmationDialog(
             context: context,
             title: '取消订单',
             content: '您确定要取消这个订单吗？',
             onConfirm: () {
                // Use correct parameter name 'action'
                context.read<OrderDetailBloc>().add(OrderActionRequested(action: OrderAction.cancel, orderId: order.id.toString()));
             },
           );
        }));
        break;
      case OrderStatus.awaitingConfirmation: // 待收货
        buttons.add(_buildButton(context, '查看物流', () {
           context.read<OrderDetailBloc>().add(GoToTracking(orderId: order.id));
        }));
        buttons.add(_buildButton(context, '补充材料', () {
          _showOrderDemandDialog(context, 'replenishment');
        }));
        buttons.add(_buildButton(context, '平台介入', () {
          _showPlatformInterventionDialog(context);
        }));
        primaryButton = _buildButton(context, '确认收货', () {
           // Call the confirmation dialog
          _showConfirmationDialog(
            context: context,
            title: '确认收货',
            content: '您确定已经收到货品，并确认收货吗？',
            onConfirm: () {
              // Use correct parameter name 'action'
              context.read<OrderDetailBloc>().add(OrderActionRequested(action: OrderAction.confirmReceipt, orderId: order.id.toString()));
            },
          );
        }, isPrimary: true);
        break;
      case OrderStatus.awaitingEvaluation: // 待评价
         buttons.add(_buildButton(context, '查看物流', () {
           // TODO: Implement tracking navigation or show modal
           print('查看物流 for order ${order.id}');
           // Example: context.go('/tracking/${order.id}');
        }));
        buttons.add(_buildButton(context, '补充材料', () {
          _showOrderDemandDialog(context, 'replenishment');
        }));
        buttons.add(_buildButton(context, '申请售后', () {
           if (order.items.isNotEmpty) {
             final firstItem = order.items.first; // Get the first item
             final firstItemId = firstItem.id;
             Future.delayed(const Duration(milliseconds: 50), () {
                if (context.mounted) {
                   // Pass the OrderItem object via the 'extra' parameter
                   context.go('/selectAfterSalesType/$firstItemId', extra: firstItem);
                   print('Navigate to select after sales type for item ID: $firstItemId, passing item data (after delay)');
                }
             });
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('错误：无法为没有商品的订单申请售后')),
             );
             print('Error: Cannot apply after sales for order ${order.id} with no items.');
           }
        }));
        buttons.add(_buildButton(context, '平台介入', () {
          _showPlatformInterventionDialog(context);
        }));
        primaryButton = _buildButton(context, '去评价', () {
           // TODO: Implement navigation to evaluation page or show modal
           print('去评价 for order ${order.id}');
           // Example: context.go('/evaluate/${order.id}');
           // For now, just adding the existing event might be okay if it handles showing the form
            context.read<OrderDetailBloc>().add(GoToEvaluation(orderId: order.id));
        }, isPrimary: true);
        break;
      case OrderStatus.orderCompleted: // 已完成
         buttons.add(_buildButton(context, '申请重做', () {
           _showOrderDemandDialog(context, 'reform');
         }));
         buttons.add(_buildButton(context, '申请售后', () {
           if (order.items.isNotEmpty) {
             final firstItem = order.items.first; // Get the first item
             final firstItemId = firstItem.id;
             Future.delayed(const Duration(milliseconds: 50), () {
                if (context.mounted) {
                  // Pass the OrderItem object via the 'extra' parameter
                  context.go('/selectAfterSalesType/$firstItemId', extra: firstItem);
                  print('Navigate to select after sales type for item ID: $firstItemId, passing item data (after delay)');
                }
             });
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('错误：无法为没有商品的订单申请售后')),
             );
             print('Error: Cannot apply after sales for order ${order.id} with no items.');
           }
        }));
         buttons.add(_buildButton(context, '删除订单', () {
           _showConfirmationDialog(
             context: context,
             title: '删除订单',
             content: '您确定要删除这个订单吗？删除后将无法恢复。',
             onConfirm: () {
               // Use correct parameter name 'action'
               context.read<OrderDetailBloc>().add(OrderActionRequested(action: OrderAction.delete, orderId: order.id.toString()));
             },
           );
        }));
        break;
      case OrderStatus.canceled: // 已取消
      case OrderStatus.afterSale: // 售后处理中 (通常不允许再申请)
      case OrderStatus.AfterSaleRejection: // 售后被拒 (是否允许再次申请? 业务决定, 暂时不加)
      case OrderStatus.applyingForMediation: // 平台介入中 (通常不允许再申请)
         buttons.add(_buildButton(context, '查看订单', () {
           // Just ensure detail page is loaded, no specific action needed?
           print('查看订单: ${order.id}');
         }));
        buttons.add(_buildButton(context, '删除订单', () {
           _showConfirmationDialog(
             context: context,
             title: '删除订单',
             content: '您确定要删除这个订单吗？删除后将无法恢复。',
             onConfirm: () {
               // Use correct parameter name 'action'
               context.read<OrderDetailBloc>().add(OrderActionRequested(action: OrderAction.delete, orderId: order.id.toString()));
             },
           );
        }));
        break;
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
      case OrderStatus.unknown:
      default:
        break;
    }

    // 如果没有按钮，不显示
    if (buttons.isEmpty && primaryButton == null) {
      return const SizedBox.shrink();
    }

    // 将主要按钮添加到列表中
    if (primaryButton != null) {
      buttons.add(primaryButton);
    }

    return _buildResponsiveButtonLayout(buttons);
  }

  /// 构建响应式按钮布局
  Widget _buildResponsiveButtonLayout(List<Widget> buttons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final buttonCount = buttons.length;
        
        // 如果按钮数量 > 3 或屏幕宽度较小，使用多行布局
        if (buttonCount > 3 || screenWidth < 400) {
          return _buildMultiRowLayout(buttons);
        } else {
          // 单行布局
          return _buildSingleRowLayout(buttons);
        }
      },
    );
  }

  /// 构建单行布局
  Widget _buildSingleRowLayout(List<Widget> buttons) {
    return Row(
      children: buttons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? 8.0 : 0,
            ),
            child: button,
          ),
        );
      }).toList(),
    );
  }

  /// 构建多行布局
  Widget _buildMultiRowLayout(List<Widget> buttons) {
    // 将主要按钮（最后一个）放在单独一行，其余按钮放在上面的行
    if (buttons.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: buttons.first,
      );
    }

    final secondaryButtons = buttons.take(buttons.length - 1).toList();
    final primaryButton = buttons.last;

    return Column(
      children: [
        // 次要操作按钮行
        if (secondaryButtons.isNotEmpty) ...[
          _buildSecondaryButtonsRow(secondaryButtons),
          const SizedBox(height: 8),
        ],
        // 主要操作按钮行
        SizedBox(
          width: double.infinity,
          child: primaryButton,
        ),
      ],
    );
  }

  /// 构建次要按钮行
  Widget _buildSecondaryButtonsRow(List<Widget> buttons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        // 如果次要按钮太多，分成两行
        if (buttons.length > 3 || (buttons.length > 2 && screenWidth < 360)) {
          return Column(
            children: [
              _buildButtonRow(buttons.take(2).toList()),
              if (buttons.length > 2) ...[
                const SizedBox(height: 8),
                _buildButtonRow(buttons.skip(2).toList()),
              ],
            ],
          );
        } else {
          return _buildButtonRow(buttons);
        }
      },
    );
  }

  /// 构建按钮行
  Widget _buildButtonRow(List<Widget> buttons) {
    return Row(
      children: buttons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? 8.0 : 0,
            ),
            child: button,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed, {bool isPrimary = false}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Define common style elements
    final buttonPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10); // 减少水平padding
    final buttonTextStyle = textTheme.bodySmall; // 使用标准小字体
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)); // Slightly less rounded
    const buttonMinSize = Size(0, 36); // Slightly taller minimum height

    return isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
               backgroundColor: colorScheme.primary,
               foregroundColor: colorScheme.onPrimary,
               padding: buttonPadding,
               textStyle: buttonTextStyle,
               shape: buttonShape,
               minimumSize: buttonMinSize,
               elevation: 2, // Add slight elevation
            ),
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              padding: buttonPadding,
              textStyle: buttonTextStyle,
              shape: buttonShape,
              minimumSize: buttonMinSize,
            ),
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          );
  }
}