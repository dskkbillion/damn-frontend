import 'package:flutter/material.dart';

/// 手机号输入框 Widget
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: '手机号',
        prefixIcon: Icon(Icons.phone_android),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入手机号';
        }
        // TODO: 添加更严格的手机号格式校验
        if (value.length != 11) { // 简单校验长度
          return '请输入有效的手机号';
        }
        return null;
      },
    );
  }
}
