import 'package:flutter/material.dart';
import 'dart:math' as math; // For PI

class PerformanceMetricsWidget extends StatelessWidget {
  final int heatPercent;
  final int recoverPercent;
  final int completePercent;
  final int goodPercent;

  const PerformanceMetricsWidget({
    super.key,
    required this.heatPercent,
    required this.recoverPercent,
    required this.completePercent,
    required this.goodPercent,
  });

  @override
  Widget build(BuildContext context) {
    // Use a Row to layout the four indicators horizontally
    const progressColorBrown = Color(0xFFB66D0E); // Define the color

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute space evenly
      children: [
        _CircleIndicator(
          label: '热度值',
          percent: heatPercent,
          backgroundColor: Colors.brown[50],
          progressColor: progressColorBrown, // Use defined color
        ),
        _CircleIndicator(
          label: '回复率',
          percent: recoverPercent,
          backgroundColor: Colors.brown[50],
          progressColor: progressColorBrown, // Use defined color
        ),
        _CircleIndicator(
          label: '完成率',
          percent: completePercent,
          backgroundColor: Colors.grey[200],
          progressColor: Colors.grey[600],
        ),
        _CircleIndicator(
          label: '好评率',
          percent: goodPercent,
          backgroundColor: Colors.grey[200],
          progressColor: Colors.grey[600],
        ),
      ],
    );
  }
}

// Helper widget for the individual circle indicator
class _CircleIndicator extends StatelessWidget {
  final String label;
  final int percent;
  final Color? backgroundColor;
  final Color? progressColor;

  const _CircleIndicator({
    required this.label,
    required this.percent,
    this.backgroundColor,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Clamp percentage between 0 and 100
    final double progress = (percent.clamp(0, 100) / 100.0);

    return Column(
      mainAxisSize: MainAxisSize.min, // Take minimum vertical space
      children: [
        // Stack the progress indicator and the percentage text
        SizedBox(
          width: 60, // Adjust size as needed
          height: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 5, // Adjust thickness
                backgroundColor: backgroundColor ?? Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? Theme.of(context).primaryColor,
                ),
              ),
              Center(
                child: Text(
                  '$percent%',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8), // Space between circle and label
        Text(
          label,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
} 