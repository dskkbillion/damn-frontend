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
  
  /// 表单键
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  /// 图片选择器
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ProductEditBloc>();
    
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
    super.dispose();
  }

  /// 更新文本控制器的值
  void _updateTextControllers(ProductFormData formData) {
    _nameController.text = formData.name;
    _descriptionController.text = formData.description;
    _priceController.text = formData.price > 0 ? formData.price.toString() : '';
  }

  /// 选择图片
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      final List<String> imagePaths = pickedFiles.map((file) => file.path).toList();
      _bloc.add(SelectProductImages(imagePaths: imagePaths));
    }
  }

  /// 选择详情图
  Future<void> _pickDetailImages() async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      final List<String> imagePaths = pickedFiles.map((file) => file.path).toList();
      _bloc.add(SelectDetailProductImages(imagePaths: imagePaths));
    }
  }

  /// 添加规格选项
  void _addVariant() {
    _bloc.add(const AddProductVariant());
  }

  /// 移除规格选项
  void _removeVariant(int index) {
    _bloc.add(RemoveProductVariant(index: index));
  }

  /// 更新规格选项
  void _updateVariant(int index, String field, dynamic value) {
    _bloc.add(UpdateProductVariant(
      index: index,
      variantData: {field: value},
    ));
  }

  /// 添加材料问题
  void _addMaterial() {
    _bloc.add(const AddProductMaterial());
  }

  /// 移除材料问题
  void _removeMaterial(int index) {
    _bloc.add(RemoveProductMaterial(index: index));
  }

  /// 更新材料问题
  void _updateMaterial(int index, String field, dynamic value) {
    _bloc.add(UpdateProductMaterial(
      index: index,
      materialData: {field: value},
    ));
  }

  /// 提交表单
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _bloc.add(const SubmitProductForm());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? '创建商品' : '编辑商品'),
        actions: [
          if (widget.productId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                // 确认删除对话框
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('确定要删除该商品吗？此操作不可撤销。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // 调用删除逻辑
                        },
                        child: const Text('删除', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
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
                content: Text(state.isCreateMode ? '商品创建成功' : '商品更新成功'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息表单
            _buildBasicInfoForm(state),
            const SizedBox(height: 24),
            
            // 商品图片
            _buildImageSection(state),
            const SizedBox(height: 24),
            
            // 详情图片
            _buildDetailImageSection(state),
            const SizedBox(height: 24),
            
            // 规格选项
            _buildVariantsSection(state),
            const SizedBox(height: 24),
            
            // 自定义材料问题
            _buildMaterialsSection(state),
            const SizedBox(height: 32),
            
            // 提交按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: state.isSubmitting 
                  ? const CircularProgressIndicator() 
                  : Text(state.isCreateMode ? '创建商品' : '保存修改'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片上传区域
  Widget _buildImageSection(ProductEditState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '商品主图',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text('请上传清晰的商品主图，最多6张，将作为列表和预览展示'),
        const SizedBox(height: 16),
        
        // 图片预览和上传按钮
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // 已选择的本地图片
              ...state.selectedImagePaths.map((path) => _buildImageItem(File(path), true)),
              
              // 数据库中已有的图片（如果是编辑模式且没有选择新图片）
              if (state.selectedImagePaths.isEmpty && 
                  state.product != null && 
                  state.product!.images.isNotEmpty)
                ...state.product!.images.split(',').map((url) => _buildImageItem(url, false)),
              
              // 添加图片按钮
              if ((state.selectedImagePaths.length + 
                  (state.selectedImagePaths.isEmpty && state.product != null 
                      ? state.product!.images.split(',').length 
                      : 0)) < 6)
                _buildAddImageButton(_pickImages),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建详情图上传区域
  Widget _buildDetailImageSection(ProductEditState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '商品详情图',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text('请上传商品详情图，最多10张，将展示在商品详情页'),
        const SizedBox(height: 16),
        
        // 图片预览和上传按钮
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // 已选择的本地详情图片
              ...state.selectedDetailImagePaths.map((path) => _buildImageItem(File(path), true)),
              
              // 添加图片按钮
              if (state.selectedDetailImagePaths.length < 10)
                _buildAddImageButton(_pickDetailImages),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建图片项
  Widget _buildImageItem(dynamic image, bool isLocal) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isLocal 
            ? Image.file(image as File, fit: BoxFit.cover)
            : Image.network(image as String, fit: BoxFit.cover),
      ),
    );
  }

  /// 构建添加图片按钮
  Widget _buildAddImageButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Icon(
          Icons.add_photo_alternate_outlined,
          size: 32,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// 构建基本信息表单
  Widget _buildBasicInfoForm(ProductEditState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '基本信息',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // 商品名称
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '商品名称',
            hintText: '请输入商品名称',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入商品名称';
            }
            return null;
          },
          onChanged: (value) {
            _bloc.add(UpdateFormField(fieldName: 'name', value: value));
          },
        ),
        const SizedBox(height: 16),
        
        // 商品描述
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '商品描述',
            hintText: '请输入商品描述',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入商品描述';
            }
            return null;
          },
          onChanged: (value) {
            _bloc.add(UpdateFormField(fieldName: 'description', value: value));
          },
        ),
        const SizedBox(height: 16),
        
        // 商品价格
        TextFormField(
          controller: _priceController,
          decoration: const InputDecoration(
            labelText: '商品价格',
            hintText: '请输入商品价格',
            border: OutlineInputBorder(),
            prefixText: '¥ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入商品价格';
            }
            if (double.tryParse(value) == null) {
              return '请输入有效的价格';
            }
            if (double.parse(value) <= 0) {
              return '价格必须大于0';
            }
            return null;
          },
          onChanged: (value) {
            final price = double.tryParse(value) ?? 0;
            _bloc.add(UpdateFormField(fieldName: 'price', value: price));
          },
        ),
        const SizedBox(height: 16),
        
        // 商品类别选择
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: '商品类别',
            hintText: '请选择商品类别',
            border: OutlineInputBorder(),
          ),
          value: state.formData.categoryId,
          items: state.categories?.map((category) {
            return DropdownMenuItem<int>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList() ?? [],
          onChanged: (value) {
            if (value != null) {
              _bloc.add(UpdateFormField(fieldName: 'categoryId', value: value));
            }
          },
        ),
      ],
    );
  }

  /// 构建规格选项区域
  Widget _buildVariantsSection(ProductEditState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '规格选项',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addVariant,
              icon: const Icon(Icons.add),
              label: const Text('添加规格'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('添加商品的不同规格选项，例如颜色、尺寸等'),
        const SizedBox(height: 16),
        
        // 规格选项列表
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.formData.variants.length,
          itemBuilder: (context, index) {
            final variant = state.formData.variants[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '规格 #${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeVariant(index),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 规格名称
                    TextFormField(
                      initialValue: variant.optionName,
                      decoration: const InputDecoration(
                        labelText: '规格名称',
                        hintText: '例如：基础、标准、高级',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _updateVariant(index, 'name', value),
                    ),
                    const SizedBox(height: 8),
                    
                    // 规格值 (不再显示，使用name代替)
                    
                    // 规格价格和交付时间
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: variant.sellingPrice > 0 ? variant.sellingPrice.toString() : variant.price.toString(),
                            decoration: const InputDecoration(
                              labelText: '价格',
                              hintText: '0',
                              border: OutlineInputBorder(),
                              prefixText: '¥ ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) {
                              final price = double.tryParse(value) ?? 0;
                              _updateVariant(index, 'sellingPrice', price);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: variant.deliveryDay.toString(),
                            decoration: const InputDecoration(
                              labelText: '交付天数',
                              hintText: '3',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final days = int.tryParse(value) ?? 3;
                              _updateVariant(index, 'deliveryDay', days);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 修改次数和库存
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: variant.editNum.toString(),
                            decoration: const InputDecoration(
                              labelText: '修改次数',
                              hintText: '1',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final editNum = int.tryParse(value) ?? 1;
                              _updateVariant(index, 'editNum', editNum);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: variant.stock.toString(),
                            decoration: const InputDecoration(
                              labelText: '库存',
                              hintText: '0',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final stock = int.tryParse(value) ?? 0;
                              _updateVariant(index, 'stock', stock);
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    // 功能特性（这里可以添加功能特性的管理，但为简化起见，暂时不实现）
                    const SizedBox(height: 8),
                    const Text(
                      '功能特性在创建后可以编辑',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建自定义材料问题区域
  Widget _buildMaterialsSection(ProductEditState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '自定义材料问题',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addMaterial,
              icon: const Icon(Icons.add),
              label: const Text('添加问题'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('添加商品定制所需的材料问题，顾客下单时需要回答'),
        const SizedBox(height: 16),
        
        // 材料问题列表
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.formData.productMaterials.length,
          itemBuilder: (context, index) {
            final material = state.formData.productMaterials[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '问题 #${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeMaterial(index),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 问题内容
                    TextFormField(
                      initialValue: material.question,
                      decoration: const InputDecoration(
                        labelText: '问题内容',
                        hintText: '例如：请提供定制内容、请上传参考图片',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _updateMaterial(index, 'question', value),
                    ),
                    const SizedBox(height: 8),
                    
                    // 默认答案
                    TextFormField(
                      initialValue: material.answer,
                      decoration: const InputDecoration(
                        labelText: '默认答案/提示',
                        hintText: '可选，为买家提供参考答案或提示',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _updateMaterial(index, 'answer', value),
                    ),
                    const SizedBox(height: 8),
                    
                    // 问题类型
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '回答类型',
                        border: OutlineInputBorder(),
                      ),
                      value: material.type,
                      items: const [
                        DropdownMenuItem(value: 'TEXT', child: Text('文本')),
                        DropdownMenuItem(value: 'FILE', child: Text('文件上传')),
                        DropdownMenuItem(value: 'PROBLEM', child: Text('问题')),
                        DropdownMenuItem(value: 'ATTACHMENT', child: Text('附件')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _updateMaterial(index, 'type', value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}