import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 显示加载对话框
void showLoadingDialog(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CustomLoadingDialog(message: message);
    },
  );
}

/// 关闭加载对话框
void dismissLoadingDialog(BuildContext context) {
  // 检查是否有路由可以弹出，避免意外关闭页面
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    // 确保只关闭对话框，不关闭页面
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}

/// 自定义加载对话框
class CustomLoadingDialog extends StatelessWidget {
  final String? message;

  const CustomLoadingDialog({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayMessage = message ?? AppLocalizations.of(context)!.core_processing;
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              displayMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 