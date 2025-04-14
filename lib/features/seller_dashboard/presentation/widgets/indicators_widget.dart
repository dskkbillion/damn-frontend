import 'package:flutter/material.dart';

class IndicatorsWidget extends StatelessWidget {
  final int totalEarnings;
  final int thisMonthTotalEarnings;
  final int overallTotalOrderCount;
  final int activeOrderNum;

  const IndicatorsWidget({
    super.key,
    required this.totalEarnings,
    required this.thisMonthTotalEarnings,
    required this.overallTotalOrderCount,
    required this.activeOrderNum,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Define the text style for the indicator values (e.g., gold/brown color)
    final valueTextStyle = textTheme.headlineSmall?.copyWith(
      color: Colors.brown, // Example color - adjust to match design
      fontWeight: FontWeight.bold,
    );
    final labelTextStyle = textTheme.bodyMedium;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // Adjust padding
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildIndicatorItem(
                    label: '总盈利',
                    value: totalEarnings.toString(),
                    valueStyle: valueTextStyle,
                    labelStyle: labelTextStyle,
                  ),
                ),
                Expanded(
                  child: _buildIndicatorItem(
                    label: '本月盈利',
                    value: thisMonthTotalEarnings.toString(),
                    valueStyle: valueTextStyle,
                    labelStyle: labelTextStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Space between rows
            Row(
              children: [
                Expanded(
                  child: _buildIndicatorItem(
                    label: '总订单数',
                    value: overallTotalOrderCount.toString(),
                    valueStyle: valueTextStyle,
                    labelStyle: labelTextStyle,
                  ),
                ),
                Expanded(
                  child: _buildIndicatorItem(
                    label: '活跃订单数',
                    value: activeOrderNum.toString(),
                    valueStyle: valueTextStyle,
                    labelStyle: labelTextStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for each label-value pair
  Widget _buildIndicatorItem({
    required String label,
    required String value,
    TextStyle? valueStyle,
    TextStyle? labelStyle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      // Center align the items in the column
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: valueStyle),
        const SizedBox(height: 4), // Small space between value and label
        Text(label, style: labelStyle),
      ],
    );
  }
} 