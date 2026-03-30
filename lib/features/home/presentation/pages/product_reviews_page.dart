import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

// 导入国际化
import '../../../../generated/app_localizations.dart';

import '../../domain/entities/product_review.dart';
import '../cubit/product_reviews_cubit.dart';
import '../cubit/product_reviews_state.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 商品评论详情页面
class ProductReviewsPage extends StatelessWidget {
  final int productId;

  const ProductReviewsPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ProductReviewsCubit>()..getProductReviews(productId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('评论'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<ProductReviewsCubit, ProductReviewsState>(
          builder: (context, state) {
            if (state is ProductReviewsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductReviewsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载失败: ${state.message}'),
                    const SizedBox(height: AppDimensions.spacingLg),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductReviewsCubit>().getProductReviews(productId);
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            } else if (state is ProductReviewsLoaded) {
              return _buildReviewsList(context, state);
            }
            return const Center(child: Text('暂无评论'));
          },
        ),
      ),
    );
  }

  Widget _buildReviewsList(BuildContext context, ProductReviewsLoaded state) {
    if (state.reviews.isEmpty) {
      return const Center(child: Text('暂无评论'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      itemCount: state.reviews.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        return _buildReviewItem(context, state.reviews[index]);
      },
    );
  }

  Widget _buildReviewItem(BuildContext context, ProductReview review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户信息和时间
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 用户头像
            CircleAvatar(
              radius: 20,
              backgroundImage: review.buyer.avatar != null
                  ? NetworkImage(review.buyer.avatar!)
                  : null,
              child: review.buyer.avatar == null
                  ? Text(review.buyer.nickName.isNotEmpty
                      ? review.buyer.nickName[0].toUpperCase()
                      : '?')
                  : null,
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户名
                  Text(
                    review.buyer.nickName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // 评分 + 套餐名
                  Row(
                    children: [
                      _buildRatingStars(review.score),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Text(
                        review.skuName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 评论时间
            Text(
              _formatDateTime(context, review.createTime),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        // 显示评论内容
        Text(
          review.content ?? '用户未填写评价内容',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: review.content == null ? AppColors.textTertiary : null,
          ),
        ),

        // 评论图片
        if (review.images != null && review.images!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.spacingSm),
            child: _buildReviewImages(review.images!),
          ),

        // 卖家回复
        if (review.sellerReply != null && review.sellerReply!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.spacingMd),
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Text(
                        '卖家回复',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (review.sellerReplyTime != null) ...[
                      const SizedBox(width: AppDimensions.spacingSm),
                      Text(
                        _formatDateTime(context, review.sellerReplyTime!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  review.sellerReply!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRatingStars(int score) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < score ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildReviewImages(List<String> images) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spacingSm),
            child: GestureDetector(
              onTap: () {
                // 点击查看大图
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.borderPrimary,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.borderPrimary,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(BuildContext context, String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}年前';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}月前';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }
}
