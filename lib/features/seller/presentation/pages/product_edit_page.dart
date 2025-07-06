import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';

/// 规格价格管理类
class PriceVariant {
  String name; // 规格名称
  double price; // 价格
  int deliveryDay; // 交付天数
  int editNum; // 修改次数
  bool isDefault; // 是否是默认规格
  TextEditingController priceController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  TextEditingController editNumController = TextEditingController();
  
  PriceVariant({
    required this.name,
    this.price = 0,
    this.deliveryDay = 3,
    this.editNum = 1,
    this.isDefault = false,
  }) {
    priceController.text = price > 0 ? price.toString() : '';
    deliveryController.text = deliveryDay.toString();
    editNumController.text = editNum.toString();
  }

  // 从ProductOptionValue创建PriceVariant
  factory PriceVariant.fromProductOptionValue(ProductOptionValue value, {bool isDefault = false}) {
    return PriceVariant(
      name: value.name.isNotEmpty ? value.name : value.optionName,
      price: value.sellingPrice > 0 ? value.sellingPrice : value.price,
      deliveryDay: value.deliveryDay,
      editNum: value.editNum,
      isDefault: isDefault,
    );
  }

  // 转换为ProductOptionValue
  ProductOptionValue toProductOptionValue() {
    return ProductOptionValue(
      id: 0, // 新建规格ID为0，后端会分配真实ID
      name: name,
      optionName: name,
      sellingPrice: price,
      deliveryDay: deliveryDay,
      editNum: editNum,
    );
  }
}

/// 商品编辑页面
class ProductEditPage extends StatefulWidget {
  /// 商品ID（编辑模式）
  final String? productId;
  
  /// 草稿保存成功回调
  final VoidCallback? onDraftSaved;

  /// 构造函数
  const ProductEditPage({
    super.key,
    this.productId,
    this.onDraftSaved,
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
  
  /// 商品价格控制器
  final TextEditingController _priceController = TextEditingController();
  
  /// 交付周期控制器
  final TextEditingController _deliveryDaysController = TextEditingController();
  
  /// 修改次数控制器
  final TextEditingController _editCountController = TextEditingController();
  
  /// 规格列表，包含默认的和用户添加的
  List<PriceVariant> _variants = [];
  
  /// 当前选中的规格索引
  int _selectedVariantIndex = 0;
  
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

  @override
  void initState() {
    super.initState();
    // 从DI容器获取BLoC实例
    _bloc = getIt<ProductEditBloc>();
    
    // 初始化默认的三种规格
    _variants.add(PriceVariant(name: '基础', deliveryDay: 3, editNum: 1, isDefault: true));
    _variants.add(PriceVariant(name: '标准', deliveryDay: 4, editNum: 2, isDefault: true));
    _variants.add(PriceVariant(name: '豪华', deliveryDay: 5, editNum: 2, isDefault: true));
    
    // 初始化页面
    _bloc.add(InitializeProductEdit(
      productId: widget.productId != null ? int.tryParse(widget.productId!) : null,
    ));
    
    // 监听输入框变化，自动检查是否有变更
    _nameController.addListener(_onFormFieldChanged);
    _descriptionController.addListener(_onFormFieldChanged);
    
    // 监听状态变化，更新控制器
    _bloc.stream.listen((state) {
      if (!state.isLoading && state.product != null) {
        _updateTextControllers(state.formData);
        // 设置初始数据用于变更检测
        if (state.initialFormData == null) {
          _bloc.add(SetInitialFormData(initialData: state.formData));
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormFieldChanged);
    _descriptionController.removeListener(_onFormFieldChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    
    // 释放所有规格控制器
    for (var variant in _variants) {
      variant.priceController.dispose();
      variant.deliveryController.dispose();
      variant.editNumController.dispose();
    }
    
    super.dispose();
  }

  /// 表单字段变化时检查变更
  void _onFormFieldChanged() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _bloc.add(const CheckForUnsavedChanges());
      }
    });
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

  /// 更新文本控制器的值
  void _updateTextControllers(ProductFormData formData) {
    _nameController.text = formData.name;
    _descriptionController.text = formData.description;
    
    // 如果是编辑模式且有变体数据，更新到本地规格列表
    if (formData.variants.isNotEmpty && !_bloc.state.isCreateMode) {
      setState(() {
        _variants.clear();
        
        // 为已有的规格标记默认属性（前三个）
        int defaultCount = 0;
        for (var variant in formData.variants) {
          bool isDefault = defaultCount < 3;
          _variants.add(PriceVariant.fromProductOptionValue(variant, isDefault: isDefault));
          defaultCount++;
        }
        
        // 如果现有规格少于3个，添加默认规格补齐
        if (_variants.length < 3) {
          final defaultNames = ['基础', '标准', '豪华'];
          final defaultDays = [3, 4, 5];
          final defaultEdits = [1, 2, 2];
          
          for (int i = _variants.length; i < 3; i++) {
            _variants.add(PriceVariant(
              name: defaultNames[i],
              deliveryDay: defaultDays[i],
              editNum: defaultEdits[i],
              isDefault: true,
            ));
          }
        }
      });
    }
  }

  /// 添加新规格方法
  void _addNewVariant(String name, double price, int deliveryDay, int editNum) {
    if (_variants.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能添加6种规格')),
      );
      return;
    }
    
    setState(() {
      _variants.add(PriceVariant(
        name: name,
        price: price,
        deliveryDay: deliveryDay,
        editNum: editNum,
      ));
      _selectedVariantIndex = _variants.length - 1; // 添加后自动选中新添加的
    });
  }
  
  /// 删除规格方法
  void _removeVariant(int index) {
    if (_variants[index].isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('默认规格不能删除')),
      );
      return;
    }
    
    setState(() {
      _variants.removeAt(index);
      if (_selectedVariantIndex >= _variants.length) {
        _selectedVariantIndex = _variants.length - 1;
      }
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
    
    // 验证每个规格的价格
    for (int i = 0; i < _variants.length; i++) {
      final variant = _variants[i];
      if (variant.price <= 0) {
        setState(() {
          _formErrors['price_$i'] = '${variant.name}价格必须大于0';
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
    
    // 所有验证通过，构建规格数据并提交
    List<ProductOptionValue> variants = _variants.map((variant) => variant.toProductOptionValue()).toList();
    
    // 更新表单数据中的规格
    _bloc.add(UpdateFormField(fieldName: 'variants', value: variants));
    
    // 设置基础价格为第一个规格的价格
    if (_variants.isNotEmpty) {
      _bloc.add(UpdateFormField(
        fieldName: 'price', 
        value: _variants[0].price
      ));
    }
    
    // 提交表单
    _bloc.add(const SubmitProductForm());
  }
  
  /// 显示添加规格弹窗
  void _showAddVariantDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final deliveryController = TextEditingController(text: '3');
    final editNumController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加新规格'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: _lightBorderDecoration.copyWith(
                labelText: '规格名称',
                hintText: '例如: 加急服务',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: _lightBorderDecoration.copyWith(
                labelText: '价格',
                prefixText: '¥ ',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: deliveryController,
                    keyboardType: TextInputType.number,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '交付天数',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: editNumController,
                    keyboardType: TextInputType.number,
                    decoration: _lightBorderDecoration.copyWith(
                      labelText: '修改次数',
                    ),
                  ),
                ),
              ],
            ),
          ],
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
                  const SnackBar(content: Text('请输入规格名称')),
                );
                return;
              }
              
              _addNewVariant(
                nameController.text,
                double.tryParse(priceController.text) ?? 0,
                int.tryParse(deliveryController.text) ?? 3,
                int.tryParse(editNumController.text) ?? 1,
              );
              
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBF7D2A),
              foregroundColor: Colors.white,
            ),
            child: const Text('添加'),
          ),
        ],
      ),
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
          title: Text(widget.productId == null ? '发布服务' : '编辑服务'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _handleBackPress();
            },
          ),
          actions: [
            // 保存草稿按钮 - 放在body的BlocConsumer中处理，避免Provider作用域问题
            BlocBuilder<ProductEditBloc, ProductEditState>(
              bloc: _bloc, // 直接指定bloc实例
              builder: (context, state) {
                if (state.hasUnsavedChanges) {
                  return TextButton.icon(
                    onPressed: state.isSavingDraft ? null : () {
                      _bloc.add(const SaveProductDraft());
                    },
                    icon: state.isSavingDraft
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_alt),
                    label: const Text('草稿'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  );
                }
                return const SizedBox.shrink();
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
              } else if (state.isDraftSaveSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('草稿保存成功'),
                    backgroundColor: Colors.green,
                  ),
                );
                // 通知父页面刷新草稿列表
                widget.onDraftSaved?.call();
              } else if (state.isSubmitSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.isCreateMode ? '服务创建成功' : '服务更新成功'),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(milliseconds: 1500), () {
                  context.pop();
                });
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return Stack(
                children: [
                  _buildFormContent(state),
                ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息表单
            _buildBasicInfoForm(state),
            
            // 价格选项卡
            _buildPriceTabsSection(),
            
            // 交付信息
            _buildDeliverySection(),
            
            // 自定义服务规格
            _buildServiceSpecificationSection(state),
            
            // 常见问题编辑
            _buildCommonQuestionsSection(state),
            
            // 买家需要提供的信息
            _buildBuyerInfoSection(state),
            
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
  
  /// 构建价格选项卡
  Widget _buildPriceTabsSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // 标题和说明
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "规格价格设置",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 添加新规格按钮，在数量小于6时显示
                if (_variants.length < 6)
                  TextButton.icon(
                    onPressed: _showAddVariantDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("添加规格"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFBF7D2A),
                    ),
                  ),
              ],
            ),
          ),
          
          // 显示所有规格的选项卡，可滚动
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (int i = 0; i < _variants.length; i++)
                  _buildVariantTab(i),
              ],
            ),
          ),
          
          // 价格输入框，显示当前选中规格的价格
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _variants[_selectedVariantIndex].priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _lightBorderDecoration.copyWith(
                hintText: '输入价格',
                prefixText: '¥ ',
                labelText: '${_variants[_selectedVariantIndex].name}价格',
                errorText: _formErrors['price_$_selectedVariantIndex'],
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
                setState(() {
                  _variants[_selectedVariantIndex].price = double.tryParse(value) ?? 0;
                  // 输入时清除该字段的错误
                  _formErrors.remove('price_$_selectedVariantIndex');
                });
                // 触发变更检测
                _onFormFieldChanged();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建单个规格Tab
  Widget _buildVariantTab(int index) {
    return InkWell(
      onTap: () => setState(() => _selectedVariantIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedVariantIndex == index
                  ? const Color(0xFFBF7D2A)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _variants[index].name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            // 如果不是默认规格，显示删除按钮
            if (!_variants[index].isDefault) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _removeVariant(index),
                child: const Icon(Icons.close, size: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 构建交付信息部分
  Widget _buildDeliverySection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前编辑的规格提示
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              '当前编辑: ${_variants[_selectedVariantIndex].name}规格',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFBF7D2A),
              ),
            ),
          ),
          
          // 交付周期
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('交付周期(天)', 
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _variants[_selectedVariantIndex].deliveryController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    decoration: _lightBorderDecoration.copyWith(
                      hintText: '天数 (如: 3)',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _variants[_selectedVariantIndex].deliveryDay = int.tryParse(value) ?? 3;
                      });
                      // 触发变更检测
                      _onFormFieldChanged();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 修改次数
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('修改次数', 
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _variants[_selectedVariantIndex].editNumController,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  decoration: _lightBorderDecoration.copyWith(
                    hintText: '次数 (如: 2)',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _variants[_selectedVariantIndex].editNum = int.tryParse(value) ?? 1;
                    });
                    // 触发变更检测
                    _onFormFieldChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 构建服务规格部分
  Widget _buildServiceSpecificationSection(ProductEditState state) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '当前规格列表',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '展示所有已创建的规格，包括基础、标准和豪华规格',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 如果没有规格，显示提示
          if (_variants.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '还没有添加规格。',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          
          // 如果有规格，显示规格列表
          if (_variants.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _variants.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final variant = _variants[index];
                  return ListTile(
                    title: Row(
                      children: [
                        Text(variant.name),
                        if (variant.isDefault)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '默认',
                              style: TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text('¥${variant.price} | 交付: ${variant.deliveryDay}天 | 修改: ${variant.editNum}次'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 编辑按钮 - 点击后选中该规格
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFFBF7D2A)),
                          onPressed: () => setState(() => _selectedVariantIndex = index),
                          tooltip: '编辑规格',
                        ),
                        // 对非默认规格显示删除按钮
                        if (!variant.isDefault)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeVariant(index),
                            tooltip: '删除规格',
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          
          // 添加规格按钮（仅当规格数量少于6个时显示）
          if (_variants.length < 6)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            child: ElevatedButton.icon(
                onPressed: _showAddVariantDialog,
              icon: const Icon(Icons.add),
              label: const Text('添加新规格'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBF7D2A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '常见问题编辑',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.expand_more),
                onPressed: () {
                  // 折叠/展开逻辑
                },
              ),
            ],
          ),
          
          TextField(
            decoration: _lightBorderDecoration.copyWith(
              hintText: '添加买家可能的问题',
              hintStyle: const TextStyle(color: Colors.grey),
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '需要买家提供',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.expand_more),
                onPressed: () {
                  // 折叠/展开逻辑
                },
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.all(12),
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
        ],
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
          const Text(
            '成功案例',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 添加案例图片按钮
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.add, size: 32),
                onPressed: () {
                  // 添加成功案例图片
                },
                color: Colors.black54,
              ),
            ),
          ),
        ],
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
    // 确定图片来源：本地选择的图片或者已有的产品图片
    final List<String> imagePaths = state.selectedImagePaths;
    final List<String> networkImageUrls = [];
    
    // 安全地获取网络图片URLs
    if (state.product != null && state.product!.images.isNotEmpty) {
      networkImageUrls.addAll(state.product!.images.split(','));
    }
        
    // 确定要显示的图片数量，包括"添加"按钮格子
    final bool hasImages = imagePaths.isNotEmpty || networkImageUrls.isNotEmpty;
    int totalItemCount = hasImages ? (imagePaths.isNotEmpty ? imagePaths.length : networkImageUrls.length) + 1 : 1;
    
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
        // 显示已有图片
        else if (index < (imagePaths.isNotEmpty ? imagePaths.length : networkImageUrls.length)) {
          final String? localImagePath = imagePaths.isNotEmpty && index < imagePaths.length 
              ? imagePaths[index] 
              : null;
              
          final String? networkImageUrl = imagePaths.isEmpty && 
                                          networkImageUrls.isNotEmpty && 
                                          index < networkImageUrls.length 
              ? networkImageUrls[index] 
              : null;
              
          return _buildImageItem(state, index, localImagePath, networkImageUrl);
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
    return Stack(
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
    );
  }
  
  // 构建添加图片按钮
  Widget _buildAddImageButton(ProductEditState state) {
    bool canAdd = (state.selectedImagePaths.length < 9) &&
                 (state.uploadStatus != UploadStatus.uploading);
                 
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
            Icon(
              Icons.add_photo_alternate_outlined,
              color: canAdd ? Theme.of(context).primaryColor : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              '添加图片',
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
    if (_bloc.state.selectedImagePaths.isNotEmpty) {
      final newPaths = List<String>.from(_bloc.state.selectedImagePaths);
      newPaths.removeAt(index);
      
      _bloc.add(SelectProductImages(imagePaths: newPaths));
    } else if (_bloc.state.product != null && _bloc.state.product!.images.isNotEmpty) {
      // 处理网络图片删除 - 转换为本地选择模式
      final imageParts = _bloc.state.product!.images.split(',');
      if (index < imageParts.length) {
        final newParts = List<String>.from(imageParts);
        newParts.removeAt(index);
        
        // 转换为selectedImagePaths，同时保留已上传的URLs
        _bloc.add(UpdateFormField(
          fieldName: 'images',
          value: newParts.join(','),
        ));
      }
    }
  }
}