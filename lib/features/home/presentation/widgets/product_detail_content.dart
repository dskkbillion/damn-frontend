import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/currency/presentation/widgets/price_display_widget.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/product_detail.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/widgets/product_images_carousel.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 商品详情内容组件 - 可在详情页和预览页复用
class ProductDetailContent extends StatefulWidget {
  final ProductDetail product;
  final bool isPreviewMode;
  final Function(int sellerId)? onContactSeller;
  final VoidCallback? onBuyNow;
  final Widget? customActions;

  const ProductDetailContent({
    super.key,
    required this.product,
    this.isPreviewMode = false,
    this.onContactSeller,
    this.onBuyNow,
    this.customActions,
  });

  @override
  State<ProductDetailContent> createState() => _ProductDetailContentState();
}

class _ProductDetailContentState extends State<ProductDetailContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedVariantIndex = 0;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.product.variants?.length ?? 1,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedVariantIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.d('[ProductDetailContent] Building with product:');
    AppLogger.d('  - Product ID: ${widget.product.id}');
    AppLogger.d('  - Product Name: "${widget.product.name}"');
    AppLogger.d('  - Product Variants: ${widget.product.variants?.length ?? 'null'}');
    AppLogger.d('  - Product Materials: ${widget.product.materials?.length ?? 'null'}');
    AppLogger.d('  - Is Preview Mode: ${widget.isPreviewMode}');

    if (widget.product.variants != null && widget.product.variants!.isNotEmpty) {
      AppLogger.d('  - First Variant: ${widget.product.variants![0].name} - Price: ${widget.product.variants![0].sellingPrice}');
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片轮播
          _buildImageCarousel(),

          // 卖家信息
          _buildSellerInfo(),

          // 商品基本信息
          _buildProductBasicInfo(),

          // 价格信息显示
          _buildPriceSection(),

          // 套餐选择（Tab样式）
          if (widget.product.variants != null && widget.product.variants!.isNotEmpty)
            _buildVariantTabs(),

          // 选中套餐的交付信息
          if (widget.product.variants != null && widget.product.variants!.isNotEmpty)
            _buildDeliveryInfo(widget.product.variants![_selectedVariantIndex]),

          // 购买按钮（预览模式下可选择性隐藏）
          if (!widget.isPreviewMode || widget.onBuyNow != null)
            _buildBuyButton(),

          // 自定义操作区域
          if (widget.customActions != null) widget.customActions!,

          // 买家需要提供（折叠面板）
          _buildBuyerRequirementsSection(),

          // 常见问题（折叠面板）
          _buildFAQSection(),

          // 案例展示
          _buildCaseShowcase(),

          // 评价区域（预览模式下可选择性显示）
          if (!widget.isPreviewMode)
            _buildReviewsSection(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return ProductImagesCarousel(
      images: widget.product.images,
      height: 300.0,
      onImageClicked: (index) {
        // 图片点击逻辑
      },
    );
  }

  Widget _buildSellerInfo() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Row(
        children: [
          // 头像
          GestureDetector(
            onTap: widget.isPreviewMode ? null : () {
              context.push('/seller-profile/${widget.product.sellerId}');
            },
            child: Semantics(
              label: 'seller-avatar',
              child: CircleAvatar(
                radius: 20,
                backgroundImage: widget.product.sellerAvatar != null
                    ? NetworkImage(widget.product.sellerAvatar!)
                    : null,
                child: widget.product.sellerAvatar == null
                    ? Text(widget.product.sellerName.isNotEmpty
                        ? widget.product.sellerName[0].toUpperCase()
                        : '?')
                    : null,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          // 卖家信息
          Expanded(
            child: GestureDetector(
              onTap: widget.isPreviewMode ? null : () {
                context.push('/seller-profile/${widget.product.sellerId}');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppDimensions.spacingSm,
                    children: [
                      Text(
                        widget.product.sellerName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 验证标签
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              AppLocalizations.of(context).product_detail_verified_label,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        ' ${widget.product.score}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 咨询卖家按钮（预览模式下隐藏）
          if (!widget.isPreviewMode && widget.onContactSeller != null)
            GestureDetector(
              onTap: () => widget.onContactSeller!(widget.product.sellerId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.borderPrimary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 16),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(AppLocalizations.of(context).product_detail_contact_seller),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductBasicInfo() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingXs),
            margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.borderPrimary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(
              widget.isPreviewMode
                  ? '预览模式'
                  : AppLocalizations.of(context).product_detail_published_status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),

          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingSm),

          // 描述区域
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 使用LayoutBuilder来判断文字是否被截断
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textSpan = TextSpan(
                      text: widget.product.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                    final textPainter = TextPainter(
                      text: textSpan,
                      maxLines: 2,
                      textDirection: TextDirection.ltr,
                    )..layout(maxWidth: constraints.maxWidth);

                    final isTextOverflow = textPainter.didExceedMaxLines;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: _isDescriptionExpanded ? null : 2,
                          overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                        // 只有当文字被截断或者已展开时才显示更多/收起按钮
                        if (isTextOverflow || _isDescriptionExpanded)
                          Padding(
                            padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _isDescriptionExpanded
                                    ? AppLocalizations.of(context).product_detail_collapse
                                    : AppLocalizations.of(context).product_detail_more,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textLink,
                                  ),
                                ),
                                Icon(
                                  _isDescriptionExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                  color: AppColors.textLink,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTierDisplayName(String tierName, BuildContext context) {
    switch (tierName) {
      case 'Basic Tier':
        return AppLocalizations.of(context).product_detail_basic_tier;
      case 'Standard Tier':
        return AppLocalizations.of(context).product_detail_standard_tier;
      case 'Premium Tier':
        return AppLocalizations.of(context).product_detail_premium_tier;
      default:
        return tierName;
    }
  }

  String _getTierPriceDisplay(BuildContext context, ProductVariant variant) {
    final tierName = _getTierDisplayName(variant.name, context);
    final price = PriceFormatter.format(variant.sellingPrice);
    return '$tierName $price';
  }

  Widget _buildPriceSection() {
    // 如果有多个variants，显示选择信息；如果没有variants，显示基础价格
    if (widget.product.variants == null || widget.product.variants!.isEmpty) {
      // 没有variants时，显示基础价格
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingSm),
        child: Row(
          children: [
            Text(
              '价格：',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            PriceDisplayWidget(
              price: widget.product.sellingPrice,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    } else {
      // 有variants时，显示提示文本
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingSm),
        child: Text(
          '请选择服务套餐：',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }

  Widget _buildVariantTabs() {
    AppLogger.d('[ProductDetailContent] Building variant tabs:');
    AppLogger.d('  - Variants count: ${widget.product.variants?.length ?? 'null'}');

    if (widget.product.variants != null) {
      for (int i = 0; i < widget.product.variants!.length; i++) {
        final variant = widget.product.variants![i];
        AppLogger.d('  - Variant $i: ${variant.name} - ${PriceFormatter.format(variant.sellingPrice)}');
      }
    }

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderPrimary, width: 0.5),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: widget.product.variants!.map((variant) => Tab(
              text: _getTierPriceDisplay(context, variant),
            )).toList(),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(ProductVariant variant) {
    // 只有当交付信息有值且大于1时才显示
    final bool hasDeliveryInfo = (variant.editNum != null && variant.editNum! > 1) ||
                                  (variant.deliveryDay != null && variant.deliveryDay! > 1);

    if (!hasDeliveryInfo) {
      return const SizedBox.shrink(); // 返回空widget，不显示任何内容
    }

    final List<Widget> deliveryRows = [];

    // 只显示有意义的交付次数
    if (variant.editNum != null && variant.editNum! > 1) {
      deliveryRows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).product_detail_delivery_times,
                style: Theme.of(context).textTheme.bodyLarge),
            Text('${variant.editNum}',
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    // 只显示有意义的交付周期
    if (variant.deliveryDay != null && variant.deliveryDay! > 1) {
      if (deliveryRows.isNotEmpty) {
        deliveryRows.add(const SizedBox(height: AppDimensions.spacingMd));
      }
      deliveryRows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).product_detail_delivery_period,
                style: Theme.of(context).textTheme.bodyLarge),
            Text('${variant.deliveryDay}',
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        children: deliveryRows,
      ),
    );
  }

  Widget _buildBuyButton() {
    final variant = widget.product.variants != null && widget.product.variants!.isNotEmpty
        ? widget.product.variants![_selectedVariantIndex]
        : null;

    // 如果没有variants但有价格，也显示购买按钮
    final displayPrice = variant?.sellingPrice ?? widget.product.sellingPrice;

    if (variant == null && widget.product.sellingPrice <= 0) {
      AppLogger.d('[ProductDetailContent] No buy button: variant is null and sellingPrice <= 0');
      AppLogger.d('  - Variants: ${widget.product.variants?.length ?? 0}');
      AppLogger.d('  - SellingPrice: ${widget.product.sellingPrice}');
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingXxl),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.isPreviewMode
            ? (widget.onBuyNow ?? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('预览模式下无法购买')),
                );
              })
            : () {
                context.push(
                  '/product-payment/${widget.product.id}/confirm',
                  extra: {
                    'productId': widget.product.id,
                    'variantId': variant?.id ?? 0,
                    'quantity': 1,
                    'sellerId': widget.product.sellerId,
                    'productName': widget.product.name,
                    'price': displayPrice,
                    'imageUrl': widget.product.images.isNotEmpty
                        ? widget.product.images.first
                        : null,
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
        ),
        child: Text(
          '一键购买 (${PriceFormatter.format(displayPrice)})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBuyerRequirementsSection() {
    // 过滤出ATTACHMENT和TEXT类型的材料作为需要买家提供的内容
    final requirementMaterials = widget.product.materials
        ?.where((m) => m.type == 'ATTACHMENT' || m.type == 'TEXT')
        .toList() ?? [];

    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.spacingSm),
      color: AppColors.backgroundCard,
      child: ExpansionTile(
        title: Text(
          '买家需要提供',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down),
        children: requirementMaterials.isEmpty
            ? [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      '卖家暂未设置需要买家提供的信息',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ]
            : requirementMaterials.map((material) => Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingMd),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getIconForMaterialType(material.type),
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    if (material.answer != null && material.answer!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
                        child: Text(
                          material.answer!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  IconData _getIconForMaterialType(String type) {
    switch (type) {
      case 'ATTACHMENT':
        return Icons.attach_file;
      case 'TEXT':
        return Icons.text_fields;
      case 'PROBLEM':
        return Icons.help_outline;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildFAQSection() {
    // 过滤出PROBLEM类型的材料作为常见问题
    final faqMaterials = widget.product.materials
        ?.where((m) => m.type == 'PROBLEM')
        .toList() ?? [];

    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.spacingSm),
      color: AppColors.backgroundCard,
      child: ExpansionTile(
        initiallyExpanded: true, // 默认展开
        title: Text(
          AppLocalizations.of(context).product_detail_faq,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down),
        children: faqMaterials.isEmpty
            ? [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      '暂无常见问题',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ]
            : faqMaterials.map((material) => Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingMd),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      material.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              if (material.answer != null && material.answer!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.spacingSm, left: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          material.answer!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCaseShowcase() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).product_detail_case_showcase,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.borderPrimary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context).product_detail_no_cases,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).product_detail_reviews(widget.product.evaluateNum),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final productId = int.tryParse(widget.product.id.toString()) ?? 0;
                  if (productId > 0) {
                    context.push('/product/$productId/reviews');
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context).product_detail_view_all,
                        style: const TextStyle(color: AppColors.textTertiary)),
                    const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // 评价内容
          if (widget.product.evaluateNum <= 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
                child: Text(
                  AppLocalizations.of(context).product_detail_no_reviews,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            // 示例评价
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.amber[100],
                  child: const Icon(Icons.person, color: Colors.amber),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context).product_detail_sample_user,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          Text(
                            '2025-03-12 11:20:05',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context).product_detail_basic_package,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              )),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(AppLocalizations.of(context).product_detail_sample_review),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
