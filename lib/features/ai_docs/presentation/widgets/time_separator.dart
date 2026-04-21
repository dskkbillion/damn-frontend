import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/utils/smart_time_formatter.dart';

class TimeSeparator extends StatelessWidget {
  final DateTime timestamp;

  const TimeSeparator({
    super.key,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.borderInput,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
            child: Text(
              SmartTimeFormatter.formatToRelativeTime(timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.borderInput,
            ),
          ),
        ],
      ),
    );
  }
}
