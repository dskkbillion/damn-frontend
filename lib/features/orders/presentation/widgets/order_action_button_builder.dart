import 'package:flutter/material.dart';

/// 订单操作按钮构建器
class OrderActionButtonBuilder {
  /// 构建响应式按钮布局
  static Widget buildResponsiveButtonLayout(List<Widget> buttons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final buttonCount = buttons.length;
        
        // 如果按钮数量 > 3 或屏幕宽度较小，使用多行布局
        if (buttonCount > 3 || screenWidth < 400) {
          return _buildMultiRowLayout(buttons);
        } else {
          // 单行布局
          return _buildSingleRowLayout(buttons);
        }
      },
    );
  }

  /// 构建单行布局
  static Widget _buildSingleRowLayout(List<Widget> buttons) {
    return Row(
      children: buttons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? 8.0 : 0,
            ),
            child: button,
          ),
        );
      }).toList(),
    );
  }

  /// 构建多行布局
  static Widget _buildMultiRowLayout(List<Widget> buttons) {
    // 将主要按钮（最后一个）放在单独一行，其余按钮放在上面的行
    if (buttons.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: buttons.first,
      );
    }

    final secondaryButtons = buttons.take(buttons.length - 1).toList();
    final primaryButton = buttons.last;

    return Column(
      children: [
        // 次要操作按钮行
        if (secondaryButtons.isNotEmpty) ...[
          _buildSecondaryButtonsRow(secondaryButtons),
          const SizedBox(height: 8),
        ],
        // 主要操作按钮行
        SizedBox(
          width: double.infinity,
          child: primaryButton,
        ),
      ],
    );
  }

  /// 构建次要按钮行
  static Widget _buildSecondaryButtonsRow(List<Widget> buttons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        // 如果次要按钮太多，分成两行
        if (buttons.length > 3 || (buttons.length > 2 && screenWidth < 360)) {
          return Column(
            children: [
              _buildButtonRow(buttons.take(2).toList()),
              if (buttons.length > 2) ...[
                const SizedBox(height: 8),
                _buildButtonRow(buttons.skip(2).toList()),
              ],
            ],
          );
        } else {
          return _buildButtonRow(buttons);
        }
      },
    );
  }

  /// 构建按钮行
  static Widget _buildButtonRow(List<Widget> buttons) {
    return Row(
      children: buttons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? 8.0 : 0,
            ),
            child: button,
          ),
        );
      }).toList(),
    );
  }

  /// 构建单个按钮
  static Widget buildButton(
    BuildContext context, 
    String text, 
    VoidCallback onPressed, 
    {bool isPrimary = false}
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Define common style elements
    final buttonPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    final buttonTextStyle = textTheme.bodySmall;
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
    const buttonMinSize = Size(0, 36);

    return isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
               backgroundColor: colorScheme.primary,
               foregroundColor: colorScheme.onPrimary,
               padding: buttonPadding,
               textStyle: buttonTextStyle,
               shape: buttonShape,
               minimumSize: buttonMinSize,
               elevation: 2,
            ),
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              padding: buttonPadding,
              textStyle: buttonTextStyle,
              shape: buttonShape,
              minimumSize: buttonMinSize,
            ),
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          );
  }
}