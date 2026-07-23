import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
// Import dart:io for File
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert'; // Import dart:convert for json handling
import 'file_upload_item.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

/// Widget for submitting order requirements (text and attachments).
class OrderRequirementSubmissionForm extends StatefulWidget {
  final Order order;

  const OrderRequirementSubmissionForm({super.key, required this.order});

  @override
  State<OrderRequirementSubmissionForm> createState() =>
      _OrderRequirementSubmissionFormState();
}

class _OrderRequirementSubmissionFormState
    extends State<OrderRequirementSubmissionForm> {
  // Add TextEditingControllers for text inputs
  late TextEditingController _requirementController1;
  late TextEditingController _requirementController2;
  // Add state for attached files
  List<FileUploadItem> _fileUploadItems = []; // 文件上传项列表
  List<String> _uploadedUrls = []; // 已上传的文件URL列表
  bool _isLoadingDraft = true; // Flag to indicate draft loading
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int _maxFileCount = 9; // 最多9个文件
  int _retryCount = 0; // 重试计数器
  static const int _maxRetryCount = 3; // 最大重试次数

  // Helper to generate SharedPreferences key for the draft
  String _getDraftKey(String orderId) => 'order_draft_$orderId';

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _requirementController1 = TextEditingController();
    _requirementController2 = TextEditingController();
    // Asynchronously load the draft
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    setState(() {
      _isLoadingDraft = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = _getDraftKey(widget.order.id.toString());
      final String? draftJson = prefs.getString(draftKey);

      if (draftJson != null) {
        final draftData = jsonDecode(draftJson) as Map<String, dynamic>;
        // Safely extract data
        final req1 = draftData['requirement1'] as String? ?? '';
        final req2 = draftData['requirement2'] as String? ?? '';
        final attachments =
            (draftData['attachments'] as List<dynamic>? ?? []).cast<String>();

        // Update controllers
        _requirementController1.text = req1;
        _requirementController2.text = req2;

        // 恢复文件列表
        if (draftData['fileItems'] != null) {
          final fileItemsList =
              (draftData['fileItems'] as List<dynamic>? ?? []);
          final restoredItems = <FileUploadItem>[];

          for (final itemData in fileItemsList) {
            if (itemData is Map<String, dynamic>) {
              restoredItems.add(FileUploadItem(
                id: itemData['id'] ?? '',
                localPath: itemData['localPath'] ?? '',
                fileName: itemData['fileName'] ?? '',
                fileSize: itemData['fileSize'] ?? 0,
                status: FileUploadStatus.values[itemData['statusIndex'] ?? 0],
                progress: (itemData['progress'] ?? 0.0).toDouble(),
                uploadedUrl: itemData['uploadedUrl'],
                errorMessage: itemData['errorMessage'],
              ));
            }
          }

          setState(() {
            _fileUploadItems = restoredItems;
            _uploadedUrls = attachments;
          });
        } else {
          // 兼容旧版本的草稿
          _uploadedUrls = attachments;
        }

        print('Draft loaded successfully for order ${widget.order.id}');
      } else {
        print('No draft found for order ${widget.order.id}');
      }
    } catch (e) {
      print('Error loading draft: $e');
      // Optionally show an error message to the user
      if (mounted) {
        // Check if widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)
                  .order_requirement_load_draft_failed)),
        );
      }
    } finally {
      // Ensure loading indicator is turned off even if errors occur
      if (mounted) {
        setState(() {
          _isLoadingDraft = false;
        });
      }
    }
  }

  // --- Draft Saving Logic ---
  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = _getDraftKey(widget.order.id.toString());

      // 保存文件项的详细信息
      final fileItemsData = _fileUploadItems
          .map((item) => {
                'id': item.id,
                'localPath': item.localPath,
                'fileName': item.fileName,
                'fileSize': item.fileSize,
                'statusIndex': item.status.index,
                'progress': item.progress,
                'uploadedUrl': item.uploadedUrl,
                'errorMessage': item.errorMessage,
              })
          .toList();

      final draftData = {
        'requirement1': _requirementController1.text,
        'requirement2': _requirementController2.text,
        'uploadedUrls': _uploadedUrls,
        'fileItems': fileItemsData,
      };

      final String draftJson = jsonEncode(draftData);
      await prefs.setString(draftKey, draftJson);
      print('Draft saved for order ${widget.order.id}');
    } catch (e) {
      print('Error saving draft: $e');
      // Optionally show an error message to the user
      if (mounted) {
        // Check if widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)
                  .order_requirement_save_draft_failed)),
        );
      }
    }
  }

  // --- Draft Clearing Logic (called externally, e.g., after successful submission) ---
  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = _getDraftKey(widget.order.id.toString());
      await prefs.remove(draftKey);
      print('Draft cleared for order ${widget.order.id}');
    } catch (e) {
      print('Error clearing draft: $e');
      // Optionally inform the user
    }
  }

  @override
  void dispose() {
    // Save draft one last time before disposing
    _saveDraft();
    // Dispose controllers
    _requirementController1.dispose();
    _requirementController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Assuming only one item per order for requirement submission view, adjust if needed
    final item =
        widget.order.items.isNotEmpty ? widget.order.items.first : null;

    // Show loading indicator while draft is loading
    if (_isLoadingDraft) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        // 点击空白区域收起键盘
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: GlassCard(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Product Info ---
              // Use a simpler display than the full OrderDetailItemTile if needed
              if (item != null)
                ListTile(
                  leading: AppNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  title: Text(item.productName, style: textTheme.titleSmall),
                  subtitle:
                      Text(item.skuName ?? '', style: textTheme.bodySmall),
                  trailing: Text(RegionConfig.formatPrice(item.price),
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  contentPadding: EdgeInsets.zero,
                ),
              if (item != null) const Divider(height: 24),

              // --- Requirements Section ---
              Text(AppLocalizations.of(context).order_requirement_title,
                  style: textTheme.titleMedium),
              const SizedBox(height: 8),
              // 动态显示商品要求
              _buildRequirementFields(context),

              const SizedBox(height: 24),

              // --- Attachments Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            AppLocalizations.of(context)
                                .order_requirement_attachment_title,
                            style: textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)
                              .order_requirement_attachment_limit(
                                  _maxFileCount, _maxFileSize ~/ (1024 * 1024)),
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (_fileUploadItems.length < _maxFileCount)
                    TextButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                          AppLocalizations.of(context).order_requirement_add),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // 文件上传列表
              if (_fileUploadItems.isNotEmpty) ...[
                ...List.generate(_fileUploadItems.length, (index) {
                  final item = _fileUploadItems[index];
                  return FileUploadItemWidget(
                    key: ValueKey(item.id),
                    item: item,
                    maxFileSize: _maxFileSize,
                    onRemove: () => _removeFile(index),
                    onUploadSuccess: (url) => _onFileUploaded(index, url),
                  );
                }),
              ] else
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickFiles,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.backgroundSecondary),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 32, color: AppColors.textTertiary),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)
                                  .order_requirement_click_select_file,
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // --- Action Buttons for this Form ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // REMOVED: Save Draft Button and associated BlocSelector
                  // const SizedBox(width: 16), // Keep spacing if needed
                  // --- Submit Requirements Button ---
                  BlocSelector<OrderDetailBloc, OrderDetailState, bool>(
                    selector: (state) =>
                        state is OrderDetailLoaded &&
                        state.isSubmittingRequirements,
                    builder: (context, isSubmitting) {
                      return ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                // 检查是否所有文件都已上传完成
                                final hasUploadingFiles = _fileUploadItems.any(
                                    (item) =>
                                        item.status ==
                                        FileUploadStatus.uploading);

                                if (hasUploadingFiles) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(AppLocalizations.of(
                                                context)
                                            .order_requirement_wait_upload)),
                                  );
                                  return;
                                }

                                // 检查是否有上传失败的文件
                                final failedFiles = _fileUploadItems
                                    .where((item) =>
                                        item.status == FileUploadStatus.failed)
                                    .toList();

                                if (failedFiles.isNotEmpty) {
                                  // 显示重试选项
                                  final shouldRetry = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(AppLocalizations.of(context)
                                          .order_requirement_upload_failed_title),
                                      content: Text(AppLocalizations.of(context)
                                          .order_requirement_upload_failed_count(
                                              failedFiles.length)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(AppLocalizations.of(
                                                  context)
                                              .order_requirement_remove_failed),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: Text(AppLocalizations.of(
                                                  context)
                                              .order_requirement_retry_upload),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (shouldRetry == true) {
                                    // 重试上传失败的文件
                                    for (final item in failedFiles) {
                                      final index =
                                          _fileUploadItems.indexOf(item);
                                      if (index != -1) {
                                        _retryUpload(index);
                                      }
                                    }
                                    return;
                                  } else if (shouldRetry == false) {
                                    // 移除失败的文件
                                    setState(() {
                                      _fileUploadItems.removeWhere((item) =>
                                          item.status ==
                                          FileUploadStatus.failed);
                                    });
                                  } else {
                                    return; // 用户取消对话框
                                  }
                                }

                                // --- Construct feature data ---
                                final item = widget.order.items.isNotEmpty
                                    ? widget.order.items.first
                                    : null;
                                final featureData = [
                                  {
                                    'question': '需求描述',
                                    'answer': _requirementController1.text
                                  },
                                  {
                                    'question': '补充说明',
                                    'answer': _requirementController2.text
                                  },
                                ];
                                // --- Get productId ---
                                final productId = item?.productId ?? -1;
                                if (productId == -1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(AppLocalizations.of(
                                                context)
                                            .order_requirement_error_product_id)),
                                  );
                                  return;
                                }

                                // --- Dispatch Event ---
                                context.read<OrderDetailBloc>().add(
                                      SubmitRequirementsSubmitted(
                                        orderId: widget.order.id.toString(),
                                        productId: productId, // Pass productId
                                        feature:
                                            featureData, // Pass structured feature data
                                        attachmentPaths:
                                            _uploadedUrls, // 使用已上传的URL列表
                                      ),
                                    );
                                print('Confirm Submission Tapped');

                                // 成功提交后清除草稿
                                _clearDraft();
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(AppLocalizations.of(context)
                                .order_requirement_confirm_submit),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for seller question text style
  Widget _buildSellerQuestion(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  // 动态构建要求字段
  Widget _buildRequirementFields(BuildContext context) {
    // 获取商品信息
    final item =
        widget.order.items.isNotEmpty ? widget.order.items.first : null;
    if (item == null) {
      return Text(AppLocalizations.of(context).order_items_empty);
    }

    // TODO: 需要实现以下功能：
    // 1. 调用后端API获取商品的ProductMaterials（商品材料问题列表）
    //    - 后端需要实现: GET /api/project/productMaterials/list?productId={productId}
    //    - 返回 List<ProductMaterials>，每个包含: id, productId, question, answer, type
    // 2. 根据ProductMaterials动态生成输入框
    //    - type字段可能包含: TEXT, NUMBER, SELECT, FILE等
    // 3. 将用户填写的答案映射到feature字段的question-answer结构
    //
    // 示例API响应：
    // [
    //   {"id": 1, "productId": 123, "question": "您的需求描述", "type": "TEXT"},
    //   {"id": 2, "productId": 123, "question": "期望完成时间", "type": "DATE"},
    //   {"id": 3, "productId": 123, "question": "预算范围", "type": "SELECT", "answer": "1000-3000,3000-5000,5000以上"}
    // ]

    // 临时解决方案：显示通用问题
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示选择的服务信息
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)
                      .order_requirement_service_selected(
                          _getLocalizedSkuName(context, item.skuName),
                          item.price.toStringAsFixed(2)),
                  style: TextStyle(fontSize: 14, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 问题1：需求描述
        _buildSellerQuestion(
            context, AppLocalizations.of(context).order_requirement_q1),
        TextField(
          controller: _requirementController1,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).order_requirement_q1_hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.backgroundSecondary,
            contentPadding: const EdgeInsets.all(12),
            helperText:
                AppLocalizations.of(context).order_requirement_q1_helper,
            helperStyle:
                TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 16),

        // 问题2：补充说明
        _buildSellerQuestion(
            context, AppLocalizations.of(context).order_requirement_q2),
        TextField(
          controller: _requirementController2,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).order_requirement_q2_hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.backgroundSecondary,
            contentPadding: const EdgeInsets.all(12),
          ),
          maxLines: 3,
        ),

        const SizedBox(height: 12),
        // 提示信息
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).order_requirement_warning,
                  style: TextStyle(fontSize: 12, color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to get localized SKU name
  String _getLocalizedSkuName(BuildContext context, String? skuName) {
    if (skuName == null)
      return AppLocalizations.of(context).order_requirement_default_service;

    // TODO: 这里需要从商品的本地化数据中获取中文名称
    // 临时映射常见的SKU名称
    final Map<String, String> skuNameMap = {
      'Basic Tier': '基础套餐',
      'Standard Tier': '标准套餐',
      'Premium Tier': '高级套餐',
      'Professional Tier': '专业套餐',
      'Enterprise Tier': '企业套餐',
      // 添加更多映射...
    };

    return skuNameMap[skuName] ?? skuName;
  }

  // --- File Picking Logic ---
  Future<void> _pickFiles() async {
    if (_fileUploadItems.length >= _maxFileCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .order_requirement_max_files(_maxFileCount))),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'bmp',
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'zip',
          'rar',
          '7z',
          'txt'
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        final remainingSlots = _maxFileCount - _fileUploadItems.length;
        final filesToAdd = result.files.take(remainingSlots);

        for (final file in filesToAdd) {
          if (file.path != null) {
            final fileItem = FileUploadItem(
              id: '${DateTime.now().millisecondsSinceEpoch}_${file.name}',
              localPath: file.path!,
              fileName: file.name,
              fileSize: file.size,
            );

            setState(() {
              _fileUploadItems.add(fileItem);
            });
          }
        }
      }
    } catch (e) {
      print('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .order_requirement_pick_failed(e.toString()))),
      );
    }
  }

  // 移除文件
  void _removeFile(int index) {
    if (index >= 0 && index < _fileUploadItems.length) {
      final item = _fileUploadItems[index];

      // 如果文件已上传，从已上传列表中移除
      if (item.uploadedUrl != null) {
        _uploadedUrls.remove(item.uploadedUrl);
      }

      setState(() {
        _fileUploadItems.removeAt(index);
      });
    }
  }

  // 文件上传成功回调
  void _onFileUploaded(int index, String url) {
    if (index >= 0 && index < _fileUploadItems.length) {
      setState(() {
        _uploadedUrls.add(url);
      });
      // 保存草稿
      _saveDraft();
    }
  }

  // 重试上传文件
  Future<void> _retryUpload(int index) async {
    if (index < 0 || index >= _fileUploadItems.length) return;

    final item = _fileUploadItems[index];
    if (item.status != FileUploadStatus.failed) return;

    _retryCount++;
    if (_retryCount > _maxRetryCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .order_upload_max_retry(_maxRetryCount))),
      );
      return;
    }

    // 重置状态并重新创建上传组件
    setState(() {
      _fileUploadItems[index] = FileUploadItem(
        id: item.id,
        localPath: item.localPath,
        fileName: item.fileName,
        fileSize: item.fileSize,
        status: FileUploadStatus.waiting,
      );
    });

    // 指数退避延迟
    final delay = Duration(seconds: _retryCount * 2);
    await Future.delayed(delay);

    // 触发重新渲染以重新开始上传
    if (mounted) {
      setState(() {});
    }
  }

  // --- Helper method to get file icon based on extension (reuse/copy from DeliveryConfirmationArea or common utils) ---
  IconData _getFileIcon(String fileName) {
    final extension =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    // ... (Switch case logic remains the same as in DeliveryConfirmationArea)
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.assessment_outlined;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image_outlined;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}
