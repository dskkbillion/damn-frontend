import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

// 导入国际化
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

import 'package:dskk_flutter_refactor/core/widgets/translatable_text.dart';

import '../../domain/entities/product_review.dart';
import '../cubit/product_reviews_cubit.dart';
import '../cubit/product_reviews_state.dart';

/// 商品评论详情页面
class ProductReviewsPage extends StatelessWidget {
  final int productId;
  
  const ProductReviewsPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ProductReviewsCubit>()..getProductReviews(productId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).home_reviews_title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
                    Text(AppLocalizations.of(context).home_reviews_load_failed(state.message)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductReviewsCubit>().getProductReviews(productId);
                      },
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              );
            } else if (state is ProductReviewsLoaded) {
              return _buildReviewsList(context, state);
            }
            return Center(child: Text(AppLocalizations.of(context).home_reviews_no_reviews));
          },
        ),
      ),
    );
  }

  Widget _buildReviewsList(BuildContext context, ProductReviewsLoaded state) {
    if (state.reviews.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context).home_reviews_no_reviews));
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户名
                  Text(
                    review.buyer.nickName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // 评分 + 套餐名
                  Row(
                    children: [
                      _buildRatingStars(review.score),
                      const SizedBox(width: 8),
                      Text(
                        review.skuName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 显示评论内容（#301 支持翻译 toggle）
        TranslatableText(
          originalText: review.content ?? AppLocalizations.of(context).home_reviews_default_content,
          translatedText: review.contentTranslated,
          sourceLang: review.translationSourceLang,
          provider: review.translationProvider,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        
        // 评论图片
        if (review.images != null && review.images!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildReviewImages(review.images!),
          ),
        
        // 卖家回复
        if (review.sellerReply != null && review.sellerReply!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppLocalizations.of(context).home_reviews_seller_reply,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (review.sellerReplyTime != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _formatDateTime(context, review.sellerReplyTime!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review.sellerReply!,
                  style: const TextStyle(
                    fontSize: 14,
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
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                // 点击查看大图
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
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
      final s = AppLocalizations.of(context);
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        return s.home_reviews_years_ago((difference.inDays / 365).floor());
      } else if (difference.inDays > 30) {
        return s.home_reviews_months_ago((difference.inDays / 30).floor());
      } else if (difference.inDays > 0) {
        return s.home_reviews_days_ago(difference.inDays);
      } else if (difference.inHours > 0) {
        return s.home_reviews_hours_ago(difference.inHours);
      } else if (difference.inMinutes > 0) {
        return s.home_reviews_minutes_ago(difference.inMinutes);
      } else {
        return s.home_reviews_just_now;
      }
    } catch (e) {
      return dateTimeStr;
    }
  }
} 