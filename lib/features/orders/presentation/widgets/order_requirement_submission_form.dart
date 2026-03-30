import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'dart:io'; // Import dart:io for File
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert'; // Import dart:convert for json handling
import 'file_upload_item.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

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
        final attachments = (draftData['attachments'] as List<dynamic>? ?? []).cast<String>();

        // Update controllers
        _requirementController1.text = req1;
        _requirementController2.text = req2;

        // 恢复文件列表
        if (draftData['fileItems'] != null) {
          final fileItemsList = (draftData['fileItems'] as List<dynamic>? ?? []);
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

        AppLogger.d('Draft loaded successfully for order ${widget.order.id}');
      } else {
        AppLogger.d('No draft found for order ${widget.order.id}');
      }
    } catch (e) {
      AppLogger.d('Error loading draft: $e');
      // Optionally show an error message to the user
      if (mounted) { // Check if widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载草稿失败')), // Localize this
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
      final fileItemsData = _fileUploadItems.map((item) => {
        'id': item.id,
        'localPath': item.localPath,
        'fileName': item.fileName,
        'fileSize': item.fileSize,
        'statusIndex': item.status.index,
        'progress': item.progress,
        'uploadedUrl': item.uploadedUrl,
        'errorMessage': item.errorMessage,
      }).toList();

      final draftData = {
        'requirement1': _requirementController1.text,
        'requirement2': _requirementController2.text,
        'uploadedUrls': _uploadedUrls,
        'fileItems': fileItemsData,
      };

      final String draftJson = jsonEncode(draftData);
      await prefs.setString(draftKey, draftJson);
      AppLogger.d('Draft saved for order ${widget.order.id}');
    } catch (e) {
      AppLogger.d('Error saving draft: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存草稿失败')), // Localize this
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
      AppLogger.d('Draft cleared for order ${widget.order.id}');
    } catch (e) {
      AppLogger.d('Error clearing draft: $e');
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
    final colorScheme = Theme.of(context).colorScheme;
    // Assuming only one item per order for requirement submission view, adjust if needed
    final item = widget.order.items.isNotEmpty ? widget.order.items.first : null;

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
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Card(
          // 使用统一Card主题
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Product Info ---
                if (item != null)
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      child: Image.network(
                        item.imageUrl,
                        width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    title: Text(item.productName, style: textTheme.titleSmall),
                    subtitle: Text(item.skuName ?? '', style: textTheme.bodySmall),
                    trailing: Text('${RegionConfig.currencySymbol}${item.price.toStringAsFixed(2)}', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    contentPadding: EdgeInsets.zero,
                  ),
                if (item != null) const Divider(height: 24),

                // --- Requirements Section ---
                Text('要求提交', style: textTheme.titleMedium),
                const SizedBox(height: AppDimensions.spacingSm),
                // 动态显示商品要求
                _buildRequirementFields(context),

                const SizedBox(height: AppDimensions.spacingXxl),

                // --- Attachments Section ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('附件上传', style: textTheme.titleMedium),
                          const SizedBox(height: AppDimensions.spacingXs),
                          Text(
                            '最多${_maxFileCount}个文件，单个文件不超过${_maxFileSize ~/ (1024 * 1024)}MB',
                            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (_fileUploadItems.length < _maxFileCount)
                      TextButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('添加'),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMd),
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
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          border: Border.all(color: AppColors.borderPrimary),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.textTertiary),
                              const SizedBox(height: AppDimensions.spacingSm),
                              Text(
                                '点击此处选择文件',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppDimensions.spacingXxl),

                // --- Action Buttons for this Form ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // --- Submit Requirements Button ---
                    BlocSelector<OrderDetailBloc, OrderDetailState, bool>(
                      selector: (state) => state is OrderDetailLoaded && state.isSubmittingRequirements,
                      builder: (context, isSubmitting) {
                        return ElevatedButton(
                          onPressed: isSubmitting ? null : () async {
                            // 检查是否所有文件都已上传完成
                            final hasUploadingFiles = _fileUploadItems.any(
                              (item) => item.status == FileUploadStatus.uploading
                            );

                            if (hasUploadingFiles) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('请等待文件上传完成')),
                              );
                              return;
                            }

                            // 检查是否有上传失败的文件
                            final failedFiles = _fileUploadItems.where(
                              (item) => item.status == FileUploadStatus.failed
                            ).toList();

                            if (failedFiles.isNotEmpty) {
                              // 显示重试选项
                              final shouldRetry = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('文件上传失败'),
                                  content: Text('有${failedFiles.length}个文件上传失败，是否重试？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('移除失败文件'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('重试上传'),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldRetry == true) {
                                // 重试上传失败的文件
                                for (final item in failedFiles) {
                                  final index = _fileUploadItems.indexOf(item);
                                  if (index != -1) {
                                    _retryUpload(index);
                                  }
                                }
                                return;
                              } else if (shouldRetry == false) {
                                // 移除失败的文件
                                setState(() {
                                  _fileUploadItems.removeWhere(
                                    (item) => item.status == FileUploadStatus.failed
                                  );
                                });
                              } else {
                                return; // 用户取消对话框
                              }
                            }

                            // --- Construct feature data ---
                            final item = widget.order.items.isNotEmpty ? widget.order.items.first : null;
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
                                const SnackBar(content: Text('错误：无法获取商品 ID')),
                              );
                              return;
                            }

                            // --- Dispatch Event ---
                            context.read<OrderDetailBloc>().add(
                                SubmitRequirementsSubmitted(
                                  orderId: widget.order.id.toString(),
                                  productId: productId, // Pass productId
                                  feature: featureData, // Pass structured feature data
                                  attachmentPaths: _uploadedUrls, // 使用已上传的URL列表
                                ),
                              );
                            AppLogger.d('Confirm Submission Tapped');

                            // 成功提交后清除草稿
                            _clearDraft();
                          },
                          child: isSubmitting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('确认提交'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for seller question text style
  Widget _buildSellerQuestion(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  // 动态构建要求字段
  Widget _buildRequirementFields(BuildContext context) {
    // 获取商品信息
    final item = widget.order.items.isNotEmpty ? widget.order.items.first : null;
    if (item == null) {
      return const Text('暂无商品信息');
    }

    // TODO: 需要实现以下功能：
    // 1. 调用后端API获取商品的ProductMaterials（商品材料问题列表）
    // 2. 根据ProductMaterials动态生成输入框
    // 3. 将用户填写的答案映射到feature字段的question-answer结构

    // 临时解决方案：显示通用问题
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示选择的服务信息
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: Text(
                  '您选择的服务：${_getLocalizedSkuName(item.skuName)} - ¥${item.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),

        // 问题1：需求描述
        _buildSellerQuestion(context, '1. 请详细描述您的需求'),
        TextField(
          controller: _requirementController1,
          decoration: InputDecoration(
            hintText: '请尽可能详细地描述您的需求，包括具体要求、期望效果等',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
            filled: true,
            fillColor: AppColors.backgroundSecondary,
            contentPadding: const EdgeInsets.all(AppDimensions.spacingMd),
            helperText: '如需提供参考资料，可在下方附件区域上传',
            helperStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: AppDimensions.spacingLg),

        // 问题2：补充说明
        _buildSellerQuestion(context, '2. 补充说明（选填）'),
        TextField(
          controller: _requirementController2,
          decoration: InputDecoration(
            hintText: '如有其他补充说明或特殊要求，请在此填写',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
            filled: true,
            fillColor: AppColors.backgroundSecondary,
            contentPadding: const EdgeInsets.all(AppDimensions.spacingMd),
          ),
          maxLines: 3,
        ),

        const SizedBox(height: AppDimensions.spacingMd),
        // 提示信息
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingSm),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber, size: 14, color: AppColors.warning),
              const SizedBox(width: AppDimensions.spacingXs),
              Expanded(
                child: Text(
                  '请认真填写需求，提交后卖家将根据您的需求开始服务',
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
  String _getLocalizedSkuName(String? skuName) {
    if (skuName == null) return "基础服务";

    // TODO: 这里需要从商品的本地化数据中获取中文名称
    final Map<String, String> skuNameMap = {
      'Basic Tier': '基础套餐',
      'Standard Tier': '标准套餐',
      'Premium Tier': '高级套餐',
      'Professional Tier': '专业套餐',
      'Enterprise Tier': '企业套餐',
    };

    return skuNameMap[skuName] ?? skuName;
  }

  // --- File Picking Logic ---
  Future<void> _pickFiles() async {
    if (_fileUploadItems.length >= _maxFileCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能上传$_maxFileCount个附件')),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'pdf', 'doc', 'docx',
                           'xls', 'xlsx', 'ppt', 'pptx', 'zip', 'rar', '7z', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final remainingSlots = _maxFileCount - _fileUploadItems.length;
        final filesToAdd = result.files.take(remainingSlots);

        for (final file in filesToAdd) {
          if (file.path != null && file.size != null) {
            final fileItem = FileUploadItem(
              id: DateTime.now().millisecondsSinceEpoch.toString() + '_${file.name}',
              localPath: file.path!,
              fileName: file.name,
              fileSize: file.size!,
            );

            setState(() {
              _fileUploadItems.add(fileItem);
            });
          }
        }
      }
    } catch (e) {
      AppLogger.d('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择文件失败: ${e.toString()}')),
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
        SnackBar(content: Text('已达到最大重试次数（$_maxRetryCount次）')),
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

  // --- Helper method to get file icon based on extension ---
  IconData _getFileIcon(String fileName) {
    final extension = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    switch (extension) {
      case 'pdf': return Icons.picture_as_pdf_outlined;
      case 'doc': case 'docx': return Icons.description_outlined;
      case 'xls': case 'xlsx': return Icons.assessment_outlined;
      case 'ppt': case 'pptx': return Icons.slideshow_outlined;
      case 'jpg': case 'jpeg': case 'png': case 'gif': case 'bmp': return Icons.image_outlined;
      case 'zip': case 'rar': case '7z': return Icons.archive_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }
}
