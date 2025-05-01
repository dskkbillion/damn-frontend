import 'package:flutter/material.dart';

/// 验证码输入框 Widget
class VerificationCodeInputField extends StatelessWidget {
  final TextEditingController controller;

  const VerificationCodeInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: '验证码',
        prefixIcon: Icon(Icons.password), // 使用类似密码的图标？或者 message 图标
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入验证码';
        }
        // TODO: 根据实际验证码长度调整校验
        if (value.length < 4 || value.length > 6) {
          return '请输入有效的验证码';
        }
        return null;
      },
    );
  }
}
