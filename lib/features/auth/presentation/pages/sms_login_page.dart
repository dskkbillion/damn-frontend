import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    // Define Theme Colors
    const Color primaryColor = Color(0xFFB66D0E);
    const Color buttonBackgroundColor = Color(0xFFC58C4A);
    final Color linkColor = Colors.grey[600]!;

    // TODO: 使用 BlocProvider 提供 SmsLoginCubit 实例
    // final cubit = BlocProvider.of<SmsLoginCubit>(context);

    return Scaffold(
      body: Theme( // Apply local theme override
        data: Theme.of(context).copyWith( // Copy existing theme and override parts
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: primaryColor, // Set primary color to #b66d0e
            secondary: primaryColor, // Optionally set secondary too
          ),
          // You might need to adjust text field decoration themes specifically if the above doesn't work
          /*
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 2.0),
            ),
             labelStyle: TextStyle(color: primaryColor), // Style for label when focused
             // floatingLabelStyle: TextStyle(color: primaryColor) // Newer SDKs use this
          ),
          textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
             cursorColor: primaryColor, // Set cursor color
             selectionColor: primaryColor.withOpacity(0.4), // Set text selection color
             selectionHandleColor: primaryColor, // Set selection handle color
          ),
          */
          // Style TextButton globally within this theme scope if needed
           textButtonTheme: TextButtonThemeData(
             style: TextButton.styleFrom(
               foregroundColor: primaryColor, // Make TextButtons use primary color by default
             ),
           ),
        ),
        child: BlocConsumer<SmsLoginCubit, SmsLoginState>(
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

            // Use SingleChildScrollView to prevent overflow on smaller screens
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // --- Logo (Temporarily Commented Out) ---
                      /*
                      // Ensure 'assets/images/图标.svg' exists and pubspec.yaml is updated.
                      // Run 'flutter pub get' and try a full app restart if logo doesn't show.
                      SvgPicture.asset(
                        'assets/images/图标.svg',
                        height: 80, // Adjust height as needed
                        // Optional: Add a placeholder if loading fails, though svg loader might not support it directly
                        // placeholderBuilder: (BuildContext context) => Container(
                        //      height: 80, width: 80, color: Colors.grey[200], child: const Center(child: Text('Logo'))),
                      ),
                      const SizedBox(height: 48),
                      */
                      // Add some space at the top if logo is removed
                      const SizedBox(height: 80), // Adjust this value as needed

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

                      // --- Login Button ---
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBackgroundColor, // Use less saturated theme color
                          foregroundColor: Colors.white, // Text color on button
                          minimumSize: const Size(double.infinity, 48),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder( // Optional: Add rounded corners
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          // Style for disabled state (loading)
                          disabledBackgroundColor: buttonBackgroundColor.withOpacity(0.7),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
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
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Text('登录'),
                      ),
                      const SizedBox(height: 24),

                      // --- Bottom Links ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(50, 30),
                              foregroundColor: linkColor // Explicitly set link color here to override theme
                            ),
                            onPressed: () {
                              // TODO: Navigate to Privacy Policy
                              print("Navigate to Privacy Policy");
                            },
                            child: Text(
                              '隐私政策',
                              style: TextStyle(fontSize: 12), // Style is now handled by foregroundColor
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              '和',
                              style: TextStyle(fontSize: 12, color: linkColor), // Use defined link color
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(50, 30),
                              foregroundColor: linkColor // Explicitly set link color here to override theme
                            ),
                            onPressed: () {
                              // TODO: Navigate to User Agreement
                              print("Navigate to User Agreement");
                            },
                            child: Text(
                              '用户协议',
                              style: TextStyle(fontSize: 12), // Style is now handled by foregroundColor
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

