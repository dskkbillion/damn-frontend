import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';

/// 商品编辑页面
class ProductEditPage extends StatefulWidget {
  /// 商品ID（编辑模式）
  final String? productId;

  /// 构造函数
  const ProductEditPage({
    super.key,
    this.productId,
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
  
  /// 表单键
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  /// 图片选择器
  final ImagePicker _imagePicker = ImagePicker();
  
  /// 当前选中的价格类型（基础、进阶、豪华）
  int _selectedPriceType = 0;
  
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

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ProductEditBloc>();
    
    // 设置默认值
    _deliveryDaysController.text = '3';
    _editCountController.text = '2';
    
    // 初始化页面
    _bloc.add(InitializeProductEdit(
      productId: widget.productId != null ? int.tryParse(widget.productId!) : null,
    ));
    
    // 监听状态变化，更新控制器
    _bloc.stream.listen((state) {
      if (!state.isLoading && state.product != null) {
        _updateTextControllers(state.formData);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _deliveryDaysController.dispose();
    _editCountController.dispose();
    super.dispose();
  }

  /// 更新文本控制器的值
  void _updateTextControllers(ProductFormData formData) {
    _nameController.text = formData.name;
    _descriptionController.text = formData.description;
    _priceController.text = formData.price > 0 ? formData.price.toString() : '';
    // 如果有第一个规格选项，设置交付周期和修改次数
    if (formData.variants.isNotEmpty) {
      _deliveryDaysController.text = formData.variants.first.deliveryDay.toString();
      _editCountController.text = formData.variants.first.editNum.toString();
    }
  }

  /// 选择图片
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      final List<String> imagePaths = pickedFiles.map((file) => file.path).toList();
      _bloc.add(SelectProductImages(imagePaths: imagePaths));
    }
  }

  /// 提交表单
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 构建默认规格
      _bloc.add(UpdateFormField(fieldName: 'variants', value: [
        ProductOptionValue(
          id: 0,
          name: '基础套餐',
          optionName: '基础套餐',
          sellingPrice: double.tryParse(_priceController.text) ?? 0,
          deliveryDay: int.tryParse(_deliveryDaysController.text) ?? 3,
          editNum: int.tryParse(_editCountController.text) ?? 2,
        )
      ]));
      
      _bloc.add(const SubmitProductForm());
    }
  }
  
  /// 显示添加规格弹窗
  void _showAddSpecificationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildAddSpecificationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? '发布服务' : '编辑服务'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
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
      body: BlocConsumer<ProductEditBloc, ProductEditState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state.hasError) {
            // 显示错误提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? '操作失败'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.isSubmitSuccess) {
            // 提交成功，显示提示并返回
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.isCreateMode ? '服务创建成功' : '服务更新成功'),
                backgroundColor: Colors.green,
              ),
            );
            // 返回上一页
            Future.delayed(const Duration(milliseconds: 1500), () {
              context.pop();
            });
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return _buildFormContent(state);
        },
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
            child: TextField(
              controller: _nameController,
              decoration: _lightBorderDecoration.copyWith(
                hintText: '服务名称',
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              onChanged: (value) {
                _bloc.add(UpdateFormField(fieldName: 'name', value: value));
              },
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
              ),
              maxLines: 3,
              onChanged: (value) {
                _bloc.add(UpdateFormField(fieldName: 'description', value: value));
              },
            ),
          ),
          
          // 商品图片上传
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: _pickImages,
              child: state.selectedImagePaths.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/placeholder_image.png',
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.file(
                        File(state.selectedImagePaths.first),
                        fit: BoxFit.cover,
                      ),
                    ),
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
          // 价格标签切换
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedPriceType = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedPriceType == 0
                              ? const Color(0xFFBF7D2A)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      '基础金额',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedPriceType = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedPriceType == 1
                              ? const Color(0xFFBF7D2A)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      '进阶金额',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedPriceType = 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedPriceType == 2
                              ? const Color(0xFFBF7D2A)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      '豪华金额',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // 价格输入框
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _lightBorderDecoration.copyWith(
                hintText: '输入价格',
                prefixText: '¥ ',
              ),
              onChanged: (value) {
                final price = double.tryParse(value) ?? 0;
                _bloc.add(UpdateFormField(fieldName: 'price', value: price));
              },
            ),
          ),
        ],
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
                    controller: _deliveryDaysController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    decoration: _lightBorderDecoration.copyWith(
                      hintText: '天数 (如: 3)',
                    ),
                    onChanged: (value) {
                      // 更新默认交付周期
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
                  controller: _editCountController,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  decoration: _lightBorderDecoration.copyWith(
                    hintText: '次数 (如: 2)',
                  ),
                  onChanged: (value) {
                    // 更新默认修改次数
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
            '自定义服务规格',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '个性化服务规格',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 如果没有规格，显示提示
          if (state.formData.variants.isEmpty || state.formData.variants.length <= 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '还没有添加自定义规格。',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          
          // 如果有规格，显示规格列表
          if (state.formData.variants.length > 1)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.formData.variants.length - 1, // 减1是因为第一个是基础规格
                separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final variant = state.formData.variants[index + 1]; // +1跳过基础规格
                  return ListTile(
                    title: Text(variant.name),
                    subtitle: Text('¥${variant.sellingPrice}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _bloc.add(RemoveProductVariant(index: index + 1)),
                    ),
                  );
                },
              ),
            ),
          
          // 添加规格按钮
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            child: ElevatedButton.icon(
              onPressed: _showAddSpecificationDialog,
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
  
  /// 构建添加规格弹窗
  Widget _buildAddSpecificationDialog() {
    final specNameController = TextEditingController();
    bool isTextType = true; // 文本型或选项型
    
    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '添加新规格',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 规格类型选择
            const Text('规格类型', style: TextStyle(fontSize: 16)),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => isTextType = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTextType ? const Color(0xFFBF7D2A) : Colors.grey[200],
                      foregroundColor: isTextType ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('文本型'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => isTextType = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isTextType ? const Color(0xFFBF7D2A) : Colors.grey[200],
                      foregroundColor: !isTextType ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('选项型'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 规格名称
            const Text('规格名称', style: TextStyle(fontSize: 16)),
            
            const SizedBox(height: 8),
            
            TextField(
              controller: specNameController,
              decoration: InputDecoration(
                hintText: '例如: 源码、加急处理',
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
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 各套餐规格值
            const Text('各套餐规格值', style: TextStyle(fontSize: 16)),
            
            const SizedBox(height: 16),
            
            // 基础套餐
            const Text('基础套餐:', style: TextStyle(fontSize: 14)),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: const Text('包含'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('不包含'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 标准套餐
            const Text('标准套餐:', style: TextStyle(fontSize: 14)),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: const Text('包含'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('不包含'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 豪华套餐
            const Text('豪华套餐:', style: TextStyle(fontSize: 14)),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: const Text('包含'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('不包含'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 底部按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (specNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请输入规格名称')),
                      );
                      return;
                    }
                    
                    // 添加规格
                    _bloc.add(AddProductVariant());
                    // 更新最新添加的规格
                    _bloc.add(UpdateProductVariant(
                      index: _bloc.state.formData.variants.length - 1,
                      variantData: {
                        'name': specNameController.text,
                        'optionName': specNameController.text,
                      },
                    ));
                    
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF7D2A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('添加规格'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}