import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/i_order_repository.dart';

/// 平台介入申请页面
class PlatformInterventionApplyPage extends StatefulWidget {
  final int orderId;
  final String orderSn;

  const PlatformInterventionApplyPage({
    super.key,
    required this.orderId,
    required this.orderSn,
  });

  @override
  State<PlatformInterventionApplyPage> createState() => _PlatformInterventionApplyPageState();
}

class _PlatformInterventionApplyPageState extends State<PlatformInterventionApplyPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _remarksController = TextEditingController();
  
  bool _isSubmitting = false;
  String _selectedReasonType = 'communication'; // 默认选择沟通问题
  
  // 预设的申请理由类型
  final Map<String, String> _reasonTypes = {
    'communication': '沟通问题',
    'quality': '质量争议',
    'delivery': '交付问题',
    'refund': '退款纠纷',
    'service': '服务态度',
    'other': '其他问题',
  };

  @override
  void dispose() {
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('申请平台介入 - #${widget.orderSn}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明卡片
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            '平台介入说明',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 平台介入适用于买卖双方无法协商解决的争议\n'
                        '• 申请后，平台客服会在24小时内联系您\n'
                        '• 每个订单最多可申请2次平台介入\n'
                        '• 请详细描述问题，有助于快速处理',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 问题类型选择
              Text(
                '问题类型 *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _reasonTypes.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.value),
                      value: entry.key,
                      groupValue: _selectedReasonType,
                      onChanged: (value) {
                        setState(() {
                          _selectedReasonType = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // 问题描述
              Text(
                '问题描述 *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: '请详细描述遇到的问题，包括具体情况、时间等信息',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
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
              const SizedBox(height: 24),

              // 补充说明
              Text(
                '补充说明',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _remarksController,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: '可补充其他相关信息（可选）',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('提交中...'),
                          ],
                        )
                                              : Text(
                            '提交申请',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // 温馨提示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '提示：申请提交后无法撤销，请确保已尝试与对方协商解决。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理申请提交
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = GetIt.instance<IOrderRepository>();
      
      // 构造申请参数
      final params = AddOrderDemandParams(
        orderId: widget.orderId,
        type: 'platform', // 平台介入类型
        reasonValue: _selectedReasonType,
        reasonLabel: _reasonTypes[_selectedReasonType]!,
        remarks: '${_reasonController.text.trim()}\n\n补充说明：${_remarksController.text.trim()}',
      );

      // 调用API
      final result = await repository.addOrderDemand(params);
      
      result.fold(
        (failure) {
          // 显示错误信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('申请失败：${failure.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          // 申请成功
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('申请已提交，平台客服会在24小时内联系您'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 返回上一页，并传递刷新信号
          context.pop(true);
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('申请失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
} 