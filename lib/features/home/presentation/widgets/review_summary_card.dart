import 'package:flutter/material.dart';
import '../../../../generated/app_localizations.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.product_reviews_total_count(totalReviews),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: percentage / 100,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 35,
                            child: Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
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