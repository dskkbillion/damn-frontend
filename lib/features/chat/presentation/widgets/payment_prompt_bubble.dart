import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// Payment prompt bubble widget for light consultation mode
/// Shows system-style payment reminder after 5 rounds of free consultation
class PaymentPromptBubble extends StatelessWidget {
  final bool isSeller;
  final String? productId;
  final int? sellerId;
  final int? chatRoomId;
  final List<Map<String, dynamic>>? variants;
  final String content;

  const PaymentPromptBubble({
    super.key,
    required this.isSeller,
    this.productId,
    this.sellerId,
    this.chatRoomId,
    this.variants,
    required this.content,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // System prompt header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4),
                Text(
                  '系统提示',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Main content container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: AppColors.borderPrimary,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Content text
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // Show price buttons for buyer, info text for seller
                if (!isSeller && variants != null && variants!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildPriceButtons(context),
                ] else if (isSeller) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '已发送付费提示',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceButtons(BuildContext context) {
    if (variants == null || variants!.isEmpty) return const SizedBox();
    
    // Sort variants by price
    final sortedVariants = List<Map<String, dynamic>>.from(variants!)
      ..sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
    
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: sortedVariants.asMap().entries.map((entry) {
        final index = entry.key;
        final variant = entry.value;
        final isRecommended = index == 1 && sortedVariants.length >= 3; // Middle option
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ElevatedButton(
              onPressed: () {
                if (productId != null && sellerId != null) {
                  // 直接跳转到订单确认页（购买页面）
                  context.pushNamed(
                    'productPaymentConfirm',
                    pathParameters: {'id': productId!},
                    extra: {
                      'variantId': variant['id'],
                      'quantity': 1,
                      'price': variant['price'],
                      'sellerId': sellerId,
                      'chatRoomId': chatRoomId,
                      'productName': variant['name'] ?? '咨询服务',
                    },
                  );
                } else {
                  // sellerId 缺失时显示错误提示
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('无法下单：商品信息不完整，请稍后重试')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended
                  ? AppColors.warning
                  : AppColors.warning.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                elevation: isRecommended ? 3 : 1,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    RegionConfig.formatPrice(variant['price'].toDouble()),
                    style: TextStyle(
                      fontSize: isRecommended ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (variant['name'] != null)
                    Text(
                      variant['name'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
            if (isRecommended)
              Positioned(
                top: -8,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Text(
                    '推荐',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
