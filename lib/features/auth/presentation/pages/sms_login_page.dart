import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_cubit.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_state.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_button.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/country_code.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
  late CountryCode _selectedCountry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 基于系统语言设置默认国家代码
    final locale = Localizations.localeOf(context);
    _selectedCountry = CountryCodes.getDefaultCountryCode(locale.languageCode);
    
    // 调试：打印当前语言环境
    print('Current locale: ${locale.languageCode}');
    print('AppLocalizations available: ${AppLocalizations.of(context) != null}');
    print('auth_phone_number: ${AppLocalizations.of(context).auth_phone_number}');
    }

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
              // 检查是否是验证码相关的错误
              final s = AppLocalizations.of(context);
              String errorMessage = state.failure.message;
              if (errorMessage.contains('验证码') ||
                  errorMessage.contains('code') ||
                  errorMessage.contains('Code')) {
                errorMessage = s.auth_verification_code_expired;
              } else {
                errorMessage = s.auth_login_failed(errorMessage);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
            } else if (state is SmsLoginCodeSendFailure) {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context).auth_code_send_failed(state.failure.message))),
              );
            } else if (state is SmsLoginSuccess) {
              // 导航将由全局 AuthStatus 监听器处理
              // Navigator.of(context).pushReplacementNamed('/home');
              print('Login Success! User ID: ${state.user.id}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context).auth_login_success)),
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
                      // 顶部留白间隔
                      const SizedBox(height: 60),

                      PhoneInputField(
                        controller: _phoneController,
                        selectedCountry: _selectedCountry,
                        onCountryChanged: (country) {
                          setState(() {
                            _selectedCountry = country;
                          });
                        },
                      ),
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
                               // 发送验证码时包含区号
                               final fullPhone = '${_selectedCountry.dialCode}$phone';
                               print('Requesting code for $fullPhone');
                               context.read<SmsLoginCubit>().sendCode(fullPhone);
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
                                 // 登录时包含区号
                                 final fullPhone = '${_selectedCountry.dialCode}${_phoneController.text}';
                                 print('Attempting login with phone: $fullPhone, code: ${_codeController.text}');
                                 context.read<SmsLoginCubit>().login(
                                   fullPhone,
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
                            : Text(AppLocalizations.of(context).auth_login),
                      ),
                      const SizedBox(height: 24),

                      // --- Bottom Links ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              foregroundColor: linkColor // Explicitly set link color here to override theme
                            ),
                            onPressed: () {
                              // TODO: Navigate to Privacy Policy
                              print("Navigate to Privacy Policy");
                            },
                            child: Text(
                              AppLocalizations.of(context).auth_privacy_policy,
                              style: const TextStyle(fontSize: 12), // Style is now handled by foregroundColor
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              AppLocalizations.of(context).auth_and,
                              style: TextStyle(fontSize: 12, color: linkColor), // Use defined link color
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              foregroundColor: linkColor // Explicitly set link color here to override theme
                            ),
                            onPressed: () {
                              // TODO: Navigate to User Agreement
                              print("Navigate to User Agreement");
                            },
                            child: Text(
                              AppLocalizations.of(context).auth_user_agreement,
                              style: const TextStyle(fontSize: 12), // Style is now handled by foregroundColor
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

