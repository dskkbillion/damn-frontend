import 'dart:async';
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
        title: const Text('检测到未保存的更改'),
        content: const Text('您有未保存的内容，是否要保存为草稿？'),
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
            child: const Text('保存草稿'),
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
        _formErrors['name'] = '请输入服务名称';
      });
      isValid = false;
    }
    
    // 验证商品描述
    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _formErrors['description'] = '请输入服务描述';
      });
      isValid = false;
    }
    
    // 验证商品图片
    if (_bloc.state.selectedImagePaths.isEmpty && (_bloc.state.product?.images.isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请至少上传一张商品图片'),
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
              hintText: '请输入属性名称',
              helperText: '最多${ValidationConstants.maxAttributeNameLength}个字符',
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
            ? '商品预览' 
            : (widget.productId == null ? '发布服务' : '编辑服务')),
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
              label: const Text('编辑'),
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
                        tooltip: '预览',
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
                      label: Text(state.hasUnsavedChanges ? '草稿*' : '草稿'),
                      style: TextButton.styleFrom(
                        foregroundColor: state.hasUnsavedChanges ? Colors.orange : Colors.grey,
                      ),
                    ),
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
            listener: (context, state) {
              if (state.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? '操作失败'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state.isDraftSaveSuccess && !_isReturning) {
                // 先检查是否已经mounted，避免在dispose后执行
                if (!mounted) return;
                
                // 设置标志，防止重复返回
                _isReturning = true;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('草稿保存成功'),
                    backgroundColor: Colors.green,
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
                      ? '服务发布成功！正在审核中，请在"在售"列表中查看' 
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
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // 标题
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "服务档位设置",
                style: TextStyle(
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
  

  

  

  
  /// 构建常见问题部分
  Widget _buildCommonQuestionsSection(ProductEditState state) {
    return Container(
      color: Colors.white,
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
              const Text(
                '常见问题编辑',
                style: TextStyle(
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
                        color: const Color(0xFFBF7D2A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_qaList.length}个问题',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBF7D2A),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                      // 展开/折叠图标
                      Icon(
                        _isQAExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
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
                label: const Text('添加问题'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFBF7D2A),
                  side: const BorderSide(color: Color(0xFFBF7D2A)),
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
        border: Border.all(color: Colors.grey[300]!),
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
                    labelText: '问题',
                    hintText: '输入买家可能问的问题',
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
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeQAPair(index),
                tooltip: '删除问题',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 答案输入
          TextField(
            readOnly: widget.isPreviewMode,
                  decoration: _lightBorderDecoration.copyWith(
              labelText: '答案',
              hintText: '输入对应的答案',
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
      color: Colors.white,
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
          const Text(
                '需要买家提供',
            style: TextStyle(
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
                        color: const Color(0xFFBF7D2A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_buyerInfoItems.length}项信息',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBF7D2A),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                      // 展开/折叠图标
                      Icon(
                        _isBuyerInfoExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
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
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '选择你需要买家提供的信息类型（该信息将展示在订单详情页）',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
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
              const Text(
                '已选择的信息项：',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
          border: Border.all(color: const Color(0xFFBF7D2A)),
                borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(_getIconForInfoType(type), color: const Color(0xFFBF7D2A)),
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
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
      child: Row(
                      children: [
          Icon(_getIconForInfoType(item.type), size: 20, color: const Color(0xFFBF7D2A)),
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
                          color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                          '必填',
                          style: TextStyle(fontSize: 10, color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFFBF7D2A)),
                onPressed: () => _showEditBuyerInfoDialog(index, item),
                tooltip: '编辑',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeBuyerInfoItem(index),
                tooltip: '删除',
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
          title: Text('添加${type.displayName}信息'),
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
                      labelText: '信息标签',
                      hintText: '例如：公司Logo设计需求',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '详细说明',
                      hintText: '请详细说明需要买家提供的信息内容',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('必填项'),
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
              child: const Text('取消'),
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
                    const SnackBar(content: Text('请输入信息标签')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBF7D2A),
                foregroundColor: Colors.white,
                ),
              child: const Text('添加'),
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
          title: Text('编辑${item.type.displayName}信息'),
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
                      labelText: '信息标签',
                      hintText: '例如：公司Logo设计需求',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '详细说明',
                      hintText: '请详细说明需要买家提供的信息内容',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('必填项'),
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
              child: const Text('取消'),
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
                    const SnackBar(content: Text('请输入信息标签')),
                  );
                }
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
  
  /// 构建成功案例部分
  Widget _buildSuccessCasesSection(ProductEditState state) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '成功案例',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.successCases.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBF7D2A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.successCases.length}个案例',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBF7D2A),
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
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              '添加案例',
              style: TextStyle(color: Colors.grey),
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
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 32, color: Colors.grey),
              SizedBox(height: 4),
              Text('图片加载失败', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          );
        },
      );
    }
    
    // 优先显示网络图片
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // 网络图片失败，尝试本地图片
          if (localPath != null && localPath.isNotEmpty) {
            return Image.file(
              File(localPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 32, color: Colors.grey),
                    SizedBox(height: 4),
                    Text('图片加载失败', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                );
              },
            );
          }
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 32, color: Colors.grey),
              SizedBox(height: 4),
              Text('图片加载失败', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          );
        },
      );
    }
    
    // 显示本地图片
    if (localPath != null && localPath.isNotEmpty) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 32, color: Colors.grey),
              SizedBox(height: 4),
              Text('图片加载失败', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          );
        },
      );
    }
    
    // 没有图片，显示占位符
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
        SizedBox(height: 4),
        Text('点击选择图片', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
            color: Colors.black.withOpacity(0.3),
          ),
          // 进度指示器
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: successCase.uploadProgress / 100,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '${successCase.uploadProgress.toInt()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
              color: Colors.grey,
              colorBlendMode: BlendMode.saturation,
            ),
          // 错误图标
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 4),
                const Text('上传失败', style: TextStyle(color: Colors.red, fontSize: 12)),
                if (successCase.canRetry)
                  TextButton(
                    onPressed: () => _bloc.add(RetrySuccessCaseUpload(caseId: successCase.id)),
                    child: const Text('重试', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
      );
    } else if (successCase.imageUrl.isNotEmpty) {
      // 已上传 - 显示网络图片
      imageWidget = Image.network(
        successCase.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // 如果网络图片加载失败，尝试使用本地图片
          if (successCase.imagePath.isNotEmpty) {
            return Image.file(
              File(successCase.imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                );
              },
            );
          }
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          );
        },
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
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          );
        },
      );
    } else {
      // 没有图片
      imageWidget = Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 40, color: Colors.grey),
      );
    }
    
    return imageWidget;
  }

  /// 构建成功案例项
  Widget _buildSuccessCaseItem(ProductEditState state, int index) {
    final successCase = state.successCases[index];
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
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
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // 删除按钮
                      InkWell(
                        onTap: () => _removeSuccessCase(successCase.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
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
                      style: const TextStyle(
                        fontSize: 12,
                color: Colors.grey,
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
          title: const Text('添加成功案例'),
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
                        border: Border.all(color: Colors.grey[300]!),
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
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
                                SizedBox(height: 4),
                                Text('点击选择图片', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 标题输入
                  TextField(
                    controller: titleController,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '案例标题',
                      hintText: '简短描述这个案例',
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 描述输入
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '案例描述',
                      hintText: '详细描述案例的背景、执行过程或效果',
                    ),
                  ),
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
                if (selectedImagePath != null && titleController.text.isNotEmpty) {
                  _addSuccessCase(
                    selectedImagePath!,
                    titleController.text,
                    descriptionController.text,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请选择图片并输入标题')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBF7D2A),
                foregroundColor: Colors.white,
              ),
              child: const Text('添加'),
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
          title: const Text('编辑成功案例'),
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
                        border: Border.all(color: Colors.grey[300]!),
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
                      labelText: '案例标题',
                      hintText: '简短描述这个案例',
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 描述输入
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '案例描述',
                      hintText: '详细描述案例的背景、执行过程或效果',
                    ),
                  ),
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
                    const SnackBar(content: Text('请选择图片并输入标题')),
                  );
                }
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
  
  /// 构建商品图片上传部分
  Widget _buildImageUploadSection(ProductEditState state) {
    return Container(
      color: Colors.white,
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
                '服务封面图',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
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
                '上传错误: ${state.errorMessage}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          
          // 图片上传说明
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '支持jpg、png、jpeg格式，单张不超过5MB，最多可上传9张图片',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
          color: Colors.blue[50],
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
              '上传中 ${state.uploadedCount}/${state.totalUploadCount}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      );
    } else if (state.uploadStatus == UploadStatus.success && state.uploadedImageUrls.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
            const SizedBox(width: 8),
            Text(
              '上传成功',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      );
    } else if (state.uploadStatus == UploadStatus.failure) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 16, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              '上传失败',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
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
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: localPath != null
                ? Image.file(
                    File(localPath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : networkUrl != null 
                    ? Image.network(
                        networkUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      ),
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
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
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
              child: const Text(
                '主图',
                style: TextStyle(color: Colors.white, fontSize: 10),
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
            color: canAdd ? Colors.grey[300]! : Colors.grey[200]!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: canAdd ? Colors.white : Colors.grey[100],
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
              color: canAdd ? Theme.of(context).primaryColor : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              isUploading ? '上传中...' : '添加图片',
              style: TextStyle(
                fontSize: 12,
                color: canAdd ? Colors.grey[700] : Colors.grey,
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
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tier.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.grey[700],
                ),
              ),
              if (hasPrice) ...[
                const SizedBox(height: 2),
                Text(
                  '${RegionConfig.currencySymbol}${tierConfig.price.toStringAsFixed(tierConfig.price % 1 == 0 ? 0 : 2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.grey[600],
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
        setState(() {
          final price = double.tryParse(value) ?? 0;
          tierConfig.updatePrice(price);
          
          // 验证价格
          if (price > ValidationConstants.maxPrice) {
            _formErrors['price_${_selectedTier.name}'] = '价格不能超过${ValidationConstants.maxPrice}';
          } else if (price > 0 && price < 0.01) {
            _formErrors['price_${_selectedTier.name}'] = '价格最小值为0.01';
          } else {
            _formErrors.remove('price_${_selectedTier.name}');
          }
        });
        _onFormFieldChanged();
      },
    );
  }

  /// 构建档位属性列表
  Widget _buildTierAttributesList() {
    final tierConfig = _serviceTiers.getTierConfig(_selectedTier);
    
    // 构建所有属性的列表（包括系统属性和自定义属性）
    final List<Widget> attributeItems = [];
    
    // 添加系统属性：交付期
    attributeItems.add(_buildFloatingLabelAttribute(
      labelText: '交付期',
      value: tierConfig.deliveryDay.toString(),
      suffix: '天',
      isSystem: true,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final parsedValue = int.tryParse(value);
        if (parsedValue != null && parsedValue > 0) {
          setState(() {
            tierConfig.updateDeliveryDay(parsedValue);
          });
          _onFormFieldChanged();
        }
      },
    ));
    
    // 添加系统属性：次数
    attributeItems.add(_buildFloatingLabelAttribute(
      labelText: '次数',
      value: tierConfig.editNum.toString(),
      suffix: '次',
      isSystem: true,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final parsedValue = int.tryParse(value);
        if (parsedValue != null && parsedValue > 0) {
          setState(() {
            tierConfig.updateEditNum(parsedValue);
          });
          _onFormFieldChanged();
        }
      },
    ));
    
    // 添加自定义属性
    final customAttributes = _serviceTiers.getAttributesForTier(_selectedTier);
    for (final attr in customAttributes) {
      if (attr.type == ProductAttributeType.boolean) {
        // 单选属性使用特殊的显示方式
        attributeItems.add(_buildBooleanAttribute(attr));
      } else {
        // 文本输入属性
        attributeItems.add(_buildFloatingLabelAttribute(
          labelText: attr.name,
          value: attr.value,
          isSystem: false,
          attributeId: attr.id,
          keyboardType: TextInputType.text,
          onChanged: (value) {
            setState(() {
              _serviceTiers.getTierConfig(_selectedTier).updateAttributeValue(attr.id, value);
            });
            _onFormFieldChanged();
          },
        ));
      }
    }
    
    return Column(
      children: [
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
      // 更新现有控制器的值（如果不同）
      final controller = controllerMap[key]!;
      if (controller.text != initialValue) {
        // 保存当前光标位置
        final selection = controller.selection;
        controller.text = initialValue;
        // 恢复光标位置（如果合理）
        if (selection.isValid && selection.end <= initialValue.length) {
          controller.selection = selection;
        }
      }
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
                  hintText: '请输入属性名称',
                  helperText: '最多${ValidationConstants.maxAttributeNameLength}个字符',
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
    // 如果初始值发生变化，更新控制器的文本（但不移动光标）
    final controller = _attributeControllers[attributeId]!;
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
    
    return ExtendedProductFormData(
      productId: widget.productId != null ? int.tryParse(widget.productId!) : null,
      name: _nameController.text,
      description: _descriptionController.text,
      price: variants.isNotEmpty ? variants.first.sellingPrice : 0.0,
      categoryId: state.formData?.categoryId,
      variants: variants,
      productMaterials: [],
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
          title: const Text('编辑商品属性'),
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
                        labelText: '占位符文本',
                        hintText: '例如：请选择颜色、请输入型号',
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
                    const SnackBar(content: Text('请输入属性名称')),
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