import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 评论统计摘要卡片
class ReviewSummaryCard extends StatelessWidget {
  final double averageScore;
  final int totalReviews;
  final Map<int, int> scoreDistribution;

  const ReviewSummaryCard({
    Key? key,
    required this.averageScore,
    required this.totalReviews,
    required this.scoreDistribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderSecondary,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧：平均分数
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      averageScore.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    _buildRatingStars(averageScore),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      AppLocalizations.of(context)!.product_reviews_total_count(totalReviews),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingXxl),
              // 右侧：评分分布
              Expanded(
                flex: 3,
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final count = scoreDistribution[star] ?? 0;
                    final percentage = totalReviews > 0
                        ? (count / totalReviews * 100).round()
                        : 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$star',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.borderPrimary,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: percentage / 100,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          SizedBox(
                            width: 35,
                            child: Text(
                              '$percentage%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double score) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < score.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index == score.floor() && score - score.floor() >= 0.5) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }
}
