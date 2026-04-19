import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/product_detail.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/widgets/product_detail_content.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_state.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/product_edit_models.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/usecases/get_logged_in_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_info_repository.dart';
import 'package:go_router/go_router.dart';
import 'product_edit_page.dart'; // 导入ExtendedProductFormData
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/loading_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 商品预览页面 - 使用与商品详情页一致的UI
class ProductPreviewPage extends StatefulWidget {
  final String? productId;
  final ExtendedProductFormData? formData; // 从编辑页面传入的表单数据

  const ProductPreviewPage({
    Key? key,
    this.productId,
    this.formData,
  }) : super(key: key);

  @override
  State<ProductPreviewPage> createState() => _ProductPreviewPageState();
}

class _ProductPreviewPageState extends State<ProductPreviewPage> {
  late final ProductEditBloc _bloc;
  ProductDetail? _productDetail;
  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<ProductEditBloc>();
    _getCurrentUserInfo();
    
    if (widget.productId != null) {
      final productIdInt = int.tryParse(widget.productId!) ?? 0;
      if (productIdInt > 0) {
        _bloc.add(InitializeProductEdit(productId: productIdInt));
      }
    } else if (widget.formData != null) {
      // 如果是从编辑页面传入的数据，直接转换
      _productDetail = _convertFormDataToProductDetail(widget.formData!);
    }
  }

  /// 获取当前用户信息
  void _getCurrentUserInfo() async {
    // Set default value first
    if (mounted) {
      setState(() {
        _currentUserName = AppLocalizations.of(context)?.product_preview_current_seller ?? 'Current Seller';
      });
    }
    try {
      // 首先获取登录用户
      final getLoggedInUser = GetIt.I<GetLoggedInUserUseCase>();
      final userResult = getLoggedInUser.call();
      
      userResult.fold(
        (failure) {
          print('[PreviewPage] Failed to get logged in user: $failure');
        },
        (authUser) async {
          if (authUser != null) {
            // 获取用户详细信息
            final userInfoRepo = GetIt.I<IUserInfoRepository>();
            final userInfoResult = await userInfoRepo.fetchUserInfo(authUser.token);
            
            userInfoResult.fold(
              (failure) {
                print('[PreviewPage] Failed to get user info: $failure');
              },
              (userInfo) {
                if (mounted) {
                  setState(() {
                    _currentUserName = userInfo.nickName ?? (AppLocalizations.of(context)?.product_preview_seller_user ?? 'Seller User');
                  });
                  print('[PreviewPage] Got user name: $_currentUserName');
                }
              },
            );
          }
        },
      );
    } catch (e) {
      print('[PreviewPage] Error getting user info: $e');
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  /// 将表单数据转换为商品详情数据
  ProductDetail _convertFormDataToProductDetail(ExtendedProductFormData formData) {
    print('[PreviewPage] Converting form data:');
    print('  - Name: "${formData.name}"');
    print('  - Description: "${formData.description}"');
    print('  - Price: ${formData.price}');
    print('  - Variants count: ${formData.variants.length}');
    print('  - Images count: ${formData.images.length}');
    print('  - QA count: ${formData.qaList.length}');
    print('  - Buyer info items count: ${formData.buyerInfoItems.length}');
    
    // 转换买家需求信息为材料信息（ATTACHMENT或TEXT类型）
    final buyerMaterials = formData.buyerInfoItems.asMap().entries.map((entry) {
      final item = entry.value;
      final type = item['type'] ?? '';
      // 根据类型映射到productMaterials的type
      String materialType = 'TEXT'; // 默认为TEXT
      if (type == 'file' || type == 'image') {
        materialType = 'ATTACHMENT';
      }
      return ProductMaterial(
        id: 1000 + entry.key, // 使用1000+索引作为ID，避免与QA冲突
        question: item['label'] ?? '',
        answer: item['description'] ?? '',
        type: materialType,
      );
    }).toList();
    
    // 转换服务档位为商品变体
    final variants = formData.variants.map((tier) {
      print('  - Converting tier: ${tier.name} - Price: ${tier.sellingPrice}');
      return ProductVariant(
        id: tier.id,
        name: tier.name,
        sellingPrice: tier.sellingPrice,
        editNum: tier.editNum,
        deliveryDay: tier.deliveryDay,
        features: tier.feature.map<Map<String, dynamic>>((f) => {
          'key': f['key'] ?? '',
          'value': f['val'] ?? f['value'] ?? '',
        }).toList(),
      );
    }).toList();
    
    print('  - Converted variants count: ${variants.length}');
    if (variants.isNotEmpty) {
      print('  - First variant price: ${variants.first.sellingPrice}');
    }

    // 转换QA为材料信息（PROBLEM类型）
    final qaMaterials = formData.qaList.asMap().entries.map((entry) => ProductMaterial(
      id: entry.key,
      question: entry.value['question'] ?? '',
      answer: entry.value['answer'] ?? '',
      type: 'PROBLEM', // 常见问题使用PROBLEM类型
    )).toList();
    
    // 合并所有材料信息
    final materials = [...qaMaterials, ...buyerMaterials];
    
    print('  - Converted materials count: ${materials.length}');

    final convertedProduct = ProductDetail(
      id: formData.productId ?? 0,
      name: formData.name,
      description: formData.description,
      sellingPrice: variants.isNotEmpty ? variants.first.sellingPrice : formData.price,
      mainImage: formData.images.isNotEmpty ? formData.images.first : '',
      images: formData.images.isEmpty ? <String>[] : formData.images,
      detailImages: null,
      detailContent: null,
      winImages: null,
      categoryId: formData.categoryId ?? 0,
      categoryName: '',
      sellerId: 0, // 预览模式下使用默认值
      sellerName: _currentUserName,
      sellerAvatar: null,
      sellerRemarks: null,
      recoverFlag: false,
      recoverContent: null,
      variants: variants,
      materials: materials,
      sales: 0,
      views: 0,
      status: 'preview',
      selectionMode: 'single',
      createTime: DateTime.now(),
      updateTime: DateTime.now(),
      evaluateNum: 0,
      score: '5.0',
    );
    
    print('[PreviewPage] Form data conversion completed:');
    print('  - Final product name: "${convertedProduct.name}"');
    print('  - Final product price: ${convertedProduct.sellingPrice}');
    print('  - Final variants count: ${convertedProduct.variants?.length ?? 0}');
    print('  - Final images count: ${convertedProduct.images.length}');
    
    return convertedProduct;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.seller_product_preview_title ?? 'Product Preview'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 返回编辑按钮
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.edit),
            label: Text(AppLocalizations.of(context)?.seller_product_preview_back_to_edit ?? 'Back to Edit'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFBF7D2A),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: widget.formData != null && _productDetail != null
          ? _buildContent(_productDetail!)
          : BlocBuilder<ProductEditBloc, ProductEditState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state.isLoading) {
                  return LoadingState(text: AppLocalizations.of(context)?.seller_product_preview_loading ?? 'Loading product info...');
                }
                
                if (state.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? (AppLocalizations.of(context)?.seller_product_preview_load_failed ?? 'Failed to load product info'),
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final productIdInt = int.tryParse(widget.productId!) ?? 0;
                            if (productIdInt > 0) {
                              _bloc.add(InitializeProductEdit(productId: productIdInt));
                            }
                          },
                          child: Text(AppLocalizations.of(context)?.seller_product_preview_retry ?? 'Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                // 如果没有错误但产品为空，显示加载中
                if (state.product == null) {
                  return LoadingState(text: AppLocalizations.of(context)?.seller_product_preview_fetching ?? 'Fetching product data...');
                }
                
                // 从状态中的产品数据构建ProductDetail
                final productDetail = _convertManagedProductToDetail(state.product!);
                return _buildContent(productDetail);
              },
            ),
    );
  }

  /// 将ManagedProduct转换为ProductDetail
  ProductDetail _convertManagedProductToDetail(dynamic product) {
    print('[PreviewPage] Converting SellerManagedProduct to ProductDetail:');
    print('  - Product ID: ${product.id}');
    print('  - Product Name: "${product.name}"');
    print('  - Product Description: "${product.description}"');
    print('  - Product Price: ${product.price}');
    print('  - Product Images: "${product.images}"');
    print('  - Product Images Type: ${product.images.runtimeType}');
    print('  - Product Status: ${product.status}');
    print('  - Product Category: ${product.category}');
    
    // 详细检查变体数据
    print('  - Product Variants Raw: ${product.variants}');
    print('  - Product Variants Type: ${product.variants.runtimeType}');
    print('  - Product Variants Length: ${product.variants?.length ?? 'null'}');
    
    if (product.variants != null && product.variants.isNotEmpty) {
      print('  - First Variant: ${product.variants[0]}');
      print('  - First Variant Type: ${product.variants[0].runtimeType}');
      print('  - First Variant Fields: name=${product.variants[0].name}, price=${product.variants[0].price}, sellingPrice=${product.variants[0].sellingPrice}');
    }
    
    print('  - Product Materials Raw: ${product.productMaterials}');
    print('  - Product Materials Length: ${product.productMaterials?.length ?? 'null'}');
    
    // 转换商品变体
    final variants = (product.variants as List<dynamic>?)?.map<ProductVariant>((variant) {
      print('  - Converting variant: ${variant.name} - Price: ${variant.sellingPrice} - DeliveryDay: ${variant.deliveryDay}');
      return ProductVariant(
        id: variant.id,
        name: variant.name.isNotEmpty ? variant.name : variant.optionValue,
        sellingPrice: variant.sellingPrice > 0 ? variant.sellingPrice : variant.price,
        editNum: variant.editNum,
        deliveryDay: variant.deliveryDay,
        features: variant.feature.map<Map<String, dynamic>>((f) => {
          'key': f['key'] ?? '',
          'value': f['val'] ?? f['value'] ?? '',
        }).toList(),
      );
    }).toList() ?? [];
    
    print('  - Converted variants count: ${variants.length}');
    
    // 转换商品材料
    final materials = (product.productMaterials as List<dynamic>?)?.map<ProductMaterial>((material) {
      return ProductMaterial(
        id: material.id,
        question: material.question,
        answer: material.answer,
        type: material.type,
      );
    }).toList() ?? [];
    
    print('  - Converted materials count: ${materials.length}');
    
    // 处理图片 - images字段是逗号分隔的字符串（已经在DTO中处理过）
    List<String> imageList = <String>[];
    if (product.images != null && product.images.isNotEmpty) {
      // 明确类型，避免类型推断问题
      final splitImages = product.images.split(',');
      for (final url in splitImages) {
        final trimmedUrl = url.trim();
        if (trimmedUrl.isNotEmpty) {
          imageList.add(trimmedUrl);
        }
      }
    }
    
    final convertedProduct = ProductDetail(
      id: product.id ?? 0,
      name: product.name ?? '',
      description: product.description ?? '',
      sellingPrice: variants.isNotEmpty ? variants.first.sellingPrice : (product.price ?? 0.0),
      mainImage: imageList.isNotEmpty ? imageList.first : '',
      images: imageList.isEmpty ? <String>[] : imageList,
      detailImages: null,
      detailContent: null,
      winImages: null,
      categoryId: product.category?.id ?? 0,
      categoryName: product.category?.name ?? '',
      sellerId: 0, // SellerManagedProduct 没有sellerId字段
      sellerName: _currentUserName,
      sellerAvatar: null,
      sellerRemarks: null,
      recoverFlag: false,
      recoverContent: null,
      variants: variants,
      materials: materials,
      sales: product.sales ?? 0,
      views: 0, // SellerManagedProduct 没有views字段
      status: 'preview',
      selectionMode: 'single',
      createTime: product.createTime ?? DateTime.now(),
      updateTime: product.updateTime ?? DateTime.now(),
      evaluateNum: 0, // SellerManagedProduct 没有evaluateNum字段
      score: '5.0', // SellerManagedProduct 没有score字段
    );
    
    print('[PreviewPage] Conversion completed:');
    print('  - Final product name: "${convertedProduct.name}"');
    print('  - Final product price: ${convertedProduct.sellingPrice}');
    print('  - Final variants count: ${convertedProduct.variants?.length ?? 0}');
    print('  - Final images count: ${convertedProduct.images.length}');
    
    return convertedProduct;
  }

  Widget _buildContent(ProductDetail productDetail) {
    return ProductDetailContent(
      product: productDetail,
      isPreviewMode: false, // 设置为false，显示与买家一致的界面
      // 不传递任何自定义内容，让预览页面与买家看到的完全一致
    );
  }

  Widget _buildPreviewActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)?.seller_product_preview_hint ?? 'This is preview mode. Buyers will see a similar interface.',
              style: TextStyle(
                color: Colors.amber[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}