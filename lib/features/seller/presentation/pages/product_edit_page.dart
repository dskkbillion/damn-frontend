import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import '../widgets/image_preview_page.dart';
import 'product_preview_page.dart';

// 导入重构后的数据模型
import 'package:dskk_flutter_refactor/features/seller/domain/entities/product_edit_models.dart';
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/service_tier_models.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/seller_page_skeleton.dart';

// 输入验证常量
class ValidationConstants {
  static const double maxPrice = 999999.99; // 最大价格
  static const int maxDeliveryDays = 365; // 最大交付天数
  static const int maxEditNum = 99; // 最大修改次数
  static const int maxAttributeNameLength = 8; // 属性名称最大长度
  static const int maxAttributeValueLength = 50; // 属性值最大长度
}



// 扩展的产品表单数据，包含额外的字段
class ExtendedProductFormData extends ProductFormData {
  final int? productId;
  final List<String> images;
  
  const ExtendedProductFormData({
    required super.name,
    required super.description,
    required super.price,
    super.categoryId,
    required super.variants,
    required super.productMaterials,
    required super.detailContent,
    required super.qaList,
    required super.buyerInfoItems,
    required super.successCases,
    this.productId,
    required this.images,
  });
}

/// 商品编辑页面
class ProductEditPage extends StatefulWidget {
  /// 商品ID（编辑模式）
  final String? productId;
  
  /// 草稿保存成功回调
  final VoidCallback? onDraftSaved;
  
  /// 是否为预览模式（只读）
  final bool isPreviewMode;

  /// 构造函数
  const ProductEditPage({
    super.key,
    this.productId,
    this.onDraftSaved,
    this.isPreviewMode = false,
  });

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  /// BLoC实例
  late final ProductEditBloc _bloc;
  
  /// 商品名称控制器
  final TextEditingController _nameController = TextEditingController();
  
  /// 商品描述控制器
  final TextEditingController _descriptionController = TextEditingController();
  
  /// 防止重复返回的标志
  bool _isReturning = false;
  
  /// 属性输入控制器映射
  final Map<String, TextEditingController> _attributeControllers = {};
  
  /// QA控制器管理（key: qaIndex_type, value: controller）
  final Map<String, TextEditingController> _qaControllers = {};

  
  /// 服务档位管理
  late ProductServiceTiers _serviceTiers;
  
  /// 当前选中的服务档位
  ServiceTier _selectedTier = ServiceTier.basic;
  
  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();
  
  
  

  
  /// QA相关状态
  final List<QAPair> _qaList = [];
  bool _isQAExpanded = false;
  
  /// 买家信息相关状态
  final List<BuyerInfoItem> _buyerInfoItems = [];
  bool _isBuyerInfoExpanded = false;
  
  /// 数据同步标志位
  bool _isInitialDataLoad = true;
  
  /// 成功案例相关状态
  // Success cases are now managed in BLoC state
  // final List<SuccessCase> _successCases = []; // Removed - now in BLoC
  
  /// 表单键
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  /// 图片选择器
  final ImagePicker _imagePicker = ImagePicker();
  
  /// 统一的输入框边框样式
  InputDecoration get _lightBorderDecoration => InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.borderInput, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.borderInput, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.sellerAccent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    filled: true,
    fillColor: AppColors.backgroundCard,
  );

  /// 添加表单验证错误状态变量
  Map<String, String> _formErrors = {};
  
  /// 系统属性控制器映射
  final Map<String, TextEditingController> _systemControllers = {};
  
  /// 防抖计时器
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    
    print('[ProductEditPage] initState called with productId: ${widget.productId}, isPreviewMode: ${widget.isPreviewMode}');
    
    // 从DI容器获取BLoC实例
    _bloc = getIt<ProductEditBloc>();
    
    // 初始化服务档位
    _serviceTiers = ProductServiceTiers();
    
    // 解析商品ID
    final productIdInt = widget.productId != null ? int.tryParse(widget.productId!) : null;
    print('[ProductEditPage] Parsed productId as int: $productIdInt');
    
    // 初始化页面
    print('[ProductEditPage] Initializing ProductEdit with productId: $productIdInt, isPreviewMode: ${widget.isPreviewMode}');
    _bloc.add(InitializeProductEdit(
      productId: productIdInt,
    ));
    
    // 监听输入框变化，自动检查是否有变更（预览模式下不需要）
    if (!widget.isPreviewMode) {
      _nameController.addListener(_onFormFieldChanged);
      _descriptionController.addListener(_onFormFieldChanged);
    }
    
    // 监听状态变化，更新控制器（预览模式和编辑模式都需要）
    _bloc.stream.listen((state) {
      print('[ProductEditPage] State changed - isLoading: ${state.isLoading}, hasProduct: ${state.product != null}, isPreviewMode: ${widget.isPreviewMode}');
      if (!state.isLoading && state.product != null) {
        print('[ProductEditPage] Syncing data from state - productName: ${state.formData.name}');
        _syncDataFromState(state.formData);
        // 设置初始数据用于变更检测（仅在编辑模式下）
        if (state.initialFormData == null && !widget.isPreviewMode) {
          _bloc.add(SetInitialFormData(initialData: state.formData));
        }
      }
    });
  }



  /// 添加QA对
  void _addQAPair() {
    setState(() {
      _qaList.add(QAPair(question: '', answer: ''));
    });
  }
  
  /// 删除QA对
  void _removeQAPair(int index) {
    setState(() {
      _qaList.removeAt(index);
      // 清理未使用的QA控制器
      _cleanupUnusedQAControllers();
    });
  }
  
  /// 更新QA对
  void _updateQAPair(int index, String question, String answer) {
    setState(() {
      _qaList[index].question = question;
      _qaList[index].answer = answer;
    });
    // 触发变更检测
    _onFormFieldChanged();
  }

  /// 添加买家信息项
  void _addBuyerInfoItem(BuyerInfoType type, String label, String description, bool isRequired) {
    setState(() {
      _buyerInfoItems.add(BuyerInfoItem(
        type: type,
        label: label,
        description: description,
        isRequired: isRequired,
      ));
    });
    // 触发变更检测
    _onFormFieldChanged();
  }
  
  /// 更新买家信息项
  void _updateBuyerInfoItem(int index, String label, String description, bool isRequired) {
    setState(() {
      _buyerInfoItems[index] = BuyerInfoItem(
        type: _buyerInfoItems[index].type,
        label: label,
        description: description,
        isRequired: isRequired,
      );
    });
    // 触发变更检测
    _onFormFieldChanged();
  }
  
  /// 删除买家信息项
  void _removeBuyerInfoItem(int index) {
    setState(() {
      _buyerInfoItems.removeAt(index);
    });
    // 触发变更检测
    _onFormFieldChanged();
  }

  /// 添加成功案例 - 简化版本
  void _addSuccessCase(String imagePath, String title, String description) {
    // Simply add to BLoC, which will handle upload automatically
    _bloc.add(AddSuccessCaseImage(
      imagePath: imagePath,
      title: title,
      description: description,
    ));
    
    // 触发变更检测
    _onFormFieldChanged();
  }
  
  // 成功案例图片上传功能已移至BLoC中自动处理
  // 参见 ProductEditBloc 中的 AddSuccessCaseImage 事件处理
  
  /// 更新成功案例 - 简化版本
  void _updateSuccessCase(String caseId, {String? imagePath, String? title, String? description}) {
    // Update through BLoC
    _bloc.add(UpdateSuccessCase(
      caseId: caseId,
      imagePath: imagePath,
      title: title,
      description: description,
    ));
    
    // 触发变更检测
    _onFormFieldChanged();
  }
  
  /// 删除成功案例 - 简化版本
  void _removeSuccessCase(String caseId) {
    _bloc.add(RemoveSuccessCase(caseId: caseId));
    // 触发变更检测
    _onFormFieldChanged();
  }

  @override
  void didUpdateWidget(ProductEditPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果产品ID发生变化，重新初始化页面
    if (oldWidget.productId != widget.productId) {
      print('[ProductEditPage] Product ID changed from ${oldWidget.productId} to ${widget.productId}, reinitializing...');
      
      // 重置数据同步标志位
      _isInitialDataLoad = true;
      
      // 清空本地列表
      _qaList.clear();
      _buyerInfoItems.clear();
      
      // 解析新的商品ID
      final productIdInt = widget.productId != null ? int.tryParse(widget.productId!) : null;
      
      // 重新初始化页面
      _bloc.add(InitializeProductEdit(
        productId: productIdInt,
      ));
    }
  }
  
  @override
  void dispose() {
    // 仅在编辑模式下移除监听器（预览模式下没有添加）
    if (!widget.isPreviewMode) {
      _nameController.removeListener(_onFormFieldChanged);
      _descriptionController.removeListener(_onFormFieldChanged);
    }
    _nameController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose(); // 释放滚动控制器
    
    // 释放防抖计时器
    _debounceTimer?.cancel();
    
    // 释放所有属性控制器
    for (var controller in _attributeControllers.values) {
      controller.dispose();
    }
    _attributeControllers.clear();
    
    // 释放所有系统属性控制器
    for (var controller in _systemControllers.values) {
      controller.dispose();
    }
    _systemControllers.clear();
    
    // 释放所有QA控制器
    for (var controller in _qaControllers.values) {
      controller.dispose();
    }
    _qaControllers.clear();
    
    // 释放所有服务档位控制器
    _serviceTiers.dispose();
    
    super.dispose();
  }

  /// 表单字段变化时检查变更
  void _onFormFieldChanged() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        // 同步新功能状态到表单数据
        _syncAdditionalFormData();
        _bloc.add(const CheckForUnsavedChanges());
      }
    });
  }

  /// 同步额外功能的表单数据
  void _syncAdditionalFormData() {
    // 同步QA列表
    final qaListJson = _qaList.map((qa) => {
      'id': qa.id,
      'question': qa.question,
      'answer': qa.answer,
    }).toList();
    _bloc.add(UpdateFormField(fieldName: 'qaList', value: qaListJson));
    
    // 同步买家信息列表
    final buyerInfoJson = _buyerInfoItems.map((item) => {
      'type': item.type.name,
      'label': item.label,
      'description': item.description,
      'isRequired': item.isRequired,
    }).toList();
    _bloc.add(UpdateFormField(fieldName: 'buyerInfoItems', value: buyerInfoJson));
    
    // Success cases are now synced from BLoC state automatically
    // No need to sync manually as they are managed in BLoC
  }

  /// 处理返回操作
  Future<void> _handleBackPress() async {
    _bloc.add(const CheckForUnsavedChanges());
    
    // 等待状态更新
    await Future.delayed(const Duration(milliseconds: 100));
    
    final hasChanges = _bloc.state.hasUnsavedChanges;
    
    if (hasChanges) {
      final shouldSave = await _showSaveDraftDialog();
      
      if (shouldSave == true) {
        // 同步本地数据到BLoC
        _syncLocalDataToBLoC();
        
        // 构建并同步服务档位数据
        List<ProductOptionValue> variants = _serviceTiers.toProductOptionValues();
        _bloc.add(UpdateFormField(fieldName: 'variants', value: variants));
        
        // 设置基础价格为基础档的价格
        _bloc.add(UpdateFormField(
          fieldName: 'price', 
          value: _serviceTiers.basic.price
        ));
        
        // 保存草稿
        _bloc.add(const SaveProductDraft());
        
        // 等待保存完成
        await _bloc.stream
            .firstWhere((state) => !state.isSavingDraft)
            .timeout(const Duration(seconds: 10));
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (shouldSave == false) {
        // 直接退出
        Navigator.of(context).pop();
      }
      // shouldSave == null 表示取消
    } else {
      // 没有变更，直接退出
      Navigator.of(context).pop();
    }
  }

  /// 显示保存草稿对话框
  Future<bool?> _showSaveDraftDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).seller_product_edit_unsaved_changes_title ?? 'Unsaved Changes Detected'),
        content: Text(AppLocalizations.of(context).seller_product_edit_unsaved_changes_message ?? 'You have unsaved content. Save as draft?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(AppLocalizations.of(context).seller_product_edit_cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).seller_product_edit_discard ?? 'Discard'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sellerAccent,
              foregroundColor: AppColors.onPrimary,
            ),
            child: Text(AppLocalizations.of(context).product_edit_save_draft ?? 'Save Draft'),
          ),
        ],
      ),
    );
  }

  /// 从BLoC状态同步数据到页面组件
  void _syncDataFromState(ProductFormData formData) {
    print('[ProductEditPage] _syncDataFromState called with name: "${formData.name}", description: "${formData.description}", variants count: ${formData.variants.length}');
    print('[ProductEditPage] isPreviewMode: ${widget.isPreviewMode}, productId: ${widget.productId}');
    print('[ProductEditPage] Current controller values - name: "${_nameController.text}", description: "${_descriptionController.text}"');
    
    // 更新基本文本字段
    if (mounted) {
      setState(() {
        _nameController.text = formData.name;
        _descriptionController.text = formData.description;
      });
      print('[ProductEditPage] Updated text controllers - name: "${_nameController.text}", description: "${_descriptionController.text}"');
    }
    
    // 如果有变体数据，更新到本地服务档位（编辑模式和预览模式都需要）
    if (formData.variants.isNotEmpty && (!_bloc.state.isCreateMode || widget.isPreviewMode)) {
      print('[ProductEditPage] Updating service tiers from ${formData.variants.length} variants');
      for (int i = 0; i < formData.variants.length; i++) {
        final variant = formData.variants[i];
        print('[ProductEditPage] Variant $i: name="${variant.name}", price=${variant.price}, sellingPrice=${variant.sellingPrice}');
      }
      
      if (mounted) {
        setState(() {
          _serviceTiers = ProductServiceTiers.fromProductOptionValues(formData.variants);
        });
        print('[ProductEditPage] Updated service tiers from variants:');
        print('[ProductEditPage] - Basic: price=${_serviceTiers.basic.price}, delivery=${_serviceTiers.basic.deliveryDay}');
        print('[ProductEditPage] - Standard: price=${_serviceTiers.standard.price}, delivery=${_serviceTiers.standard.deliveryDay}'); 
        print('[ProductEditPage] - Premium: price=${_serviceTiers.premium.price}, delivery=${_serviceTiers.premium.deliveryDay}');
      }
    }
    
    // 同步QA列表数据和买家信息列表数据
    if (mounted) {
      // 只在初始加载时同步（避免覆盖用户正在编辑的数据）
      if (_isInitialDataLoad) {
        setState(() {
          // 同步QA列表
          _qaList.clear();
          for (final qaMap in formData.qaList) {
            try {
              // 确保数据格式正确
              final qaData = <String, dynamic>{
                'id': qaMap['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                'question': qaMap['question'] ?? '',
                'answer': qaMap['answer'] ?? '',
              };
              _qaList.add(QAPair.fromJson(qaData));
              print('[ProductEditPage] Added QA item: question="${qaMap['question']}", answer="${qaMap['answer']}"');
            } catch (e) {
              print('[ProductEditPage] Error parsing QA data: $e, qaMap: $qaMap');
            }
          }
          // 清理未使用的QA控制器
          _cleanupUnusedQAControllers();
          print('[ProductEditPage] Synced ${_qaList.length} QA items from formData');
          
          // 同步买家信息列表
          _buyerInfoItems.clear();
          for (final buyerInfoMap in formData.buyerInfoItems) {
            try {
              _buyerInfoItems.add(BuyerInfoItem.fromJson(buyerInfoMap));
              print('[ProductEditPage] Added buyer info item: type="${buyerInfoMap['type']}", label="${buyerInfoMap['label']}"');
            } catch (e) {
              print('[ProductEditPage] Error parsing buyer info data: $e, buyerInfoMap: $buyerInfoMap');
            }
          }
          print('[ProductEditPage] Synced ${_buyerInfoItems.length} buyer info items from formData');
          
          // 标记初始数据已加载
          _isInitialDataLoad = false;
        });
      }
    }
    
    // Success cases are now managed in BLoC state
    // No need to sync here
    
    print('[ProductEditPage] Synced data from state:');
    print('  - QA items: ${_qaList.length}');
    print('  - Buyer info items: ${_buyerInfoItems.length}');
    print('  - Success cases: managed in BLoC');
    print('  - Variants: ${formData.variants.length}');
  }

  /// 将页面组件的本地数据同步到BLoC状态
  void _syncLocalDataToBLoC() {
    print('[ProductEditPage] Syncing local data to BLoC:');
    print('  - QA items: ${_qaList.length}');
    print('  - Buyer info items: ${_buyerInfoItems.length}');
    print('  - Success cases: managed in BLoC');
    
    // 直接调用现有的同步方法
    _syncAdditionalFormData();
  }

  /// 选择服务档位
  void _selectServiceTier(ServiceTier tier) {
    setState(() {
      _selectedTier = tier;
    });
  }



  /// 选择图片
  Future<void> _pickImages({bool replaceExisting = false}) async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      final List<String> newImagePaths = pickedFiles.map((file) => file.path).toList();
      
      // 如果是追加模式且已有图片，合并新旧图片路径
      if (!replaceExisting && _bloc.state.selectedImagePaths.isNotEmpty) {
        final List<String> combinedPaths = [
          ..._bloc.state.selectedImagePaths,
          ...newImagePaths,
        ];
        
        // 确保不超过9张图片的限制
        if (combinedPaths.length > 9) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).seller_product_edit_max_images ?? 'Maximum 9 images allowed'),
              backgroundColor: AppColors.warning,
            ),
          );
          _bloc.add(SelectProductImages(imagePaths: combinedPaths.sublist(0, 9)));
        } else {
          _bloc.add(SelectProductImages(imagePaths: combinedPaths));
        }
      } else {
        // 替换模式或之前没有选择图片
        _bloc.add(SelectProductImages(imagePaths: newImagePaths));
      }
    }
  }

  /// 验证并提交表单
  void _submitForm() {
    // 重置表单错误
    setState(() {
      _formErrors = {};
    });
    
    // 验证基本信息
    bool isValid = true;
    
    // 验证商品名称
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _formErrors['name'] = AppLocalizations.of(context).product_edit_validation_name_required ?? 'Please enter service name';
      });
      isValid = false;
    }
    
    // 验证商品描述
    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _formErrors['description'] = AppLocalizations.of(context).product_edit_validation_description_required ?? 'Please enter service description';
      });
      isValid = false;
    }
    
    // 验证商品图片
    // #379: 校验需同时考虑已成功上传到 OSS 的图片(uploadedImageUrls)，
    // 否则上传成功后 selectedImagePaths 被清空、images 为空会误判"未上传图片"。
    if (_bloc.state.selectedImagePaths.isEmpty &&
        _bloc.state.uploadedImageUrls.isEmpty &&
        (_bloc.state.product?.images.isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).product_edit_at_least_one_image ?? 'Please upload at least one product image'),
          backgroundColor: AppColors.error,
        ),
      );
      isValid = false;
    }
    
        // 验证每个服务档位的价格
    final tiers = [_serviceTiers.basic, _serviceTiers.standard, _serviceTiers.premium];
    for (int i = 0; i < tiers.length; i++) {
      final tier = tiers[i];
      if (tier.price <= 0) {
        setState(() {
          _formErrors['price_${tier.tier.name}'] = AppLocalizations.of(context).seller_product_edit_price_required(tier.tier.displayName) ?? '${tier.tier.displayName} price must be greater than 0';
        });
        isValid = false;
      }
    }
    
    if (!isValid) {
      // 滚动到第一个错误字段
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).seller_product_edit_form_incomplete ?? 'Form data incomplete. Please check highlighted fields.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // 所有验证通过，先同步本地数据到BLoC，然后构建规格数据并提交
    _syncLocalDataToBLoC();
    
    List<ProductOptionValue> variants = _serviceTiers.toProductOptionValues();
    
    // 更新表单数据中的规格
    _bloc.add(UpdateFormField(fieldName: 'variants', value: variants));
    
    // 设置基础价格为基础档的价格
      _bloc.add(UpdateFormField(
        fieldName: 'price', 
      value: _serviceTiers.basic.price
      ));
    
    // 提交表单
    _bloc.add(const SubmitProductForm());
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isPreviewMode 
            ? AppLocalizations.of(context).product_edit_preview_product ?? 'Preview Product' 
            : (widget.productId == null ? AppLocalizations.of(context).product_edit_publish_product ?? 'Publish Product' : AppLocalizations.of(context).product_edit_title_edit ?? 'Edit Product')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (widget.isPreviewMode) {
                Navigator.of(context).pop();
              } else {
                await _handleBackPress();
              }
            },
          ),
          actions: widget.isPreviewMode ? [
            // 预览模式下显示编辑按钮
            TextButton.icon(
              onPressed: () {
                // 跳转到编辑模式
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ProductEditPage(
                      productId: widget.productId,
                      isPreviewMode: false,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: Text(AppLocalizations.of(context).product_management_action_edit ?? 'Edit'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.sellerAccent,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(width: 16),
          ] : [
            // 编辑模式下显示预览、保存草稿和发布按钮
            BlocBuilder<ProductEditBloc, ProductEditState>(
              bloc: _bloc,
              buildWhen: (previous, current) => 
                previous.product?.status != current.product?.status,
              builder: (context, state) {
                // 判断是否是草稿商品
                final isDraft = state.product?.status == ProductStatus.draft;
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 预览按钮 - 草稿商品不显示
                    if (!isDraft) ...[
                      IconButton(
                        onPressed: () => _previewProduct(),
                        icon: const Icon(Icons.preview),
                        tooltip: AppLocalizations.of(context).product_edit_preview_product ?? 'Preview',
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // 保存草稿按钮
                    TextButton.icon(
                      onPressed: state.isSavingDraft ? null : () {
                        // 同步本地数据到BLoC
                        _syncLocalDataToBLoC();
                        
                        // 构建并同步服务档位数据
                        List<ProductOptionValue> variants = _serviceTiers.toProductOptionValues();
                        _bloc.add(UpdateFormField(fieldName: 'variants', value: variants));
                        
                        // 设置基础价格为基础档的价格
                        _bloc.add(UpdateFormField(
                          fieldName: 'price', 
                          value: _serviceTiers.basic.price
                        ));
                        
                        // 添加调试日志
                        print('[ProductEditPage] Saving draft with price: ${_serviceTiers.basic.price}');
                        print('[ProductEditPage] Variants count: ${variants.length}');
                        for (var i = 0; i < variants.length; i++) {
                          print('[ProductEditPage] Variant $i: ${variants[i].name} - price: ${variants[i].sellingPrice}');
                        }
                        
                        // 保存草稿
                        _bloc.add(const SaveProductDraft());
                      },
                      icon: state.isSavingDraft
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_alt),
                      label: Text(state.hasUnsavedChanges
                          ? (AppLocalizations.of(context).seller_product_edit_draft_unsaved_label ?? 'Draft*')
                          : (AppLocalizations.of(context).seller_product_edit_draft_label ?? 'Draft')),
                      style: TextButton.styleFrom(
                        foregroundColor: state.hasUnsavedChanges ? AppColors.warning : AppColors.textTertiary,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            TextButton(
              onPressed: _submitForm,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.sellerAccent,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(AppLocalizations.of(context).seller_product_edit_publish ?? 'Publish'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: BlocProvider<ProductEditBloc>(
          create: (context) => _bloc,
          child: BlocConsumer<ProductEditBloc, ProductEditState>(
            listener: (context, state) {
              if (state.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? (AppLocalizations.of(context).seller_product_edit_operation_failed ?? 'Operation failed')),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state.isDraftSaveSuccess && !_isReturning) {
                // 先检查是否已经mounted，避免在dispose后执行
                if (!mounted) return;
                
                // 设置标志，防止重复返回
                _isReturning = true;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).seller_product_edit_draft_saved ?? 'Draft saved successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // 通知父页面刷新草稿列表
                widget.onDraftSaved?.call();
                // 立即返回，不再延迟
                // 返回true表示需要刷新列表
                Navigator.of(context).pop(true);
              } else if (state.isSubmitSuccess) {
                // 先检查是否已经mounted，避免在dispose后执行
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.isCreateMode
                      ? (AppLocalizations.of(context).seller_product_edit_publish_success ?? 'Service published successfully!')
                      : (AppLocalizations.of(context).seller_product_edit_update_success ?? 'Service updated successfully')),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2), // 缩短显示时间
                  ),
                );
                // 立即返回，不再延迟
                // 返回时带上刷新标志，让商品管理页面知道需要刷新
                Navigator.of(context).pop(true);
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const SellerPageSkeleton(variant: SellerSkeletonVariant.form);
              }
              
              return GestureDetector(
                onTap: () {
                  // 点击空白处取消键盘焦点
                  FocusScope.of(context).unfocus();
                },
                child: Stack(
                  children: [
                    _buildFormContent(state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  /// 构建表单内容
  Widget _buildFormContent(ProductEditState state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController, // 添加滚动控制器
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息表单
            _buildBasicInfoForm(state),
            
            // 服务档位设置
            _buildServiceTiersSection(),
            
            // 买家需要提供的信息
            _buildBuyerInfoSection(state),
            
            // 常见问题编辑
            _buildCommonQuestionsSection(state),
            
            // 成功案例
            _buildSuccessCasesSection(state),
            
            // 商品图片上传
            _buildImageUploadSection(state),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 构建基本信息表单
  Widget _buildBasicInfoForm(ProductEditState state) {
    return Container(
      color: AppColors.backgroundCard,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 服务名称
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
              controller: _nameController,
              readOnly: widget.isPreviewMode,
              decoration: _lightBorderDecoration.copyWith(
                hintText: AppLocalizations.of(context).seller_product_edit_service_name_hint ?? 'Service Name',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                    errorText: _formErrors['name'],
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.error, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                    ),
              ),
              onChanged: (value) {
                    // 输入时清除该字段的错误
                    if (_formErrors.containsKey('name')) {
                      setState(() {
                        _formErrors.remove('name');
                      });
                    }
                _bloc.add(UpdateFormField(fieldName: 'name', value: value));
              },
                ),
              ],
            ),
          ),
          
          // 服务描述
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: _descriptionController,
              readOnly: widget.isPreviewMode,
              decoration: _lightBorderDecoration.copyWith(
                hintText: AppLocalizations.of(context).seller_product_edit_description_hint ?? 'Describe your service details...',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                errorText: _formErrors['description'],
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.error, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                ),
              ),
              maxLines: 3,
              onChanged: (value) {
                // 输入时清除该字段的错误
                if (_formErrors.containsKey('description')) {
                  setState(() {
                    _formErrors.remove('description');
                  });
                }
                _bloc.add(UpdateFormField(fieldName: 'description', value: value));
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建服务档位设置区域
  Widget _buildServiceTiersSection() {
    return Container(
      color: AppColors.backgroundCard,
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).product_edit_service_tiers ?? 'Service Tier Settings',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // 档位选择标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTierSelector(ServiceTier.basic),
                const SizedBox(width: 8),
                _buildTierSelector(ServiceTier.standard),
                const SizedBox(width: 8),
                _buildTierSelector(ServiceTier.premium),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 档位价格编辑
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTierPriceEditor(),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  

  

  

  
  /// 构建常见问题部分
  Widget _buildCommonQuestionsSection(ProductEditState state) {
    return Container(
      color: AppColors.backgroundCard,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏 - 整个区域可点击
          InkWell(
            onTap: () {
              setState(() {
                _isQAExpanded = !_isQAExpanded;
              });
            },
      child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).seller_product_edit_faq_title ?? 'FAQ Editor',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // QA数量指示器
                  if (_qaList.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
                        color: AppColors.sellerAccentLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context).seller_product_edit_faq_count(_qaList.length) ?? '${_qaList.length} questions',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.sellerAccent,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                      // 展开/折叠图标
                      Icon(
                        _isQAExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
              ),
            ),
          ),
          
          // 展开的内容
          if (_isQAExpanded) ...[
            const SizedBox(height: 16),
            
            // QA列表
            if (_qaList.isNotEmpty)
              ...List.generate(_qaList.length, (index) => _buildQAItem(index)),
            
            // 添加QA按钮 - 预览模式下隐藏
            if (!widget.isPreviewMode) Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              child: OutlinedButton.icon(
                onPressed: _addQAPair,
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context).seller_product_edit_add_question ?? 'Add Question'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sellerAccent,
                  side: const BorderSide(color: AppColors.sellerAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 构建单个QA项
  Widget _buildQAItem(int index) {
    final qa = _qaList[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderInput),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 问题输入
          Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: widget.isPreviewMode,
                    decoration: _lightBorderDecoration.copyWith(
                    labelText: AppLocalizations.of(context).seller_product_edit_question_label ?? 'Question',
                    hintText: AppLocalizations.of(context).seller_product_edit_question_hint ?? 'Enter a question buyers may ask',
                    ),
                    controller: _getQAController(index, 'question', qa.question),
                    onChanged: widget.isPreviewMode ? null : (value) {
                    _updateQAPair(index, value, qa.answer);
                    },
                    // 优化中文输入法体验
                    enableIMEPersonalizedLearning: true,
                    keyboardType: TextInputType.text,
                  ),
                ),
              const SizedBox(width: 8),
              // 删除按钮 - 预览模式下隐藏
              if (!widget.isPreviewMode) IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _removeQAPair(index),
                tooltip: AppLocalizations.of(context).seller_product_edit_delete_question ?? 'Delete Question',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 答案输入
          TextField(
            readOnly: widget.isPreviewMode,
                  decoration: _lightBorderDecoration.copyWith(
              labelText: AppLocalizations.of(context).seller_product_edit_answer_label ?? 'Answer',
              hintText: AppLocalizations.of(context).seller_product_edit_answer_hint ?? 'Enter the answer',
                  ),
            controller: _getQAController(index, 'answer', qa.answer),
            maxLines: 3,
                  onChanged: widget.isPreviewMode ? null : (value) {
              _updateQAPair(index, qa.question, value);
            },
            // 优化中文输入法体验
            enableIMEPersonalizedLearning: true,
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }
  
  /// 构建买家需要提供的信息部分
  Widget _buildBuyerInfoSection(ProductEditState state) {
    return Container(
      color: AppColors.backgroundCard,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏 - 整个区域可点击
          InkWell(
            onTap: () {
              setState(() {
                _isBuyerInfoExpanded = !_isBuyerInfoExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
                AppLocalizations.of(context).seller_product_edit_buyer_info_title ?? 'Buyer Information Required',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
              Row(
                children: [
                  // 信息项数量指示器
                  if (_buyerInfoItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.sellerAccentLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context).seller_product_edit_buyer_info_count(_buyerInfoItems.length) ?? '${_buyerInfoItems.length} items',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.sellerAccent,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                      // 展开/折叠图标
                      Icon(
                        _isBuyerInfoExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
              ),
            ),
          ),
          
          // 说明文字
          if (!_isBuyerInfoExpanded)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderInput),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context).seller_product_edit_buyer_info_desc ?? 'Select the information types buyers need to provide',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
                ),
            ),
          ),
          
          // 展开的内容
          if (_isBuyerInfoExpanded) ...[
          const SizedBox(height: 16),
          
            // 信息类型选择网格
            _buildBuyerInfoTypeGrid(),
            
            // 已选择的信息项列表
            if (_buyerInfoItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).seller_product_edit_selected_items ?? 'Selected items:',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ..._buyerInfoItems.asMap().entries.map((entry) => 
                _buildBuyerInfoItem(entry.key, entry.value)
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// 构建信息类型选择网格
  Widget _buildBuyerInfoTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: BuyerInfoType.values.length,
      itemBuilder: (context, index) {
        final type = BuyerInfoType.values[index];
        return _buildInfoTypeCard(type);
      },
    );
  }

  /// 构建信息类型卡片
  Widget _buildInfoTypeCard(BuyerInfoType type) {
    return InkWell(
      onTap: () => _showAddBuyerInfoDialog(type),
      child: Container(
        padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
          border: Border.all(color: AppColors.sellerAccent),
                borderRadius: BorderRadius.circular(8),
          color: AppColors.backgroundCard,
        ),
        child: Row(
          children: [
            Icon(_getIconForInfoType(type), color: AppColors.sellerAccent),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                type.displayName,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取信息类型对应的图标
  IconData _getIconForInfoType(BuyerInfoType type) {
    switch (type) {
      case BuyerInfoType.text:
        return Icons.text_fields;
      case BuyerInfoType.image:
        return Icons.image;
      case BuyerInfoType.file:
        return Icons.attach_file;
      case BuyerInfoType.contact:
        return Icons.contact_phone;
      case BuyerInfoType.requirement:
        return Icons.description;
      case BuyerInfoType.reference:
        return Icons.link;
    }
  }

  /// 构建买家信息项
  Widget _buildBuyerInfoItem(int index, BuyerInfoItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderInput),
                borderRadius: BorderRadius.circular(8),
              ),
      child: Row(
                      children: [
          Icon(_getIconForInfoType(item.type), size: 20, color: AppColors.sellerAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (item.isRequired)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                          AppLocalizations.of(context).seller_product_edit_required ?? 'Required',
                          style: TextStyle(fontSize: 10, color: AppColors.error),
                            ),
                          ),
                      ],
                    ),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.sellerAccent),
                onPressed: () => _showEditBuyerInfoDialog(index, item),
                tooltip: AppLocalizations.of(context).seller_product_edit_edit_tooltip ?? 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _removeBuyerInfoItem(index),
                tooltip: AppLocalizations.of(context).seller_product_edit_delete_tooltip ?? 'Delete',
              ),
            ],
          ),
                      ],
                    ),
                  );
  }

  /// 显示添加买家信息对话框
  void _showAddBuyerInfoDialog(BuyerInfoType type) {
    final labelController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isRequired = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).seller_product_edit_add_info_title(type.displayName) ?? 'Add ${type.displayName} Info'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5, // 限制最大高度
              maxWidth: double.maxFinite,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: AppLocalizations.of(context).seller_product_edit_info_label ?? 'Info Label',
                      hintText: AppLocalizations.of(context).seller_product_edit_info_label_hint ?? 'e.g., Company Logo Design Requirements',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: AppLocalizations.of(context).seller_product_edit_info_description ?? 'Detailed Description',
                      hintText: AppLocalizations.of(context).seller_product_edit_info_description_hint ?? 'Describe the information buyers need to provide',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context).seller_product_edit_required_field ?? 'Required Field'),
                    value: isRequired,
                    onChanged: (value) {
                      setState(() {
                        isRequired = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).seller_product_edit_cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  _addBuyerInfoItem(
                    type,
                    labelController.text,
                    descriptionController.text,
                    isRequired,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).product_edit_please_enter_label ?? 'Please enter information label')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerAccent,
                foregroundColor: AppColors.onPrimary,
                ),
              child: Text(AppLocalizations.of(context).seller_product_edit_add ?? 'Add'),
          ),
        ],
        ),
      ),
    );
  }

  /// 显示编辑买家信息对话框
  void _showEditBuyerInfoDialog(int index, BuyerInfoItem item) {
    final labelController = TextEditingController(text: item.label);
    final descriptionController = TextEditingController(text: item.description);
    bool isRequired = item.isRequired;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).seller_product_edit_edit_info_title(item.type.displayName) ?? 'Edit ${item.type.displayName} Info'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5, // 限制最大高度
              maxWidth: double.maxFinite,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: AppLocalizations.of(context).seller_product_edit_info_label ?? 'Info Label',
                      hintText: AppLocalizations.of(context).seller_product_edit_info_label_hint ?? 'e.g., Company Logo Design Requirements',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: AppLocalizations.of(context).seller_product_edit_info_description ?? 'Detailed Description',
                      hintText: AppLocalizations.of(context).seller_product_edit_info_description_hint ?? 'Describe the information buyers need to provide',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context).seller_product_edit_required_field ?? 'Required Field'),
                    value: isRequired,
                    onChanged: (value) {
                      setState(() {
                        isRequired = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).seller_product_edit_cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  _updateBuyerInfoItem(
                    index,
                    labelController.text,
                    descriptionController.text,
                    isRequired,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).product_edit_please_enter_label ?? 'Please enter information label')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerAccent,
                foregroundColor: AppColors.onPrimary,
                ),
              child: Text(AppLocalizations.of(context).seller_product_edit_save ?? 'Save'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建成功案例部分
  Widget _buildSuccessCasesSection(ProductEditState state) {
    return Container(
      color: AppColors.onPrimary,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).product_edit_success_cases ?? 'Success Cases',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.successCases.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sellerAccentLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(context).seller_product_edit_cases_count(state.successCases.length) ?? '${state.successCases.length} cases',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.sellerAccent,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 成功案例网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.successCases.length + 1, // +1 for add button
            itemBuilder: (context, index) {
              if (index == state.successCases.length) {
                return _buildAddSuccessCaseButton();
              }
              return _buildSuccessCaseItem(state, index);
                },
              ),
            ],
          ),
    );
  }

  /// 构建添加成功案例按钮
  Widget _buildAddSuccessCaseButton() {
    return InkWell(
      onTap: _showAddSuccessCaseDialog,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderInput, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.backgroundSecondary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).seller_product_edit_add_case ?? 'Add Case',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建编辑对话框的图片
  Widget _buildEditDialogImage(String? localPath, String? imageUrl, bool imageChanged) {
    // 如果图片已更改，只显示本地图片
    if (imageChanged && localPath != null && localPath.isNotEmpty) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 32, color: AppColors.textTertiary),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context).seller_product_edit_image_load_failed ?? 'Image load failed', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
            ],
          );
        },
      );
    }

    // 优先显示网络图片
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: (localPath != null && localPath.isNotEmpty)
            ? Image.file(
                File(localPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 32, color: AppColors.textTertiary),
                      const SizedBox(height: 4),
                      Text(AppLocalizations.of(context).seller_product_edit_image_load_failed ?? 'Image load failed', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                    ],
                  );
                },
              )
            : null,
      );
    }

    // 显示本地图片
    if (localPath != null && localPath.isNotEmpty) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 32, color: AppColors.textTertiary),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context).seller_product_edit_image_load_failed ?? 'Image load failed', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
            ],
          );
        },
      );
    }
    
    // 没有图片，显示占位符
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 32, color: AppColors.textTertiary),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context).seller_product_edit_click_select_image ?? 'Click to select image', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
      ],
    );
  }

  /// 构建成功案例图片
  Widget _buildSuccessCaseImage(SuccessCase successCase) {
    Widget imageWidget;
    
    // 根据上传状态显示不同内容
    if (successCase.uploadStatus == SuccessCaseUploadStatus.uploading) {
      // 上传中 - 显示进度
      imageWidget = Stack(
        children: [
          // 显示本地图片作为背景
          if (successCase.imagePath.isNotEmpty)
            Image.file(
              File(successCase.imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          // 半透明遮罩
          Container(
            color: AppColors.overlayLight,
          ),
          // 进度指示器
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: successCase.uploadProgress / 100,
                  backgroundColor: AppColors.onPrimary.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  '${successCase.uploadProgress.toInt()}%',
                  style: TextStyle(color: AppColors.onPrimary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (successCase.uploadStatus == SuccessCaseUploadStatus.failed) {
      // 上传失败 - 显示错误状态
      imageWidget = Stack(
        children: [
          // 显示本地图片作为背景
          if (successCase.imagePath.isNotEmpty)
            Image.file(
              File(successCase.imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              color: AppColors.textTertiary,
              colorBlendMode: BlendMode.saturation,
            ),
          // 错误图标
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 40),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context).seller_product_edit_upload_failed ?? 'Upload Failed', style: TextStyle(color: AppColors.error, fontSize: 12)),
                if (successCase.canRetry)
                  TextButton(
                    onPressed: () => _bloc.add(RetrySuccessCaseUpload(caseId: successCase.id)),
                    child: Text(AppLocalizations.of(context).seller_product_edit_upload_retry ?? 'Retry', style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
      );
    } else if (successCase.imageUrl.isNotEmpty) {
      // 已上传 - 显示网络图片
      imageWidget = AppNetworkImage(
        imageUrl: successCase.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorWidget: successCase.imagePath.isNotEmpty
            ? Image.file(
                File(successCase.imagePath),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.backgroundSecondary,
                    child: const Icon(Icons.broken_image, size: 40, color: AppColors.textTertiary),
                  );
                },
              )
            : Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColors.backgroundSecondary,
                child: const Icon(Icons.broken_image, size: 40, color: AppColors.textTertiary),
              ),
      );
    } else if (successCase.imagePath.isNotEmpty) {
      // 待上传 - 显示本地图片
      imageWidget = Image.file(
        File(successCase.imagePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.backgroundSecondary,
            child: const Icon(Icons.broken_image, size: 40, color: AppColors.textTertiary),
          );
        },
      );
    } else {
      // 没有图片
      imageWidget = Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.backgroundSecondary,
        child: Icon(Icons.image, size: 40, color: AppColors.textTertiary),
      );
    }
    
    return imageWidget;
  }

  /// 构建成功案例项
  Widget _buildSuccessCaseItem(ProductEditState state, int index) {
    final successCase = state.successCases[index];
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderInput),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Expanded(
            flex: 3,
            child: Stack(
            children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: _buildSuccessCaseImage(successCase),
                ),
                // 操作按钮
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 编辑按钮
                      InkWell(
                        onTap: () => _showEditSuccessCaseDialog(state, successCase.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.overlayHeavy,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit, color: AppColors.onPrimary, size: 16),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // 删除按钮
                      InkWell(
                        onTap: () => _removeSuccessCase(successCase.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.overlayHeavy,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: AppColors.onPrimary, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          ),
          
          // 文字区域
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    successCase.title,
                    style: const TextStyle(
                fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      successCase.description,
                      style: TextStyle(
                        fontSize: 12,
                color: AppColors.textTertiary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 显示添加成功案例对话框
  void _showAddSuccessCaseDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedImagePath;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).product_edit_add_success_case ?? 'Add Success Case'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6, // 限制最大高度为屏幕高度的60%
              maxWidth: double.maxFinite,
            ),
            child: SingleChildScrollView(
      child: Column(
                mainAxisSize: MainAxisSize.min,
        children: [
                  // 图片选择区域 - 使用ImageUploadHelper
                  InkWell(
                    onTap: () async {
                      final results = await ImageUploadHelper.pickFromGallery(
                        type: ImageUploadType.product,
                        allowMultiple: false,
                      );
                      if (results.isNotEmpty) {
                        setState(() {
                          selectedImagePath = results.first.finalFile.path;
                        });
                      }
                    },
                    child: Container(
                      height: 100, // 减小图片预览高度
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderInput),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(selectedImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 32, color: AppColors.textTertiary),
                                const SizedBox(height: 4),
                                Text(AppLocalizations.of(context).seller_product_edit_click_select_image ?? 'Click to select image', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 标题输入
                  TextField(
                    controller: titleController,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: AppLocalizations.of(context).seller_product_edit_case_title_label ?? 'Case Title',
                      hintText: AppLocalizations.of(context).seller_product_edit_case_title_hint ?? 'Brief description of this case',
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 描述输入
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: AppLocalizations.of(context).seller_product_edit_case_desc_label ?? 'Case Description',
                      hintText: AppLocalizations.of(context).seller_product_edit_case_desc_hint ?? 'Describe the background, process, or results',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).seller_product_edit_cancel ?? 'Cancel'),
            ),
            ElevatedButton(
                onPressed: () {
                if (selectedImagePath != null && titleController.text.isNotEmpty) {
                  _addSuccessCase(
                    selectedImagePath!,
                    titleController.text,
                    descriptionController.text,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).seller_product_edit_select_image_and_title ?? 'Please select an image and enter a title')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerAccent,
                foregroundColor: AppColors.onPrimary,
              ),
              child: Text(AppLocalizations.of(context).seller_product_edit_add ?? 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示编辑成功案例对话框
  void _showEditSuccessCaseDialog(ProductEditState state, String caseId) {
    final successCase = state.successCases.firstWhere((c) => c.id == caseId);
    final titleController = TextEditingController(text: successCase.title);
    final descriptionController = TextEditingController(text: successCase.description);
    String? selectedImagePath = successCase.imagePath;
    String? currentImageUrl = successCase.imageUrl;
    bool imageChanged = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).product_edit_edit_success_case ?? 'Edit Success Case'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6, // 限制最大高度为屏幕高度的60%
              maxWidth: double.maxFinite,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 图片选择区域 - 使用ImageUploadHelper
                  InkWell(
                    onTap: () async {
                      final results = await ImageUploadHelper.pickFromGallery(
                        type: ImageUploadType.product,
                        allowMultiple: false,
                      );
                      if (results.isNotEmpty) {
                        setState(() {
                          selectedImagePath = results.first.finalFile.path;
                          imageChanged = true;
                        });
                      }
                    },
                    child: Container(
                      height: 100, // 减小图片预览高度
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderInput),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildEditDialogImage(selectedImagePath, currentImageUrl, imageChanged),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 标题输入
                  TextField(
                    controller: titleController,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: AppLocalizations.of(context).seller_product_edit_case_title_label ?? 'Case Title',
                      hintText: AppLocalizations.of(context).seller_product_edit_case_title_hint ?? 'Brief description of this case',
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 描述输入
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: AppLocalizations.of(context).seller_product_edit_case_desc_label ?? 'Case Description',
                      hintText: AppLocalizations.of(context).seller_product_edit_case_desc_hint ?? 'Describe the background, process, or results',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).seller_product_edit_cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedImagePath != null && selectedImagePath!.isNotEmpty && titleController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _updateSuccessCase(
                    caseId,
                    imagePath: imageChanged ? selectedImagePath : null,
                    title: titleController.text,
                    description: descriptionController.text,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).seller_product_edit_select_image_and_title ?? 'Please select an image and enter a title')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sellerAccent,
                foregroundColor: AppColors.onPrimary,
              ),
              child: Text(AppLocalizations.of(context).seller_product_edit_save ?? 'Save'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建商品图片上传部分
  Widget _buildImageUploadSection(ProductEditState state) {
    return Container(
      color: AppColors.onPrimary,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题区域与状态指示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).seller_product_edit_cover_image ?? 'Service Cover Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              // 上传状态指示器
              _buildUploadStatusIndicator(state),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 图片网格区域 - 使用GridView替代之前的行布局
          _buildImageGrid(state),
          
          // 上传失败错误消息
          if (state.uploadStatus == UploadStatus.failure && state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                AppLocalizations.of(context).seller_product_edit_upload_error(state.errorMessage ?? '') ?? 'Upload error: ${state.errorMessage}',
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
          
          // 图片上传说明
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              AppLocalizations.of(context).seller_product_edit_image_format_hint ?? 'Supports jpg, png, jpeg formats. Max 5MB per image, up to 9 images.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建上传状态指示器
  Widget _buildUploadStatusIndicator(ProductEditState state) {
    if (state.uploadStatus == UploadStatus.uploading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryWithOpacity05,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).product_edit_uploading_progress(state.uploadedCount, state.totalUploadCount),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    } else if (state.uploadStatus == UploadStatus.success && state.uploadedImageUrls.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).seller_product_edit_upload_success ?? 'Upload Successful',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    } else if (state.uploadStatus == UploadStatus.failure) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 16, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).seller_product_edit_upload_failed ?? 'Upload Failed',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink(); // 如果没有上传状态，返回空
  }

  // 构建图片网格
  Widget _buildImageGrid(ProductEditState state) {
    // 合并已上传的图片URL和新选择的图片路径
    final List<String> allImages = [
      ...state.uploadedImageUrls,  // 已上传的图片（网络URL）
      ...state.selectedImagePaths, // 新选择的图片（本地路径）
    ];
        
    // 确定要显示的图片数量，包括"添加"按钮格子
    final bool hasImages = allImages.isNotEmpty;
    int totalItemCount = hasImages ? allImages.length + 1 : 1;
    
    // 限制最多9张图片 + 1个添加按钮 = 10个格子
    if (totalItemCount > 10) totalItemCount = 10;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 每行3个
        mainAxisSpacing: 10, // 主轴间距
        crossAxisSpacing: 10, // 交叉轴间距
        childAspectRatio: 1, // 正方形
      ),
      itemCount: totalItemCount,
      itemBuilder: (context, index) {
        // 最后一个格子显示添加按钮
        if (hasImages && index == totalItemCount - 1) {
          return _buildAddImageButton(state);
        } 
        // 显示图片
        else if (index < allImages.length) {
          final String imagePath = allImages[index];
          // 判断是否为网络URL
          final bool isNetworkImage = imagePath.startsWith('http');
          
          return _buildImageItem(
            state, 
            index, 
            isNetworkImage ? null : imagePath,  // 本地路径
            isNetworkImage ? imagePath : null,  // 网络URL
          );
        } 
        // 添加按钮格子（以防万一）
        else {
          return _buildAddImageButton(state);
        }
      },
    );
  }
  
  // 构建单个图片项
  Widget _buildImageItem(ProductEditState state, int index, String? localPath, String? networkUrl) {
    return GestureDetector(
      onTap: () => _openImagePreview(state, index),
      child: Stack(
      children: [
        // 图片容器
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderInput),
            borderRadius: BorderRadius.circular(8),
          ),
          child: localPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.file(
                    File(localPath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : networkUrl != null
                  ? AppNetworkImage(
                      imageUrl: networkUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.circular(7),
                      errorWidget: const Center(
                        child: Icon(Icons.image_not_supported, color: AppColors.textTertiary),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported, size: 40, color: AppColors.textTertiary),
                    ),
        ),
        
        // 删除按钮
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              // 删除图片逻辑
              _removeImage(index);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.overlayHeavy,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.onPrimary,
                size: 16,
              ),
            ),
          ),
        ),
        
        // 如果是第一张图片，添加主图标识
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppLocalizations.of(context).seller_product_edit_main_image ?? 'Main',
                style: const TextStyle(color: AppColors.onPrimary, fontSize: 10),
              ),
            ),
          ),
      ],
    ),
    );
  }
  
  // 构建添加图片按钮
  Widget _buildAddImageButton(ProductEditState state) {
    bool canAdd = (state.selectedImagePaths.length < 9);
    
    // 如果正在上传，显示上传状态但仍然允许添加
    bool isUploading = (state.uploadStatus == UploadStatus.uploading);
                 
    return InkWell(
      onTap: canAdd ? () => _pickImages(replaceExisting: false) : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: canAdd ? AppColors.borderInput : AppColors.backgroundSecondary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: canAdd ? AppColors.backgroundCard : AppColors.backgroundSecondary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 如果正在上传，显示上传图标和进度
            if (isUploading)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.cloud_upload,
                    color: Theme.of(context).primaryColor,
                    size: 12,
                  ),
                ],
              )
            else
            Icon(
              Icons.add_photo_alternate_outlined,
              color: canAdd ? Theme.of(context).primaryColor : AppColors.textTertiary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              isUploading ? (AppLocalizations.of(context).product_edit_uploading ?? 'Uploading...') : (AppLocalizations.of(context).product_edit_add_image ?? 'Add Image'),
              style: TextStyle(
                fontSize: 12,
                color: canAdd ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 删除图片方法
  void _removeImage(int index) {
    // 使用新的删除事件，避免重新上传
    _bloc.add(RemoveProductImage(index: index, isDetailImage: false));
    
    // 触发变更检测
    _onFormFieldChanged();
  }

  /// 打开图片预览页面
  void _openImagePreview(ProductEditState state, int index) {
    // 合并已上传的图片URL和新选择的图片路径
    final List<String> allImagePaths = [
      ...state.uploadedImageUrls,
      ...state.selectedImagePaths,
    ];
    
    if (allImagePaths.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImagePreviewPage(
            imagePaths: allImagePaths,
            initialIndex: index,
            mainImageIndex: 0, // 第一张总是主图
            onSetMainImage: (selectedIndex) => _setMainImage(selectedIndex),
            onDeleteImage: (selectedIndex) => _removeImage(selectedIndex),
          ),
        ),
      );
    }
  }

  /// 设置主图
  void _setMainImage(int index) {
    _bloc.add(SetMainProductImage(index: index, isDetailImage: false));
    _onFormFieldChanged();
  }

  /// 构建档位选择器
  Widget _buildTierSelector(ServiceTier tier) {
    final isSelected = _selectedTier == tier;
    final tierConfig = _serviceTiers.getTierConfig(tier);
    final hasPrice = tierConfig.price > 0;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectServiceTier(tier),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderInput,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? AppColors.primaryWithOpacity10 : AppColors.backgroundCard,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tier.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              if (hasPrice) ...[
                const SizedBox(height: 2),
                Text(
                  '${RegionConfig.currencySymbol}${tierConfig.price.toStringAsFixed(tierConfig.price % 1 == 0 ? 0 : 2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建档位价格编辑器
  Widget _buildTierPriceEditor() {
    final tierConfig = _serviceTiers.getTierConfig(_selectedTier);
    
    return TextField(
      controller: tierConfig.priceController,
      readOnly: widget.isPreviewMode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).seller_product_edit_tier_price_label(_selectedTier.displayName) ?? '${_selectedTier.displayName} Price',
        labelStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
        ),
        prefixText: RegionConfig.currencySymbol,
        prefixStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        helperText: AppLocalizations.of(context).seller_product_edit_max_price('${ValidationConstants.maxPrice}') ?? 'Maximum: ${ValidationConstants.maxPrice}',
        helperStyle: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        errorText: _formErrors['price_${_selectedTier.name}'],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        filled: true,
        fillColor: AppColors.backgroundCard,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;
          final value = double.tryParse(newValue.text);
          if (value == null) return oldValue;
          if (value > ValidationConstants.maxPrice) {
            return oldValue;
          }
          return newValue;
        }),
      ],
      onChanged: (value) {
        setState(() {
          final price = double.tryParse(value) ?? 0;
          tierConfig.updatePrice(price);
          
          // 验证价格
          if (price > ValidationConstants.maxPrice) {
            _formErrors['price_${_selectedTier.name}'] = AppLocalizations.of(context).seller_product_edit_price_exceed_max('${ValidationConstants.maxPrice}') ?? 'Price cannot exceed ${ValidationConstants.maxPrice}';
          } else if (price > 0 && price < 0.01) {
            _formErrors['price_${_selectedTier.name}'] = AppLocalizations.of(context).seller_product_edit_price_min ?? 'Minimum price is 0.01';
          } else {
            _formErrors.remove('price_${_selectedTier.name}');
          }
        });
        _onFormFieldChanged();
      },
    );
  }

  /// 获取或创建QA控制器
  TextEditingController _getQAController(int qaIndex, String type, String initialValue) {
    final key = '${qaIndex}_$type';
    if (!_qaControllers.containsKey(key)) {
      _qaControllers[key] = TextEditingController(text: initialValue);
    }
    // 如果初始值发生变化，更新控制器的文本（但不移动光标）
    final controller = _qaControllers[key]!;
    if (controller.text != initialValue) {
      // 保存当前的光标位置
      final selection = controller.selection;
      controller.text = initialValue;
      // 恢复光标位置，确保不超出新文本的长度
      if (selection.isValid && selection.end <= initialValue.length) {
        controller.selection = selection;
      }
    }
    return controller;
  }


  /// 预览商品
  void _previewProduct() {
    // 获取当前表单数据
    final formData = _collectFormData();
    
    // 导航到预览页面，传递表单数据
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductPreviewPage(
          productId: widget.productId,
          formData: formData,
        ),
      ),
    );
  }
  
  /// 收集表单数据
  ExtendedProductFormData _collectFormData() {
    final state = _bloc.state;
    
    // 收集所有启用的服务档位数据
    final variants = <ProductOptionValue>[];
    int variantId = 1;
    
    for (final tier in ServiceTier.values) {
      final tierConfig = _serviceTiers.getTierConfig(tier);
      // 检查该档位是否启用（价格大于0）
      if (tierConfig.price > 0) {
        // 获取该档位的属性
        final attributes = _serviceTiers.getAttributesForTier(tier);
        
        variants.add(ProductOptionValue(
          id: variantId++,
          name: tier.displayName,
          sellingPrice: tierConfig.price,
          deliveryDay: tierConfig.deliveryDay,
          editNum: tierConfig.editNum,
          feature: attributes.map((attr) => {
            'key': attr.name,
            'val': attr.value,
            'type': attr.type.value,
          }).toList(),
        ));
      }
    }
    
    // 转换qaList和buyerInfoItems为productMaterials
    final List<ProductMaterial> materials = [];
    
    // 转换qaList为PROBLEM类型的materials
    int materialId = 1;
    for (final qa in _qaList) {
      materials.add(ProductMaterial(
        id: materialId++,
        question: qa.question,
        answer: qa.answer,
        type: 'PROBLEM',
      ));
    }
    
    // 转换buyerInfoItems为ATTACHMENT或TEXT类型的materials
    int buyerInfoMaterialId = 1000; // 从1000开始，避免与QA的ID冲突
    for (final item in _buyerInfoItems) {
      String materialType = 'TEXT';
      // 根据类型判断是TEXT还是ATTACHMENT
      if (item.type == BuyerInfoType.file || item.type == BuyerInfoType.image) {
        materialType = 'ATTACHMENT';
      }
      
      materials.add(ProductMaterial(
        id: buyerInfoMaterialId++,
        question: item.label,
        answer: item.description,
        type: materialType,
      ));
    }
    
    return ExtendedProductFormData(
      productId: widget.productId != null ? int.tryParse(widget.productId!) : null,
      name: _nameController.text,
      description: _descriptionController.text,
      price: variants.isNotEmpty ? variants.first.sellingPrice : 0.0,
      categoryId: state.formData.categoryId,
      variants: variants,
      productMaterials: materials, // 使用转换后的materials
      detailContent: '',
      qaList: _qaList.map((qa) => {
        'question': qa.question,
        'answer': qa.answer,
      }).toList(),
      buyerInfoItems: _buyerInfoItems.map((item) => {
        'type': item.type.name,
        'label': item.label,
        'description': item.description,
        'isRequired': item.isRequired,
      }).toList(),
      successCases: state.successCases.map((case_) => case_.toJson()).toList(),
      images: state.selectedImagePaths,
    );
  }

  /// 清理未使用的QA控制器
  void _cleanupUnusedQAControllers() {
    final currentQAKeys = <String>{};
    
    // 收集所有当前使用的QA键
    for (int i = 0; i < _qaList.length; i++) {
      currentQAKeys.add('${i}_question');
      currentQAKeys.add('${i}_answer');
    }
    
    // 移除不再使用的控制器
    final keysToRemove = _qaControllers.keys
        .where((key) => !currentQAKeys.contains(key))
        .toList();
    
    for (final key in keysToRemove) {
      _qaControllers[key]?.dispose();
      _qaControllers.remove(key);
    }
  }

}
