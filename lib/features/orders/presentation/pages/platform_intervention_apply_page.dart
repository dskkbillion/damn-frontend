import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:file_picker/file_picker.dart';

/// Platform Intervention Application Page
/// Allows users to apply for platform intervention when they have disputes with sellers
class PlatformInterventionApplyPage extends StatefulWidget {
  final String orderId;
  final String? orderSn;

  const PlatformInterventionApplyPage({
    Key? key,
    required this.orderId,
    this.orderSn,
  }) : super(key: key);

  @override
  State<PlatformInterventionApplyPage> createState() => _PlatformInterventionApplyPageState();
}

class _PlatformInterventionApplyPageState extends State<PlatformInterventionApplyPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedReasonType = 'communication';
  final List<String> _evidenceFiles = [];
  bool _isSubmitting = false;

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
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _evidenceFiles.addAll(result.paths.where((path) => path != null).cast<String>());
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择文件失败: $e')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _evidenceFiles.removeAt(index);
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Submit through BLoC
      context.read<OrderDetailBloc>().add(
        PlatformInterventionRequested(
          orderId: int.parse(widget.orderId),
          reasonValue: _selectedReasonType,
          reasonLabel: _reasonTypes[_selectedReasonType]!,
          description: _descriptionController.text.trim(),
        ),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('平台介入申请已提交，我们将在24小时内处理'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to order detail
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('提交失败: $e'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('申请平台介入'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '关于平台介入',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '当您与卖家无法达成一致时，可以申请平台介入处理。平台客服会在24小时内介入并公正处理争议。',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Order Info
              if (widget.orderSn != null) ...[
                Text(
                  '订单编号: ${widget.orderSn}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Reason Type Selection
              Text(
                '问题类型 *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedReasonType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: _reasonTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReasonType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                '问题描述 *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: '请详细描述您遇到的问题，包括与卖家的沟通情况、争议点等...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
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

              // Evidence Upload
              Text(
                '上传证据（可选）',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '请上传相关截图、聊天记录等证据材料',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 12),
              
              // File List
              if (_evidenceFiles.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: _evidenceFiles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final path = entry.value;
                      final fileName = path.split('/').last;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_file, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fileName,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => _removeFile(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Upload Button
              OutlinedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text('选择文件'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Warning
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
                    Icon(Icons.warning_amber_outlined, 
                      color: Colors.orange[700], 
                      size: 20
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '重要提示',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• 申请提交后无法撤销\n• 每个订单最多可申请2次平台介入\n• 请确保提供真实、完整的信息',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '提交申请',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}