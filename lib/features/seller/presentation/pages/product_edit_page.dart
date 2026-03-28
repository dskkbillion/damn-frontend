import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import '../widgets/image_preview_page.dart';
import 'product_preview_page.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';

// 导入重构后的数据模型
import 'package:dskk_flutter_refactor/features/seller/domain/entities/product_edit_models.dart';
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/service_tier_models.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import '../widgets/product_edit/product_success_cases_section.dart';
import '../widgets/product_edit/product_image_upload_section.dart';
import '../widgets/product_edit/product_buyer_info_section.dart';
import '../widgets/product_edit/product_qa_section.dart';

// 输入验证常量
class ValidationConstants {
  static const double maxPrice = 999999.99; // 最大价格
  static const int maxDeliveryDays = 365; // 最大交付天数
  static const int maxEditNum = 99; // 最大修改次数
  static const int maxAttributeNameLength = 8; // 属性名称最大长度
  static const int maxAttributeValueLength = 50; // 属性值最大长度
}

/// 自定义的最大值文本输入格式化器
class _MaxValueTextInputFormatter extends TextInputFormatter {
  final int maxValue;
  
  _MaxValueTextInputFormatter(this.maxValue);
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final newInt = int.tryParse(newValue.text);
    if (newInt == null) {
      return oldValue;
    }
    
    if (newInt > maxValue) {
      return oldValue;
    }
    
    return newValue;
  }
}

// 扩展的产品表单数据，包含额外的字段
class ExtendedProductFormData extends ProductFormData {
  final int? productId;
  final List<String> images;
  
  const ExtendedProductFormData({
    required String name,
    required String description,
    required double price,
    int? categoryId,
    required List<ProductOptionValue> variants,
    required List<ProductMaterial> productMaterials,
    required String detailContent,
    required List<Map<String, String>> qaList,
    required List<Map<String, dynamic>> buyerInfoItems,
    required List<Map<String, dynamic>> successCases,
    this.productId,
    required this.images,
  }) : super(
    name: name,
    description: description,
    price: price,
    categoryId: categoryId,
    variants: variants,
    productMaterials: productMaterials,
    detailContent: detailContent,
    qaList: qaList,
    buyerInfoItems: buyerInfoItems,
    successCases: successCases,
  );
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

class _ProductEditPageState extends State<ProductEditPage> with TickerProviderStateMixin {
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
  
  /// 服务档位管理
  late ProductServiceTiers _serviceTiers;
  
  /// 当前选中的服务档位
  ServiceTier _selectedTier = ServiceTier.basic;

  /// 闪烁动画控制器
  late AnimationController _flashAnimationController;

  /// 闪烁动画
  late Animation<double> _flashAnimation;

  /// 档位切换动画控制器
  late AnimationController _tierSwitchAnimationController;

  /// 档位缩放动画
  late Animation<double> _tierScaleAnimation;

  /// 档位淡入淡出动画
  late Animation<double> _tierFadeAnimation;

  /// 档位滑动动画
  late Animation<Offset> _tierSlideAnimation;

  /// 属性列表切换动画控制器
  late AnimationController _attributeListAnimationController;

  /// 属性列表淡入淡出动画
  late Animation<double> _attributeFadeAnimation;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();
  
  
  

  
  /// QA相关状态
  final List<QAPair> _qaList = [];

  /// 买家信息相关状态
  final List<BuyerInfoItem> _buyerInfoItems = [];
  
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
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFBF7D2A), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    filled: true,
    fillColor: Colors.white,
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
    
    AppLogger.d('[ProductEditPage] initState called with productId: ${widget.productId}, isPreviewMode: ${widget.isPreviewMode}');
    
    // 从DI容器获取BLoC实例
    _bloc = getIt<ProductEditBloc>();
    
    // 初始化服务档位
    _serviceTiers = ProductServiceTiers();

    // 初始化闪烁动画
    _flashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashAnimationController,
      curve: Curves.easeInOut,
    ));

    // 初始化档位切换动画控制器
    _tierSwitchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _tierScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _tierSwitchAnimationController,
      curve: Curves.easeOutBack,
    ));

    _tierFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tierSwitchAnimationController,
      curve: Curves.easeInOut,
    ));

    _tierSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _tierSwitchAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 初始化属性列表动画控制器
    _attributeListAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _attributeFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _attributeListAnimationController,
      curve: Curves.easeInOut,
    ));

    _tierSwitchAnimationController.forward();
    _attributeListAnimationController.forward();

    // 解析商品ID
    final productIdInt = widget.productId != null ? int.tryParse(widget.productId!) : null;
    AppLogger.d('[ProductEditPage] Parsed productId as int: $productIdInt');
    
    // 初始化页面
    AppLogger.d('[ProductEditPage] Initializing ProductEdit with productId: $productIdInt, isPreviewMode: ${widget.isPreviewMode}');
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
      AppLogger.d('[ProductEditPage] State changed - isLoading: ${state.isLoading}, hasProduct: ${state.product != null}, isPreviewMode: ${widget.isPreviewMode}');
      if (!state.isLoading && state.product != null) {
        // 只在初始加载或者非用户输入触发的状态变化时同步数据
        // 避免在用户输入时触发同步导致光标跳转
        if (_isInitialDataLoad) {
          AppLogger.d('[ProductEditPage] Initial data load - syncing data from state');
          _syncDataFromState(state.formData);
          _isInitialDataLoad = false;
        } else if (state.formData.name != _nameController.text ||
                   state.formData.description != _descriptionController.text) {
          // 只有当BLoC状态与当前控制器值不同时才同步（说明不是由用户输入触发的）
          // 但要小心处理，避免覆盖用户正在编辑的内容
          AppLogger.d('[ProductEditPage] External state change detected - syncing carefully');
          _syncDataFromState(state.formData);
        }

        // 设置初始数据用于变更检测（仅在编辑模式下）
        if (state.initialFormData == null && !widget.isPreviewMode) {
          _bloc.add(SetInitialFormData(initialData: state.formData));
        }
      }
    });
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
      AppLogger.d('[ProductEditPage] Product ID changed from ${oldWidget.productId} to ${widget.productId}, reinitializing...');
      
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

    // 释放动画控制器
    _tierSwitchAnimationController.dispose();
    _attributeListAnimationController.dispose();
    
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
    
    // 释放所有服务档位控制器
    _serviceTiers.dispose();

    // 释放动画控制器
    _flashAnimationController.dispose();

    super.dispose();
  }

  /// 表单字段变化时检查变更
  void _onFormFieldChanged() {
    // 取消之前的防抖计时器
    _debounceTimer?.cancel();

    // 设置新的防抖计时器，延迟500ms执行
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
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
        
        // 轻咨询模式：直接发布商品，不保存草稿
        _bloc.add(const SubmitProductForm());
        
        // 原草稿功能代码（暂时保留，后续可能会用）
        // _bloc.add(const SaveProductDraft());
        
        // 等待提交完成
        await _bloc.stream
            .firstWhere((state) => !state.isSubmitting)
            .timeout(const Duration(seconds: 10));
        
        // 原草稿等待代码
        // await _bloc.stream
        //     .firstWhere((state) => !state.isSavingDraft)
        //     .timeout(const Duration(seconds: 10));
        
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

  /// 显示保存对话框
  Future<bool?> _showSaveDraftDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('检测到未保存的更改'),
        // 轻咨询模式：直接发布
        content: const Text('您有未保存的内容，是否要保存并发布？'),
        // 原草稿提示文案
        // content: const Text('您有未保存的内容，是否要保存为草稿？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('不保存'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBF7D2A),
              foregroundColor: Colors.white,
            ),
            // 轻咨询模式：直接发布
            child: const Text('保存并发布'),
            // 原草稿按钮文案
            // child: Text(AppLocalizations.of(context)!?.product_edit_save_draft ?? 'Save Draft'),
          ),
        ],
      ),
    );
  }

  /// 从BLoC状态同步数据到页面组件
  void _syncDataFromState(ProductFormData formData) {
    AppLogger.d('[ProductEditPage] _syncDataFromState called with name: "${formData.name}", description: "${formData.description}", variants count: ${formData.variants.length}');
    AppLogger.d('[ProductEditPage] isPreviewMode: ${widget.isPreviewMode}, productId: ${widget.productId}');
    AppLogger.d('[ProductEditPage] Current controller values - name: "${_nameController.text}", description: "${_descriptionController.text}"');

    // 更新基本文本字段 - 只在值真正改变时更新，避免光标跳转
    if (mounted) {
      // 保存当前光标位置
      final nameSelection = _nameController.selection;
      final descriptionSelection = _descriptionController.selection;

      // 只在内容真正改变时才更新控制器
      if (_nameController.text != formData.name) {
        setState(() {
          _nameController.text = formData.name;
        });
        AppLogger.d('[ProductEditPage] Updated name controller - "${_nameController.text}"');
      }

      if (_descriptionController.text != formData.description) {
        setState(() {
          _descriptionController.text = formData.description;
        });
        AppLogger.d('[ProductEditPage] Updated description controller - "${_descriptionController.text}"');
      }
    }
    
    // 如果有变体数据，更新到本地服务档位（编辑模式和预览模式都需要）
    if (formData.variants.isNotEmpty && (!_bloc.state.isCreateMode || widget.isPreviewMode)) {
      AppLogger.d('[ProductEditPage] Updating service tiers from ${formData.variants.length} variants');
      for (int i = 0; i < formData.variants.length; i++) {
        final variant = formData.variants[i];
        AppLogger.d('[ProductEditPage] Variant $i: name="${variant.name}", price=${variant.price}, sellingPrice=${variant.sellingPrice}');
      }
      
      if (mounted) {
        setState(() {
          _serviceTiers = ProductServiceTiers.fromProductOptionValues(formData.variants);
        });
        AppLogger.d('[ProductEditPage] Updated service tiers from variants:');
        AppLogger.d('[ProductEditPage] - Basic: price=${_serviceTiers.basic.price}, delivery=${_serviceTiers.basic.deliveryDay}');
        AppLogger.d('[ProductEditPage] - Standard: price=${_serviceTiers.standard.price}, delivery=${_serviceTiers.standard.deliveryDay}'); 
        AppLogger.d('[ProductEditPage] - Premium: price=${_serviceTiers.premium.price}, delivery=${_serviceTiers.premium.deliveryDay}');
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
              AppLogger.d('[ProductEditPage] Added QA item: question="${qaMap['question']}", answer="${qaMap['answer']}"');
            } catch (e) {
              AppLogger.d('[ProductEditPage] Error parsing QA data: $e, qaMap: $qaMap');
            }
          }
          AppLogger.d('[ProductEditPage] Synced ${_qaList.length} QA items from formData');
          
          // 同步买家信息列表
          _buyerInfoItems.clear();
          for (final buyerInfoMap in formData.buyerInfoItems) {
            try {
              _buyerInfoItems.add(BuyerInfoItem.fromJson(buyerInfoMap));
              AppLogger.d('[ProductEditPage] Added buyer info item: type="${buyerInfoMap['type']}", label="${buyerInfoMap['label']}"');
            } catch (e) {
              AppLogger.d('[ProductEditPage] Error parsing buyer info data: $e, buyerInfoMap: $buyerInfoMap');
            }
          }
          AppLogger.d('[ProductEditPage] Synced ${_buyerInfoItems.length} buyer info items from formData');
          
          // 标记初始数据已加载
          _isInitialDataLoad = false;
        });
      }
    }
    
    // Success cases are now managed in BLoC state
    // No need to sync here
    
    AppLogger.d('[ProductEditPage] Synced data from state:');
    AppLogger.d('  - QA items: ${_qaList.length}');
    AppLogger.d('  - Buyer info items: ${_buyerInfoItems.length}');
    AppLogger.d('  - Success cases: managed in BLoC');
    AppLogger.d('  - Variants: ${formData.variants.length}');
  }

  /// 将页面组件的本地数据同步到BLoC状态
  void _syncLocalDataToBLoC() {
    AppLogger.d('[ProductEditPage] Syncing local data to BLoC:');
    AppLogger.d('  - QA items: ${_qaList.length}');
    AppLogger.d('  - Buyer info items: ${_buyerInfoItems.length}');
    AppLogger.d('  - Success cases: managed in BLoC');
    
    // 直接调用现有的同步方法
    _syncAdditionalFormData();
  }

  /// 获取档位主题色
  Color _getTierThemeColor() {
    switch (_selectedTier) {
      case ServiceTier.basic:
        return Colors.blue.shade600;
      case ServiceTier.standard:
        return Colors.purple.shade600;
      case ServiceTier.premium:
        return Colors.amber.shade700;
    }
  }

  /// 获取档位图标
  IconData _getTierIcon() {
    switch (_selectedTier) {
      case ServiceTier.basic:
        return Icons.flash_on;
      case ServiceTier.standard:
        return Icons.star;
      case ServiceTier.premium:
        return Icons.diamond;
    }
  }

  /// 获取档位提示文字
  String _getTierHintText() {
    switch (_selectedTier) {
      case ServiceTier.basic:
        return '快速响应，即时解答';
      case ServiceTier.standard:
        return '深入分析，专业建议';
      case ServiceTier.premium:
        return '全方位服务，持续优化';
    }
  }

  /// 选择服务档位
  void _selectServiceTier(ServiceTier tier) {
    if (_selectedTier != tier) {
      // 触发档位切换动画
      _tierSwitchAnimationController.reverse().then((_) {
        setState(() {
          _selectedTier = tier;
        });
        _tierSwitchAnimationController.forward();
      });

      // 触发属性列表切换动画
      _attributeListAnimationController.reverse().then((_) {
        _attributeListAnimationController.forward();
      });

      // 触发闪烁动画
      _flashAnimationController.forward().then((_) {
        _flashAnimationController.reverse();
      });
    }
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
            const SnackBar(
              content: Text('最多只能上传9张图片，已选择前9张'),
              backgroundColor: Colors.orange,
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
        _formErrors['name'] = AppLocalizations.of(context)!?.product_edit_validation_name_required ?? 'Please enter service name';
      });
      isValid = false;
    }
    
    // 验证商品描述
    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _formErrors['description'] = AppLocalizations.of(context)!?.product_edit_validation_description_required ?? 'Please enter service description';
      });
      isValid = false;
    }
    
    // 验证商品图片
    bool hasImages = _bloc.state.selectedImagePaths.isNotEmpty || 
                     _bloc.state.uploadedImageUrls.isNotEmpty ||
                     (_bloc.state.product?.images.isNotEmpty ?? false);
    
    if (!hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!?.product_edit_at_least_one_image ?? 'Please upload at least one product image'),
          backgroundColor: Colors.red,
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
          _formErrors['price_${tier.tier.name}'] = '${tier.tier.displayName}价格必须大于0';
        });
        isValid = false;
      }
    }
    
    if (!isValid) {
      // 滚动到第一个错误字段
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('表单数据不完整，请检查标红字段'),
          backgroundColor: Colors.red,
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
  
  /// 显示添加商品属性弹窗
  void _showAddFeatureDialog() {
    final nameController = TextEditingController();
    String? errorText;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加属性'),
          content: TextField(
            controller: nameController,
            maxLength: ValidationConstants.maxAttributeNameLength,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!?.product_edit_attribute_name_hint ?? 'Please enter attribute name',
              helperText: AppLocalizations.of(context)!?.product_edit_max_characters != null 
                  ? AppLocalizations.of(context)!.product_edit_max_characters(ValidationConstants.maxAttributeNameLength)
                  : 'Max ${ValidationConstants.maxAttributeNameLength} characters',
              errorText: errorText,
              border: const OutlineInputBorder(),
              counterText: '${nameController.text.length}/${ValidationConstants.maxAttributeNameLength}',
            ),
            autofocus: true,
            onChanged: (value) {
              setDialogState(() {
                if (value.length > ValidationConstants.maxAttributeNameLength) {
                  errorText = '属性名称最多${ValidationConstants.maxAttributeNameLength}个字符';
                } else {
                  errorText = null;
                }
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    nameController.text.length <= ValidationConstants.maxAttributeNameLength) {
                  _addProductAttribute(
                    nameController.text,
                    '',
                    ProductAttributeType.input,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建选项编辑器
  Widget _buildOptionsEditor(List<String> options, StateSetter setState) {
    final optionController = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选项配置',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        // 已添加的选项
        ...options.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(child: Text(option)),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      options.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        
        // 添加新选项
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: optionController,
                decoration: _lightBorderDecoration.copyWith(
                  labelText: '新选项',
                  hintText: '输入选项内容',
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && !options.contains(value)) {
                    setState(() {
                      options.add(value);
                      optionController.clear();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFBF7D2A)),
              onPressed: () {
                final value = optionController.text.trim();
                if (value.isNotEmpty && !options.contains(value)) {
                  setState(() {
                    options.add(value);
                    optionController.clear();
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
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
            ? AppLocalizations.of(context)!?.product_edit_preview_product ?? 'Preview Product' 
            : (widget.productId == null ? AppLocalizations.of(context)!?.product_edit_publish_product ?? 'Publish Product' : AppLocalizations.of(context)!?.product_edit_title_edit ?? 'Edit Product')),
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
              label: Text(AppLocalizations.of(context)!?.product_management_action_edit ?? 'Edit'),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFBF7D2A),
                foregroundColor: Colors.white,
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
                        tooltip: AppLocalizations.of(context)!?.product_edit_preview_product ?? 'Preview',
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // 保存草稿按钮 - 暂时注释掉，直接发布商品
                    // TextButton.icon(
                    //   onPressed: state.isSavingDraft ? null : () {
                    //     // 同步本地数据到BLoC
                    //     _syncLocalDataToBLoC();
                    //     
                    //     // 构建并同步服务档位数据
                    //     List<ProductOptionValue> variants = _serviceTiers.toProductOptionValues();
                    //     _bloc.add(UpdateFormField(fieldName: 'variants', value: variants));
                    //     
                    //     // 设置基础价格为基础档的价格
                    //     _bloc.add(UpdateFormField(
                    //       fieldName: 'price', 
                    //       value: _serviceTiers.basic.price
                    //     ));
                    //     
                    //     // 添加调试日志
                    //     AppLogger.d('[ProductEditPage] Saving draft with price: ${_serviceTiers.basic.price}');
                    //     AppLogger.d('[ProductEditPage] Variants count: ${variants.length}');
                    //     for (var i = 0; i < variants.length; i++) {
                    //       AppLogger.d('[ProductEditPage] Variant $i: ${variants[i].name} - price: ${variants[i].sellingPrice}');
                    //     }
                    //     
                    //     // 保存草稿
                    //     _bloc.add(const SaveProductDraft());
                    //   },
                    //   icon: state.isSavingDraft
                    //       ? const SizedBox(
                    //           width: 16,
                    //           height: 16,
                    //           child: CircularProgressIndicator(strokeWidth: 2),
                    //         )
                    //       : const Icon(Icons.save_alt),
                    //   label: Text(state.hasUnsavedChanges ? '草稿*' : '草稿'),
                    //   style: TextButton.styleFrom(
                    //     foregroundColor: state.hasUnsavedChanges ? Colors.orange : Colors.grey,
                    //   ),
                    // ),
                  ],
                );
              },
            ),
            
            TextButton(
              onPressed: _submitForm,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFBF7D2A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('发布'),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: BlocProvider<ProductEditBloc>(
          create: (context) => _bloc,
          child: BlocConsumer<ProductEditBloc, ProductEditState>(
            buildWhen: (previous, current) {
              // 只在真正影响UI渲染的字段变化时才rebuild
              if (previous.isLoading != current.isLoading) return true;
              if (previous.product != current.product) return true;
              if (previous.selectedImagePaths != current.selectedImagePaths) return true;
              if (previous.selectedDetailImagePaths != current.selectedDetailImagePaths) return true;
              if (previous.uploadedImageUrls != current.uploadedImageUrls) return true;
              if (previous.uploadedDetailImageUrls != current.uploadedDetailImageUrls) return true;
              if (previous.uploadStatus != current.uploadStatus) return true;
              if (previous.uploadedCount != current.uploadedCount) return true;
              if (previous.totalUploadCount != current.totalUploadCount) return true;
              if (previous.formData.name != current.formData.name) return true;
              if (previous.formData.description != current.formData.description) return true;
              if (previous.formData.categoryId != current.formData.categoryId) return true;
              if (previous.formData.price != current.formData.price) return true;
              if (previous.categories != current.categories) return true;
              if (previous.successCases != current.successCases) return true;
              if (previous.hasError != current.hasError) return true;
              if (previous.errorMessage != current.errorMessage) return true;
              // hasUnsavedChanges / isSavingDraft / isDraftSaveSuccess / isSubmitting / isSubmitSuccess
              // / initialFormData / lastAutoSaveTime / formData.qaList / formData.buyerInfoItems
              // 变化不需要rebuild表单主体
              return false;
            },
            listener: (context, state) {
              if (state.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? '操作失败'),
                    backgroundColor: Colors.red,
                  ),
                );
              // 原草稿保存成功处理（暂时注释，后续可能会用）
              // else if (state.isDraftSaveSuccess && !_isReturning) {
              //   // 先检查是否已经mounted，避免在dispose后执行
              //   if (!mounted) return;
              //   
              //   // 设置标志，防止重复返回
              //   _isReturning = true;
              //   
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text('草稿保存成功'),
              //       backgroundColor: Colors.green,
              //     ),
              //   );
              //   // 通知父页面刷新草稿列表
              //   widget.onDraftSaved?.call();
              //   // 立即返回，不再延迟
              //   // 返回true表示需要刷新列表
              //   Navigator.of(context).pop(true);
              // }
              } else if (state.isSubmitSuccess) {
                // 先检查是否已经mounted，避免在dispose后执行
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.isCreateMode 
                      ? '服务发布成功！请在"在售"列表中查看' 
                      : '服务更新成功'),
                    backgroundColor: Colors.green,
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
                return const Center(child: CircularProgressIndicator());
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
            ProductBuyerInfoSection(
              items: _buyerInfoItems,
              isPreviewMode: widget.isPreviewMode,
              onAdd: _addBuyerInfoItem,
              onUpdate: _updateBuyerInfoItem,
              onRemove: _removeBuyerInfoItem,
            ),
            
            // 常见问题编辑
            ProductQASection(
              initialItems: _qaList,
              isPreviewMode: widget.isPreviewMode,
              onChanged: (items) {
                _qaList
                  ..clear()
                  ..addAll(items);
                _onFormFieldChanged();
              },
            ),
            
            // 成功案例
            ProductSuccessCasesSection(
              state: state,
              onAdd: _addSuccessCase,
              onEdit: _updateSuccessCase,
              onRemove: _removeSuccessCase,
              onRetryUpload: (caseId) => _bloc.add(RetrySuccessCaseUpload(caseId: caseId)),
            ),
            
            // 商品图片上传
            ProductImageUploadSection(
              state: state,
              onPickImages: ({bool replaceExisting = false}) =>
                  _pickImages(replaceExisting: replaceExisting),
              onRemoveImage: _removeImage,
              onSetMainImage: _setMainImage,
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 构建基本信息表单
  Widget _buildBasicInfoForm(ProductEditState state) {
    return Container(
      color: Colors.white,
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
                hintText: '服务名称',
                hintStyle: const TextStyle(color: Colors.grey),
                    errorText: _formErrors['name'],
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
              ),
              onChanged: (value) {
                    // 输入时清除该字段的错误（不使用setState避免输入法问题）
                    if (_formErrors.containsKey('name')) {
                      _formErrors.remove('name');
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
                hintText: '描述一下您的服务的具体信息，如...',
                hintStyle: const TextStyle(color: Colors.grey),
                errorText: _formErrors['description'],
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
              maxLines: 3,
              onChanged: (value) {
                // 输入时清除该字段的错误（不使用setState避免输入法问题）
                if (_formErrors.containsKey('description')) {
                  _formErrors.remove('description');
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
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!?.product_edit_service_tiers ?? 'Service Tier Settings',
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
          
          // 当前档位的属性列表
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildTierAttributesList(),
          ),
          
          const SizedBox(height: 16),
        ],
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

    // 根据档位获取主题色
    Color getTierColor() {
      switch (tier) {
        case ServiceTier.basic:
          return Colors.blue.shade600;
        case ServiceTier.standard:
          return Colors.purple.shade600;
        case ServiceTier.premium:
          return Colors.amber.shade700;
      }
    }

    // 根据档位获取图标
    IconData getTierIcon() {
      switch (tier) {
        case ServiceTier.basic:
          return Icons.flash_on;
        case ServiceTier.standard:
          return Icons.star;
        case ServiceTier.premium:
          return Icons.diamond;
      }
    }

    final tierColor = getTierColor();

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectServiceTier(tier),
            borderRadius: BorderRadius.circular(12),
            splashColor: tierColor.withOpacity(0.2),
            highlightColor: tierColor.withOpacity(0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                vertical: isSelected ? 12 : 8,
                horizontal: isSelected ? 16 : 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? tierColor : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? tierColor.withOpacity(0.1) : Colors.white,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: tierColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      getTierIcon(),
                      color: isSelected ? tierColor : Colors.grey[500],
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isSelected ? 15 : 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? tierColor : Colors.grey[700],
                    ),
                    child: Text(tier.displayName),
                  ),
                  if (hasPrice) ...[
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: isSelected ? 13 : 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? tierColor : Colors.grey[600],
                      ),
                      child: Text(
                        '${RegionConfig.currencySymbol}${tierConfig.price.toStringAsFixed(tierConfig.price % 1 == 0 ? 0 : 2)}',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 构建档位价格编辑器
  Widget _buildTierPriceEditor() {
    final tierConfig = _serviceTiers.getTierConfig(_selectedTier);

    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(_flashAnimation.value * 0.8),
                blurRadius: 20 * _flashAnimation.value,
                spreadRadius: 5 * _flashAnimation.value,
              ),
            ],
          ),
          child: TextField(
      controller: tierConfig.priceController,
      readOnly: widget.isPreviewMode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: '${_selectedTier.displayName}价格',
        labelStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 12,
          color: Colors.blue,
        ),
        prefixText: RegionConfig.currencySymbol,
        prefixStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        helperText: '最大值：${ValidationConstants.maxPrice}',
        helperStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
        errorText: _formErrors['price_${_selectedTier.name}'],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        filled: true,
        fillColor: Colors.white,
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
        final price = double.tryParse(value) ?? 0;
        tierConfig.updatePrice(price);

        // 验证价格 —— 直接更新错误 map，不触发 setState 避免全树 rebuild
        if (price > ValidationConstants.maxPrice) {
          _formErrors['price_${_selectedTier.name}'] = '价格不能超过${ValidationConstants.maxPrice}';
        } else if (price > 0 && price < 0.01) {
          _formErrors['price_${_selectedTier.name}'] = '价格最小值为0.01';
        } else {
          _formErrors.remove('price_${_selectedTier.name}');
        }
        _onFormFieldChanged();
      },
          ),
        );
      },
    );
  }

  /// 构建档位属性列表
  Widget _buildTierAttributesList() {
    final tierConfig = _serviceTiers.getTierConfig(_selectedTier);

    // 构建所有属性的列表（包括系统属性和自定义属性）
    final List<Widget> attributeItems = [];

    // 添加自定义属性
    final customAttributes = _serviceTiers.getAttributesForTier(_selectedTier);
    for (int i = 0; i < customAttributes.length; i++) {
      final attr = customAttributes[i];
      Widget attributeWidget;

      if (attr.type == ProductAttributeType.boolean) {
        // 单选属性使用特殊的显示方式
        attributeWidget = _buildBooleanAttribute(attr);
      } else {
        // 文本输入属性
        attributeWidget = _buildFloatingLabelAttribute(
          labelText: attr.name,
          value: attr.value,
          isSystem: false,
          attributeId: attr.id,
          keyboardType: TextInputType.text,
          onChanged: (value) {
            // 直接更新数据，不调用setState避免输入法问题
            _serviceTiers.getTierConfig(_selectedTier).updateAttributeValue(attr.id, value);
            _onFormFieldChanged();
          },
        );
      }

      attributeItems.add(
        attributeWidget,
      );
    }

    return FadeTransition(
      opacity: _attributeFadeAnimation,
      child: SlideTransition(
        position: _tierSlideAnimation,
        child: Column(
          children: [
            // 档位特色提示卡片
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getTierThemeColor().withOpacity(0.05),
                    _getTierThemeColor().withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getTierThemeColor().withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getTierIcon(),
                    size: 16,
                    color: _getTierThemeColor(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getTierHintText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTierThemeColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 属性列表
            ...attributeItems,
        
        // 底部操作按钮
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _showAddFeatureDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '输入',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _showAddSelectionAttribute(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.radio_button_checked, size: 20, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '单选',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  /// 构建floating label属性输入框
  Widget _buildFloatingLabelAttribute({
    required String labelText,
    required String value,
    String? suffix,
    required bool isSystem,
    String? attributeId,
    required TextInputType keyboardType,
    required Function(String) onChanged,
  }) {
    // 获取或创建控制器
    final controller = _getOrCreateController(
      isSystem: isSystem,
      attributeId: attributeId,
      labelText: labelText,
      initialValue: value,
    );
    
    // 确定验证规则
    List<TextInputFormatter> inputFormatters = [];
    String? helperText;
    
    // 系统属性的验证
    if (isSystem) {
      if (labelText == '交付期' && suffix == '天') {
        inputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
          _MaxValueTextInputFormatter(ValidationConstants.maxDeliveryDays),
        ];
        helperText = '最多${ValidationConstants.maxDeliveryDays}天';
      } else if (labelText == '次数' && suffix == '次') {
        inputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
          _MaxValueTextInputFormatter(ValidationConstants.maxEditNum),
        ];
        helperText = '最多${ValidationConstants.maxEditNum}次';
      }
    } else {
      // 自定义属性的验证 - 属性值最大长度
      inputFormatters = [
        LengthLimitingTextInputFormatter(ValidationConstants.maxAttributeValueLength),
      ];
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 主要的输入框
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: widget.isPreviewMode,
              inputFormatters: inputFormatters,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                floatingLabelStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
                suffixText: suffix,
                suffixStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                helperText: helperText,
                helperStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (newValue) {
                // 对于系统属性，直接更新值，inputFormatters已经处理了验证
                if (isSystem && newValue.isNotEmpty) {
                  final parsedValue = int.tryParse(newValue);
                  if (parsedValue != null && parsedValue > 0) {
                    // 添加防抖机制，避免频繁触发
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                      onChanged(newValue);
                    });
                  }
                } else {
                  // 自定义属性，使用防抖
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                    onChanged(newValue);
                  });
                }
              },
            ),
          ),

          // 删除按钮（仅对自定义属性显示）
          if (!isSystem && attributeId != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _removeProductAttribute(attributeId),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建布尔类型属性（单选）
  Widget _buildBooleanAttribute(ProductAttribute attribute) {
    final isTrue = attribute.value == 'true';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attribute.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _serviceTiers.getTierConfig(_selectedTier).updateAttributeValue(attribute.id, 'true');
                            });
                            _onFormFieldChanged();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isTrue ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isTrue ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  size: 20,
                                  color: isTrue ? Colors.blue : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '是',
                                  style: TextStyle(
                                    color: isTrue ? Colors.blue : Colors.grey[700],
                                    fontWeight: isTrue ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _serviceTiers.getTierConfig(_selectedTier).updateAttributeValue(attribute.id, 'false');
                            });
                            _onFormFieldChanged();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !isTrue ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  !isTrue ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  size: 20,
                                  color: !isTrue ? Colors.blue : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '否',
                                  style: TextStyle(
                                    color: !isTrue ? Colors.blue : Colors.grey[700],
                                    fontWeight: !isTrue ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 删除按钮
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _removeProductAttribute(attribute.id),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取或创建控制器
  TextEditingController _getOrCreateController({
    required bool isSystem,
    String? attributeId,
    required String labelText,
    required String initialValue,
  }) {
    String key;
    Map<String, TextEditingController> controllerMap;
    
    if (isSystem) {
      key = '${_selectedTier.name}_$labelText';
      controllerMap = _systemControllers;
    } else {
      key = attributeId ?? labelText;
      controllerMap = _attributeControllers;
    }
    
    if (!controllerMap.containsKey(key)) {
      controllerMap[key] = TextEditingController(text: initialValue);
    } else {
      // Controller 已存在，不覆盖 text —— controller 是输入的 source of truth
      // initialValue 可能因 debounce 而过时，强制覆盖会导致红色报错闪烁
    }
    
    return controllerMap[key]!;
  }
  
  /// 清理不再使用的控制器
  void _cleanupControllers() {
    // 清理属性控制器
    final currentAttributeIds = _serviceTiers.attributeTemplates.map((t) => t.id).toSet();
    final attributeKeysToRemove = _attributeControllers.keys
        .where((key) => !currentAttributeIds.contains(key))
        .toList();
    
    for (final key in attributeKeysToRemove) {
      _attributeControllers[key]?.dispose();
      _attributeControllers.remove(key);
    }
  }
  
  /// 显示添加单选属性对话框
  void _showAddSelectionAttribute() {
    final nameController = TextEditingController();
    final List<String> options = ['是', '否'];
    String? errorText;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加单选属性'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                maxLength: ValidationConstants.maxAttributeNameLength,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!?.product_edit_attribute_name_hint ?? 'Please enter attribute name',
                  helperText: AppLocalizations.of(context)!?.product_edit_max_characters != null 
                  ? AppLocalizations.of(context)!.product_edit_max_characters(ValidationConstants.maxAttributeNameLength)
                  : 'Max ${ValidationConstants.maxAttributeNameLength} characters',
                  errorText: errorText,
                  border: const OutlineInputBorder(),
                  counterText: '${nameController.text.length}/${ValidationConstants.maxAttributeNameLength}',
                ),
                autofocus: true,
                onChanged: (value) {
                  setDialogState(() {
                    if (value.length > ValidationConstants.maxAttributeNameLength) {
                      errorText = '属性名称最多${ValidationConstants.maxAttributeNameLength}个字符';
                    } else {
                      errorText = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                '默认选项：是/否',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    nameController.text.length <= ValidationConstants.maxAttributeNameLength) {
                  _addProductAttribute(
                    nameController.text,
                    'false', // 默认值为"否"
                    ProductAttributeType.boolean,
                    options: options,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  /// 添加商品属性
  void _addProductAttribute(
    String name, 
    String value, 
    ProductAttributeType type, {
    List<String> options = const [],
    bool isRequired = false,
    String placeholder = '',
  }) {
    setState(() {
      final template = ProductAttributeTemplate(
        name: name,
        type: type,
        options: options,
        isRequired: isRequired,
        placeholder: placeholder,
      );
      _serviceTiers.addAttributeTemplate(template);
      // 确保新属性的默认值 —— 使用 update 方法同步 controller
      for (final tier in ServiceTier.values) {
        final config = _serviceTiers.getTierConfig(tier);
        if (config.deliveryDay != 1) {
          config.updateDeliveryDay(1);
        }
        if (config.editNum != 1) {
          config.updateEditNum(1);
        }
      }
      // 为当前选中档位设置值
      _serviceTiers.getTierConfig(_selectedTier).updateAttributeValue(template.id, value);
    });
  }
  
  /// 删除商品属性
  void _removeProductAttribute(String attributeId) {
    setState(() {
      _serviceTiers.removeAttributeTemplate(attributeId);
      // 清理相关的控制器
      _attributeControllers[attributeId]?.dispose();
      _attributeControllers.remove(attributeId);
    });
    _onFormFieldChanged();
  }

  /// 获取或创建属性控制器
  TextEditingController _getAttributeController(String attributeId, String initialValue) {
    if (!_attributeControllers.containsKey(attributeId)) {
      _attributeControllers[attributeId] = TextEditingController(text: initialValue);
    }
    // Controller 已存在时不覆盖 text —— controller 是输入的 source of truth
    // initialValue 可能因 debounce 而过时，强制覆盖会导致红色报错闪烁
    return _attributeControllers[attributeId]!;
  }

  /// 更新属性值
  void _updateAttributeValue(String attributeId, String newValue) {
    setState(() {
      // 更新当前选中档位的属性值
      _serviceTiers.getTierConfig(_selectedTier).updateAttributeValue(attributeId, newValue);
    });
    // 触发变更检测
    _onFormFieldChanged();
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
      categoryId: state.formData?.categoryId,
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

  /// 清理未使用的属性控制器
  void _cleanupUnusedControllers() {
    final currentAttributeIds = <String>{};
    
    // 收集所有当前使用的属性ID（从属性模板中获取）
    for (final template in _serviceTiers.attributeTemplates) {
      currentAttributeIds.add(template.id);
    }
    
    // 移除不再使用的控制器
    final keysToRemove = _attributeControllers.keys
        .where((key) => !currentAttributeIds.contains(key))
        .toList();
    
    for (final key in keysToRemove) {
      _attributeControllers[key]?.dispose();
      _attributeControllers.remove(key);
    }
  }

  /// 显示编辑属性对话框
  void _showEditAttributeDialog(ProductAttribute feature) {
    final nameController = TextEditingController(text: feature.name);
    final placeholderController = TextEditingController(text: feature.placeholder);
    ProductAttributeType selectedType = feature.type;
    List<String> options = List<String>.from(feature.options);
    bool isRequired = feature.isRequired;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!?.product_edit_edit_attribute ?? 'Edit Product Attributes'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: double.maxFinite,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 属性名称
                  TextField(
                    controller: nameController,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '属性名称 *',
                      hintText: '例如：颜色、型号、材质、适用年龄',
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 属性类型选择
                  DropdownButtonFormField<ProductAttributeType>(
                    value: selectedType,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '属性类型',
                    ),
                    items: ProductAttributeType.values.map((type) => 
                      DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ),
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                        // 现在只有input和boolean类型，都不需要options
                        options.clear();
                        // 如果选择boolean类型，清除占位符文本和必填项设置
                        if (selectedType == ProductAttributeType.boolean) {
                          placeholderController.clear();
                          isRequired = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // boolean类型不需要options配置
                  
                  const SizedBox(height: 12),
                  
                  // 占位符文本（仅对input类型显示）
                  if (selectedType == ProductAttributeType.input) ...[
                    TextField(
                      controller: placeholderController,
                      decoration: _lightBorderDecoration.copyWith(
                        labelText: AppLocalizations.of(context)!?.product_edit_placeholder_label ?? 'Placeholder Text',
                        hintText: AppLocalizations.of(context)!?.product_edit_placeholder_hint ?? 'e.g., Please select color, Please enter model',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // 是否必填（仅对input类型显示）
                  if (selectedType == ProductAttributeType.input) ...[
                    Row(
                      children: [
                        Checkbox(
                          value: isRequired,
                          onChanged: (value) {
                            setState(() {
                              isRequired = value ?? false;
                            });
                          },
                        ),
                        const Text('必填项'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!?.product_edit_please_enter_attribute_name ?? 'Please enter attribute name')),
                  );
                  return;
                }
                
                // 现在只有input和boolean类型，不需要检查选项
                // 删除了选择类型的验证逻辑
                
                _updateAttributeConfig(
                  feature.id,
                  nameController.text,
                  selectedType,
                  options,
                  isRequired,
                  placeholderController.text,
                );
                
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBF7D2A),
                foregroundColor: Colors.white,
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  /// 更新属性配置
  void _updateAttributeConfig(
    String attributeId,
    String name,
    ProductAttributeType type,
    List<String> options,
    bool isRequired,
    String placeholder,
  ) {
    setState(() {
      final template = ProductAttributeTemplate(
        id: attributeId,
        name: name,
        type: type,
        options: options,
        isRequired: isRequired,
        placeholder: placeholder,
      );
      _serviceTiers.updateAttributeTemplate(attributeId, template);
    });
    // 触发变更检测
    _onFormFieldChanged();
  }
}