import 'package:flutter/material.dart';

class UpgradeProgressWidget extends StatelessWidget {
  // Target values
  final int targetDays;
  final int targetOrderNum;
  final int targetOrderPrice;
  // Progress values
  final int progressDays;
  final int progressOrderCount;
  final int progressOrderPrice;

  const UpgradeProgressWidget({
    super.key,
    required this.targetDays,
    required this.targetOrderNum,
    required this.targetOrderPrice,
    required this.progressDays,
    required this.progressOrderCount,
    required this.progressOrderPrice,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Define the text style for the progress numbers (e.g., gold/brown color)
    final progressTextStyle = textTheme.bodyLarge?.copyWith(
      color: Colors.brown, // Example color - adjust to match design
      fontWeight: FontWeight.bold,
    );

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressRow(
              // Left side text needs clarification or hardcoding based on design
              // Example: "成为三级会员卖家 ${targetDays} 天"
              label: '成为三级会员卖家 ${targetDays} 天', // Example Label
              progress: progressDays,
              target: targetDays,
              textStyle: textTheme.bodyLarge,
              progressTextStyle: progressTextStyle,
            ),
            const SizedBox(height: 12), // Spacing between rows
            _buildProgressRow(
              label: '完成订单 ${targetOrderNum} 笔', // Example Label
              progress: progressOrderCount,
              target: targetOrderNum,
              textStyle: textTheme.bodyLarge,
              progressTextStyle: progressTextStyle,
            ),
             const SizedBox(height: 12),
            _buildProgressRow(
              label: '盈利 ${targetOrderPrice.toStringAsFixed(2)} 元', // Example Label with formatting
              progress: progressOrderPrice,
              target: targetOrderPrice,
              textStyle: textTheme.bodyLarge,
              progressTextStyle: progressTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for each progress row
  Widget _buildProgressRow({
    required String label,
    required int progress,
    required int target,
    TextStyle? textStyle,
    TextStyle? progressTextStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(
          // Format progress/target
          // Handle potential division by zero if target is 0
          '$progress/${target == 0 ? '-' : target}',
          style: progressTextStyle,
        ),
      ],
    );
  }
} 