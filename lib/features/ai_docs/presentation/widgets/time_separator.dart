import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/smart_time_formatter.dart';

class TimeSeparator extends StatelessWidget {
  final DateTime timestamp;
  
  const TimeSeparator({
    Key? key,
    required this.timestamp,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey[300],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              SmartTimeFormatter.formatToRelativeTime(timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
} 