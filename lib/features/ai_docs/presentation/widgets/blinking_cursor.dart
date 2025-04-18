import 'package:flutter/material.dart';

/// {@template blinking_cursor}
/// A simple widget that displays a blinking vertical bar,
/// often used to indicate text input or streaming text.
/// {@endtemplate}
class BlinkingCursor extends StatefulWidget {
  /// The color of the cursor.
  final Color? cursorColor;

  /// {@macro blinking_cursor}
  const BlinkingCursor({super.key, this.cursorColor});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // Use a slightly faster duration for better effect
      duration: const Duration(milliseconds: 500), 
      vsync: this,
    )..repeat(reverse: true); // Make it blink continuously
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine cursor color, defaulting to current text theme color if not provided
    final color = widget.cursorColor ?? DefaultTextStyle.of(context).style.color ?? Colors.black87;

    return FadeTransition(
      opacity: _controller,
      child: Text(
         '|', 
         style: TextStyle(
           fontSize: 15.0, // Match bubble text size
           color: color, 
           fontWeight: FontWeight.bold
           )
      ),
    );
  }
} 
 