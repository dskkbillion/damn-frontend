import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import '../bloc/seller_order_detail_bloc.dart'; // Import Detail Bloc

// 移除邀请评价状态类

/// Displays action buttons for the SellerOrderDetailPage, typically at the bottom.
class SellerOrderDetailActions extends StatefulWidget {
  final Order order;

  const SellerOrderDetailActions({super.key, required this.order});

  @override
  State<SellerOrderDetailActions> createState() => _SellerOrderDetailActionsState();
}

class _SellerOrderDetailActionsState extends State<SellerOrderDetailActions> {
  // 移除邀请评价相关状态
  // InvitationStatus? _invitationStatus;

  @override
  void initState() {
    super.initState();
    // 不再加载邀请状态
  }

  // 移除邀请状态加载方法
  /*
  Future<void> _loadInvitationStatus() async {
    final prefs = GetIt.instance<SharedPreferences>();
    final key = 'invitation_status_${widget.order.id}';
    final data = prefs.getString(key);
    
    if (data != null) {
      try {
        final parts = data.split('|');
        if (parts.length >= 2) {
          final todayCount = int.parse(parts[0]);
          final lastTimeStr = parts[1];
          final lastTime = lastTimeStr.isNotEmpty ? DateTime.parse(lastTimeStr) : null;
          
          // 检查是否跨天，如果跨天则重置计数
          if (lastTime != null) {
            final now = DateTime.now();
            final lastDate = DateTime(lastTime.year, lastTime.month, lastTime.day);
            final today = DateTime(now.year, now.month, now.day);
            
            if (lastDate.isBefore(today)) {
              // 跨天了，重置计数
              setState(() {
                _invitationStatus = const InvitationStatus(todayCount: 0);
              });
              await _saveInvitationStatus(const InvitationStatus(todayCount: 0));
              return;
            }
          }
          
          setState(() {
            _invitationStatus = InvitationStatus(
              todayCount: todayCount,
              lastInviteTime: lastTime,
            );
          });
        }
      } catch (e) {
        print('[SellerOrderDetailActions] Error parsing invitation status: $e');
      }
    }
    
    // 如果没有数据或解析失败，使用默认状态
    if (_invitationStatus == null) {
      setState(() {
        _invitationStatus = const InvitationStatus();
      });
    }
  }
  */

  // 移除保存邀请状态方法
  /*
  Future<void> _saveInvitationStatus(InvitationStatus status) async {
    final prefs = GetIt.instance<SharedPreferences>();
    final key = 'invitation_status_${widget.order.id}';
    final data = '${status.todayCount}|${status.lastInviteTime?.toIso8601String() ?? ''}';
    await prefs.setString(key, data);
  }
  */

  // 移除邀请评价处理方法
  /*
  Future<void> _handleInviteEvaluation(BuildContext context) async {
    final bloc = BlocProvider.of<SellerOrderDetailBloc>(context);
    
    // 检查是否已达到限制
    if (_invitationStatus?.hasReachedLimit == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('今日邀请次数已达上限（3次），请明天再试'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 显示确认对话框，包含状态信息
    final confirmed = await _showInviteConfirmationDialog(context);
    if (confirmed == true) {
      // 先乐观更新UI状态
      final currentStatus = _invitationStatus ?? const InvitationStatus();
      final newStatus = InvitationStatus(
        todayCount: currentStatus.todayCount + 1,
        lastInviteTime: DateTime.now(),
      );
      
      setState(() {
        _invitationStatus = newStatus;
      });
      await _saveInvitationStatus(newStatus);
      
      // 发送邀请请求
      bloc.add(SellerInviteEvaluationRequested(orderId: widget.order.id));
    }
  }
  */

  // 移除邀请确认对话框方法
  /*
  Future<bool?> _showInviteConfirmationDialog(BuildContext context) {
    final status = _invitationStatus ?? const InvitationStatus();
    final remaining = 3 - status.todayCount;
    
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('邀请评价'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('您确定要邀请买家评价此订单吗？'),
              const SizedBox(height: 8),
              Text(
                '当前状态：${status.statusText}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: status.hasReachedLimit ? Colors.orange : Colors.green,
                ),
              ),
              if (remaining > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '邀请后今日还可邀请 ${remaining - 1} 次',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('确认邀请'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    final buttons = _buildButtons(context);

    // Use a SafeArea and Padding for bottom bar
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor, // Or scaffoldBackgroundColor
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Wrap(
          spacing: 8.0,
          alignment: WrapAlignment.end,
          children: buttons,
        ),
      ),
    );
  }

  // Helper method to build the list of buttons based on order state
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    final bloc = BlocProvider.of<SellerOrderDetailBloc>(context); // Get the Detail Bloc

    // Button styles (similar to list item buttons, maybe centralize later)
    final ButtonStyle outlineStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
    final ButtonStyle filledStyle = ElevatedButton.styleFrom(
       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
       textStyle: Theme.of(context).textTheme.labelLarge,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

    // Determine buttons based on state
    switch (widget.order.state) {
      case OrderStatus.awaitingStart:
        buttons.add(OutlinedButton(
          onPressed: () async {
             // Show dialog to get rejection reason
             final Map<String, String?>? reasonInfo = await _showRejectReasonDialog(context);

             if (reasonInfo != null) {
                final String reasonLabel = reasonInfo['reasonLabel'] ?? '卖家拒绝接单'; // Default if somehow null
                final String? remarks = reasonInfo['remarks'];

                // Basic validation: reason cannot be empty if dialog confirmed
                if (reasonLabel.trim().isNotEmpty) {
                    // TODO: Map common reasons to reasonValue codes if needed by API
                    final params = AddOrderDemandParams(
                        orderId: widget.order.id,
                        type: 'refuse',
                        reasonValue: 'seller_reject_custom', // Placeholder value
                        reasonLabel: reasonLabel.trim(),
                        remarks: remarks?.trim(),
                    );
                    // Pass only params, as orderId is inside params
                    bloc.add(SellerRejectRequested(params: params)); 
                } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('请输入拒绝理由'), backgroundColor: Colors.orange),
                    );
                }
             } // User cancelled dialog
          }, 
          style: outlineStyle, 
          child: const Text('拒绝接单')
        ));
        buttons.add(ElevatedButton(
           onPressed: () async {
            final confirmed = await _showConfirmationDialog(context, title: '确认接单', content: '您确定要接受此订单吗？');
            if (confirmed == true) {
              bloc.add(SellerConfirmAcceptanceRequested(orderId: widget.order.id));
            }
           }, 
           style: filledStyle, 
           child: const Text('确认接单')
          ));
        break;
      case OrderStatus.awaitingDelivery:
         buttons.add(OutlinedButton(onPressed: () { /* TODO: Contact buyer */ }, style: outlineStyle, child: const Text('联系买家')));
         buttons.add(ElevatedButton(
          onPressed: () async {
             // Show dialog to collect delivery info
             final Map<String, String>? deliveryInfo = await _showDeliveryInputDialog(context);
             
             if (deliveryInfo != null) {
               final String deliverySn = deliveryInfo['sn'] ?? '';
               final String deliveryCompany = deliveryInfo['company'] ?? ''; // Default if needed

               if (deliverySn.isNotEmpty) { // Require SN at least
                  final params = DeliverOrderParams(
                    orderId: widget.order.id, 
                    content: '已发货', // Or use custom content?
                    files: [], // TODO: Handle file uploads
                    deliverySn: deliverySn, // Pass the collected SN
                    deliveryCompany: deliveryCompany.isNotEmpty ? deliveryCompany : null, // Pass company if provided
                  );
                  bloc.add(SellerDeliverRequested(orderId: widget.order.id, params: params));
               } else {
                 // SN was empty, even if dialog was confirmed
                  ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('请输入物流单号'), backgroundColor: Colors.orange),
                 );
               }
             } // If deliveryInfo is null, user canceled dialog - do nothing
            }, 
            style: filledStyle, 
            child: const Text('去交付')
            ));
        break;
      case OrderStatus.awaitingConfirmation:
         buttons.add(OutlinedButton(onPressed: () { /* TODO: Show logistics */ }, style: outlineStyle, child: const Text('查看物流')));
         // buttons.add(ElevatedButton(onPressed: () { /* TODO: Remind buyer */ }, style: filledStyle, child: const Text('提醒确认收货'))); // Maybe not needed here?
        break;
      case OrderStatus.orderCompleted:
        buttons.add(OutlinedButton(
          onPressed: () async {
             final confirmed = await _showConfirmationDialog(context, title: '确认删除', content: '您确定要删除这条订单记录吗？此操作无法撤销。');
             if (confirmed == true) {
               bloc.add(SellerDeleteRecordRequested(orderId: widget.order.id));
             }
          }, 
          style: outlineStyle, 
          child: const Text('删除记录')
          ));
        // 移除邀请评价按钮
        break;
      case OrderStatus.canceled:
          buttons.add(OutlinedButton(
           onPressed: () async {
             final confirmed = await _showConfirmationDialog(context, title: '确认删除', content: '您确定要删除这条已取消的订单记录吗？此操作无法撤销。');
             if (confirmed == true) {
                bloc.add(SellerDeleteRecordRequested(orderId: widget.order.id));
              }
            }, 
            style: outlineStyle, 
            child: const Text('删除记录')
           ));
        break;
      // TODO: Add buttons for other relevant seller states
      default:
        // No actions for other states for now
        break;
    }

    return buttons;
  }

  // Helper to show a dialog for entering rejection reason and remarks
  Future<Map<String, String?>?> _showRejectReasonDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController remarksController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, String?>?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('拒绝订单'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: '拒绝理由 *',
                    hintText: '请输入拒绝理由'
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '拒绝理由不能为空';
                    }
                    return null;
                  },
                  maxLines: 2, // Allow slightly longer reasons
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: remarksController,
                  decoration: const InputDecoration(
                    labelText: '补充说明 (可选)',
                    hintText: '选填'
                  ),
                   maxLines: 2,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(dialogContext).pop(null),
            ),
            TextButton(
              child: const Text('确认拒绝'),
              onPressed: () {
                 if (formKey.currentState!.validate()) {
                    Navigator.of(dialogContext).pop({
                       'reasonLabel': reasonController.text.trim(),
                       'remarks': remarksController.text.trim(),
                     });
                  }
              },
            ),
          ],
        );
      },
    );
  }

  // Helper to show a confirmation dialog
  Future<bool?> _showConfirmationDialog(BuildContext context, {required String title, required String content, String confirmText = '确认'}) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(confirmText),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
  }

  // Helper to show an input dialog for delivery SN and Company
  Future<Map<String, String>?> _showDeliveryInputDialog(BuildContext context) {
    final TextEditingController snController = TextEditingController();
    final TextEditingController companyController = TextEditingController(); // Controller for company
    final formKey = GlobalKey<FormState>(); // Add form key for potential validation

    return showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('填写发货信息'),
          content: Form( // Wrap with Form
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevent dialog from taking full height
              children: [
                TextFormField( // Use TextFormField for validation
                  controller: snController,
                  decoration: const InputDecoration(
                    labelText: '物流单号 *', // Mark as required
                    hintText: '请输入物流单号'
                  ),
                  autofocus: true,
                  validator: (value) { // Basic validation
                    if (value == null || value.trim().isEmpty) {
                      return '物流单号不能为空';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextField( // Company is optional for now
                  controller: companyController,
                  decoration: const InputDecoration(
                    labelText: '物流公司',
                    hintText: '请输入物流公司 (可选)'
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(dialogContext).pop(null), // Return null on cancel
            ),
            TextButton(
              child: const Text('确认发货'),
              onPressed: () {
                 // Validate the form
                 if (formKey.currentState!.validate()) {
                    // Return a map with both values if valid
                    Navigator.of(dialogContext).pop({
                       'sn': snController.text.trim(),
                       'company': companyController.text.trim(),
                     });
                  }
              },
            ),
          ],
        );
      },
    );
  }
}

