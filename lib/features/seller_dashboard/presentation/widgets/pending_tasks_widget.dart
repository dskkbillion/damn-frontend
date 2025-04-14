import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For potential date formatting

class PendingTasksWidget extends StatelessWidget {
  final int pendingOrderNum;
  final int receiptOrderNum;
  final int earlyTime; // Treat as Unix timestamp (seconds)
  final int latenessTime; // Treat as Unix timestamp (seconds)

  const PendingTasksWidget({
    super.key,
    required this.pendingOrderNum,
    required this.receiptOrderNum,
    required this.earlyTime,
    required this.latenessTime,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Define the text style for the values (e.g., gold/brown color)
    final valueTextStyle = textTheme.bodyLarge?.copyWith(
      color: Colors.brown, // Example color - adjust to match design
      fontWeight: FontWeight.bold,
    );
    final labelTextStyle = textTheme.bodyLarge;

    // --- Format the time/date values --- 
    // TODO: Clarify the exact meaning and desired format for earlyTime/latenessTime.
    // Assuming they are timestamps and we want to show relative time or date.
    // For now, just display the raw numbers as in the screenshot.
    final String timeDisplay = '$earlyTime (最早) / $latenessTime (最晚)'; // Placeholder formatting
    // Example date formatting (if needed later):
    // final dateFormat = DateFormat('MM/dd'); // Example format
    // final earlyDate = DateTime.fromMillisecondsSinceEpoch(earlyTime * 1000);
    // final lateDate = DateTime.fromMillisecondsSinceEpoch(latenessTime * 1000);
    // final String timeDisplay = '${dateFormat.format(earlyDate)} / ${dateFormat.format(lateDate)}';

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('未完成订单数', style: labelTextStyle),
                Text(
                  '$pendingOrderNum (待完成) / $receiptOrderNum (回单)', // Combined display
                  style: valueTextStyle,
                ),
              ],
            ),
            const SizedBox(height: 12), // Space between rows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('距离下次递交日', style: labelTextStyle),
                Text(
                  timeDisplay, // Display formatted time/date
                  style: valueTextStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 