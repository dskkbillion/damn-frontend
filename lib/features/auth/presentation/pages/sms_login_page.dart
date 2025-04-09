import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_cubit.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_state.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_button.dart';

// TODO: 需要根据 design-info/HTML原型/HTML-new/outer/login/login.html 和 RN 代码实现具体 UI

class SmsLoginPage extends StatefulWidget {
  const SmsLoginPage({super.key});

  @override
  State<SmsLoginPage> createState() => _SmsLoginPageState();
}

class _SmsLoginPageState extends State<SmsLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 使用 BlocProvider 提供 SmsLoginCubit 实例
    // final cubit = BlocProvider.of<SmsLoginCubit>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('短信登录')), // TODO: 根据设计调整 AppBar
      body: BlocConsumer<SmsLoginCubit, SmsLoginState>(
        listener: (context, state) {
          // 处理副作用，如显示 SnackBar, 导航等
          if (state is SmsLoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('登录失败: ${state.failure.message}')),
            );
          } else if (state is SmsLoginCodeSendFailure) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('验证码发送失败: ${state.failure.message}')),
            );
          } else if (state is SmsLoginSuccess) {
            // 导航将由全局 AuthStatus 监听器处理
            // Navigator.of(context).pushReplacementNamed('/home');
            print('Login Success! User ID: ${state.user.id}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('登录成功!')),
            );
          }
        },
        builder: (context, state) {
          bool isLoading = state is SmsLoginLoading || state is SmsLoginCodeSending;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // TODO: 添加 Logo 或其他视觉元素 (参考 HTML/RN)
                  const FlutterLogo(size: 80),
                  const SizedBox(height: 32),

                  PhoneInputField(controller: _phoneController),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: VerificationCodeInputField(controller: _codeController),
                      ),
                      const SizedBox(width: 8),
                      VerificationCodeButton(
                        phoneController: _phoneController, // 传递手机号控制器给按钮
                        onSendCode: (phone) async {
                           // TODO: 调用 cubit.sendCode(phone);
                           print('Requesting code for $phone');
                           context.read<SmsLoginCubit>().sendCode(phone);
                        },
                        codeSentState: state is SmsLoginCodeSentSuccess ? CodeButtonState.counting : CodeButtonState.idle,
                        isSending: state is SmsLoginCodeSending,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48), // 宽按钮
                    ),
                    // 当加载中时禁用按钮
                    onPressed: isLoading ? null : () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: 调用 cubit.login(...)
                        print('Attempting login with phone: ${_phoneController.text}, code: ${_codeController.text}');
                        context.read<SmsLoginCubit>().login(
                          _phoneController.text,
                          _codeController.text,
                        );
                      }
                    },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('登录'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
