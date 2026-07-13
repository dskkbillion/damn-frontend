import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_cubit.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_state.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_button.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/login_particle_backdrop.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/country_code.dart';
import 'package:dskk_flutter_refactor/core/utils/phone_validator.dart';

enum LoginMode { phone, email }

class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late CountryCode _selectedCountry;
  LoginMode _loginMode = LoginMode.email;
  // #276: 记录上次成功发送验证码的 mode，用于让倒计时只对该 mode 生效
  // 切到另一个 mode 时 lastSentCodeMode != _loginMode，按钮回到 idle 状态
  LoginMode? _lastSentCodeMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 基于系统语言设置默认国家代码
    final locale = Localizations.localeOf(context);
    _selectedCountry = CountryCodes.getDefaultCountryCode(locale.languageCode);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // 验证邮箱格式
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // 获取当前输入的账号（手机号或邮箱）
  String _getCurrentAccount() {
    if (_loginMode == LoginMode.phone) {
      return '${_selectedCountry.dialCode}${_phoneController.text}';
    } else {
      return _emailController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define Theme Colors
    const Color primaryColor = AppColors.primary;
    const Color buttonBackgroundColor = AppColors.primaryVariant;
    const Color linkColor = AppColors.textSecondary;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const LoginParticleBackdrop(),
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: primaryColor,
                    secondary: primaryColor,
                  ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
            ),
            child: BlocConsumer<SmsLoginCubit, SmsLoginState>(
              listener: (context, state) {
                // 处理副作用，如显示 SnackBar, 导航等
                if (state is SmsLoginFailure) {
                  // #209 AUTH-07: 不直接暴露 ServerException 原始文本,识别"验证码"
                  // 关键字后显示友好提示
                  String raw = state.failure.message;
                  String userMessage;
                  if (raw.contains('验证码') ||
                      raw.toLowerCase().contains('code')) {
                    userMessage = '验证码错误或已过期,请重新获取';
                  } else {
                    // 提取 message: 后的实际内容,丢掉 ServerException 包装
                    final match =
                        RegExp(r'message:\s*([^,)]+)').firstMatch(raw);
                    final clean = match?.group(1)?.trim() ?? raw;
                    userMessage = '登录失败:$clean';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(userMessage)),
                  );
                } else if (state is SmsLoginCodeSendFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('验证码发送失败: ${state.failure.message}')),
                  );
                } else if (state is SmsLoginSuccess) {
                  debugPrint('Login Success! User ID: ${state.user.id}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('登录成功!')),
                  );
                }
              },
              builder: (context, state) {
                // 只在真正登录中显示底部按钮 loading;
                // SmsLoginCodeSending 由「获取验证码」按钮自己的 isSending 处理,
                // 否则发送验证码时底部+右侧两处同时转(#328)。
                bool isLoading = state is SmsLoginLoading;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 64.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // 顶部Logo区域（保持原有设计）
                          const SizedBox(height: 60),

                          // App Logo
                          Center(
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/nav/dskk_logo.svg',
                                  width: 100,
                                  height: 100,
                                  colorFilter: const ColorFilter.mode(
                                    primaryColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'DeepStream',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // 登录模式切换按钮
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: primaryColor.withOpacity(0.3)),
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusSm),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildModeButton(
                                    mode: LoginMode.email,
                                    icon: Icons.email,
                                    label: '邮箱',
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: primaryColor.withOpacity(0.3),
                                ),
                                Expanded(
                                  child: _buildModeButton(
                                    mode: LoginMode.phone,
                                    icon: Icons.phone,
                                    label: '手机号',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 根据登录模式显示不同的输入框
                          if (_loginMode == LoginMode.phone) ...[
                            PhoneInputField(
                              controller: _phoneController,
                              selectedCountry: _selectedCountry,
                              onCountryChanged: (country) {
                                setState(() {
                                  _selectedCountry = country;
                                });
                              },
                            ),
                          ] else if (_loginMode == LoginMode.email) ...[
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: '邮箱地址',
                                hintText: '请输入邮箱地址',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入邮箱地址';
                                }
                                if (!_isValidEmail(value)) {
                                  return '请输入有效的邮箱地址';
                                }
                                return null;
                              },
                            ),
                          ],

                          // 验证码输入区域
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: VerificationCodeInputField(
                                    controller: _codeController),
                              ),
                              const SizedBox(width: 8),
                              VerificationCodeButton(
                                // #276: 用 ValueKey 强制按 mode 重建 widget，
                                // 配合下面 codeSentState 只在 _lastSentMode == 当前 mode 时传 counting
                                key: ValueKey(_loginMode),
                                phoneController: _loginMode == LoginMode.phone
                                    ? _phoneController
                                    : _emailController,
                                onSendCode: (account) async {
                                  if (_loginMode == LoginMode.email) {
                                    // 邮箱模式验证
                                    if (!_isValidEmail(account)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('请输入有效的邮箱地址')),
                                      );
                                      return;
                                    }
                                    debugPrint(
                                        'Sending code to email: $account');
                                    // #276: 记录当前发送 mode
                                    setState(() {
                                      _lastSentCodeMode = LoginMode.email;
                                    });
                                    context
                                        .read<SmsLoginCubit>()
                                        .sendCode(account);
                                  } else {
                                    // 手机模式验证 - 使用统一的验证工具类
                                    final validationResult =
                                        PhoneValidator.validate(
                                      account,
                                      _selectedCountry.code,
                                      context: context,
                                    );
                                    if (!validationResult.isValid) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(validationResult
                                                .errorMessage!)),
                                      );
                                      return;
                                    }
                                    final fullPhone =
                                        '${_selectedCountry.dialCode}$account';
                                    debugPrint(
                                        'Sending code to phone: $fullPhone');
                                    // #276: 记录当前发送 mode
                                    setState(() {
                                      _lastSentCodeMode = LoginMode.phone;
                                    });
                                    context
                                        .read<SmsLoginCubit>()
                                        .sendCode(fullPhone);
                                  }
                                },
                                // #276: 仅当 cubit 处于 CodeSentSuccess 且
                                // 发送 mode == 当前 mode 时显示倒计时，
                                // 切到另一个 mode 按钮回到 idle 状态
                                codeSentState:
                                    (state is SmsLoginCodeSentSuccess &&
                                            _lastSentCodeMode == _loginMode)
                                        ? CodeButtonState.counting
                                        : CodeButtonState.idle,
                                isSending: state is SmsLoginCodeSending,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 登录按钮
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonBackgroundColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm),
                              ),
                              disabledBackgroundColor:
                                  buttonBackgroundColor.withOpacity(0.7),
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final account = _getCurrentAccount();
                                      debugPrint(
                                          'Attempting login with account: $account, code: ${_codeController.text}');
                                      context.read<SmsLoginCubit>().login(
                                            account,
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

                          // 底部链接
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  foregroundColor: linkColor,
                                ),
                                onPressed: () {
                                  // TODO: Navigate to Privacy Policy
                                  debugPrint("Navigate to Privacy Policy");
                                },
                                child: const Text(
                                  '隐私政策',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  '和',
                                  style:
                                      TextStyle(fontSize: 12, color: linkColor),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  foregroundColor: linkColor,
                                ),
                                onPressed: () {
                                  // TODO: Navigate to User Agreement
                                  debugPrint("Navigate to User Agreement");
                                },
                                child: const Text(
                                  '用户协议',
                                  style: TextStyle(fontSize: 12),
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
        ],
      ),
    );
  }

  // 构建模式切换按钮
  Widget _buildModeButton({
    required LoginMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _loginMode == mode;
    const primaryColor = AppColors.primary;

    return Material(
      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _loginMode = mode;
            // 清空验证码
            _codeController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? primaryColor : AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryColor : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
