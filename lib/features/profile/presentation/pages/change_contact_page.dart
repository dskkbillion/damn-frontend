import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_button.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/country_code.dart';
import 'package:dskk_flutter_refactor/features/profile/presentation/bloc/profile_bloc.dart';

class ChangeContactPage extends StatefulWidget {
  final String contactType; // "phone" or "email"
  final String currentContact;

  const ChangeContactPage({
    super.key,
    required this.contactType,
    required this.currentContact,
  });

  @override
  State<ChangeContactPage> createState() => _ChangeContactPageState();
}

class _ChangeContactPageState extends State<ChangeContactPage> {
  // Step 1: verify old contact
  final TextEditingController _oldCodeController = TextEditingController();
  // Step 2: bind new contact
  final TextEditingController _newContactController = TextEditingController();
  final TextEditingController _newCodeController = TextEditingController();
  final _newFormKey = GlobalKey<FormState>();

  late CountryCode _selectedCountry;

  int _currentStep = 1; // 1 or 2
  String? _verifyToken;

  // Verification code button states - step 1
  CodeButtonState _step1CodeState = CodeButtonState.idle;
  bool _step1IsSending = false;

  // Verification code button states - step 2
  CodeButtonState _step2CodeState = CodeButtonState.idle;
  bool _step2IsSending = false;

  bool _isSubmitting = false;

  bool get _isEmail => widget.contactType == 'email';


  @override
  void initState() {
    super.initState();
    _selectedCountry = CountryCodes.commonCountries[0]; // default China
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    _selectedCountry = CountryCodes.getDefaultCountryCode(locale.languageCode);
  }

  @override
  void dispose() {
    _oldCodeController.dispose();
    _newContactController.dispose();
    _newCodeController.dispose();
    super.dispose();
  }

  String get _fullNewPhoneNumber {
    final phone = _newContactController.text.trim();
    if (_isEmail) return phone;
    if (_selectedCountry.dialCode == '+86') return phone;
    return '${_selectedCountry.dialCode}$phone';
  }

  String _maskContact(String contact) {
    if (_isEmail) {
      return _maskEmail(contact);
    }
    return _maskPhoneNumber(contact);
  }

  String _maskEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 1) return email;
    final prefix = email.substring(0, 1);
    final domain = email.substring(atIndex);
    return '$prefix****$domain';
  }

  String _maskPhoneNumber(String phone) {
    if (phone.startsWith('+')) {
      final digits = phone.substring(1);
      if (digits.length > 8) {
        return '+${digits.substring(0, 4)}****${digits.substring(digits.length - 4)}';
      }
      return phone;
    }
    if (phone.length > 8) {
      return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
    }
    return phone;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱地址';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  // --- Step 1: Send code to old contact ---
  Future<void> _onSendCodeStep1(String _) async {
    setState(() => _step1IsSending = true);
    final dio = GetIt.instance<Dio>();
    try {
      final response = await dio.post(
        '/api/common/send-code/verify-contact',
        data: {'mobile': widget.currentContact},
      );
      if (response.statusCode == 200 &&
          (response.data['code'] == 200 || response.data['code'] == 0)) {
        if (mounted) {
          setState(() {
            _step1CodeState = CodeButtonState.counting;
            _step1IsSending = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('验证码已发送'), backgroundColor: AppColors.success),
          );
          // Reset to idle after 60s
          Future.delayed(const Duration(seconds: 60), () {
            if (mounted && _step1CodeState == CodeButtonState.counting) {
              setState(() => _step1CodeState = CodeButtonState.idle);
            }
          });
        }
      } else {
        final errorMsg = response.data['msg'] ?? '发送验证码失败';
        if (mounted) {
          setState(() => _step1IsSending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _step1IsSending = false);
        final msg = (e.response?.data is Map && e.response?.data['msg'] != null)
            ? e.response?.data['msg']
            : '发送验证码失败，请检查网络连接';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // --- Step 1: Verify old contact ---
  Future<void> _onVerifyOldContact() async {
    final code = _oldCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入验证码')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final dio = GetIt.instance<Dio>();
    try {
      final response = await dio.post(
        '/api/member/verify-current-contact',
        data: {
          'contact': widget.currentContact,
          'code': code,
        },
      );
      if (response.statusCode == 200 &&
          (response.data['code'] == 200 || response.data['code'] == 0)) {
        final token = response.data['data']?['verifyToken'] as String?;
        if (mounted) {
          setState(() {
            _verifyToken = token;
            _currentStep = 2;
            _isSubmitting = false;
          });
        }
      } else {
        final errorMsg = response.data['msg'] ?? '验证失败';
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        final msg = (e.response?.data is Map && e.response?.data['msg'] != null)
            ? e.response?.data['msg']
            : '验证失败，请检查网络连接';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // --- Step 2: Send code to new contact ---
  Future<void> _onSendCodeStep2(String contact) async {
    if (_isEmail) {
      final error = _validateEmail(contact);
      if (error != null) return;
    } else {
      if (_newContactController.text.trim().isEmpty) return;
    }

    final newContact = _isEmail ? _newContactController.text.trim() : _fullNewPhoneNumber;
    setState(() => _step2IsSending = true);
    final dio = GetIt.instance<Dio>();
    try {
      final response = await dio.post(
        '/api/common/send-code/verify-contact',
        data: {'mobile': newContact},
      );
      if (response.statusCode == 200 &&
          (response.data['code'] == 200 || response.data['code'] == 0)) {
        if (mounted) {
          setState(() {
            _step2CodeState = CodeButtonState.counting;
            _step2IsSending = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('验证码已发送'), backgroundColor: AppColors.success),
          );
          Future.delayed(const Duration(seconds: 60), () {
            if (mounted && _step2CodeState == CodeButtonState.counting) {
              setState(() => _step2CodeState = CodeButtonState.idle);
            }
          });
        }
      } else {
        final errorMsg = response.data['msg'] ?? '发送验证码失败';
        if (mounted) {
          setState(() => _step2IsSending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _step2IsSending = false);
        final msg = (e.response?.data is Map && e.response?.data['msg'] != null)
            ? e.response?.data['msg']
            : '发送验证码失败，请检查网络连接';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // --- Step 2: Change contact ---
  Future<void> _onChangeContact() async {
    if (!(_newFormKey.currentState?.validate() ?? false)) return;

    final newContact = _isEmail ? _newContactController.text.trim() : _fullNewPhoneNumber;
    final code = _newCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入验证码')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final dio = GetIt.instance<Dio>();
    try {
      final response = await dio.post(
        '/api/member/change-contact',
        data: {
          'verifyToken': _verifyToken,
          'newContact': newContact,
          'code': code,
        },
      );
      if (response.statusCode == 200 &&
          (response.data['code'] == 200 || response.data['code'] == 0)) {
        if (mounted) {
          // Refresh profile
          GetIt.instance<ProfileBloc>().add(const GetUserProfileEvent(skipCache: true));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('换绑成功'), backgroundColor: AppColors.success),
          );
          context.pop(true);
        }
      } else {
        final errorMsg = response.data['msg'] ?? '换绑失败';
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        final msg = (e.response?.data is Map && e.response?.data['msg'] != null)
            ? e.response?.data['msg']
            : '换绑失败，请检查网络连接';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_isEmail ? '换绑邮箱' : '换绑手机号'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
        ),
    );
  }

  Widget _buildStep1() {
    // Use a hidden TextEditingController for the VerificationCodeButton
    // since it requires a phoneController but we send to the old contact directly
    final dummyController = TextEditingController(text: widget.currentContact);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator
        Text(
          '第 1 步：验证当前${_isEmail ? '邮箱' : '手机号'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        // Display current contact (masked)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.borderInput),
          ),
          child: Text(
            _maskContact(widget.currentContact),
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 16),
        // Verification code input + send button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: VerificationCodeInputField(controller: _oldCodeController),
            ),
            const SizedBox(width: 12),
            VerificationCodeButton(
              phoneController: dummyController,
              onSendCode: _onSendCodeStep1,
              codeSentState: _step1CodeState,
              isSending: _step1IsSending,
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Next step button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _onVerifyOldContact,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('下一步', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _newFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          Text(
            '第 2 步：绑定新的${_isEmail ? '邮箱' : '手机号'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          // New contact input
          if (_isEmail)
            TextFormField(
              controller: _newContactController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '新邮箱地址',
                hintText: '请输入新邮箱地址',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: _validateEmail,
            )
          else
            PhoneInputField(
              controller: _newContactController,
              selectedCountry: _selectedCountry,
              onCountryChanged: (country) {
                setState(() => _selectedCountry = country);
              },
            ),
          const SizedBox(height: 16),
          // Verification code input + send button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: VerificationCodeInputField(controller: _newCodeController),
              ),
              const SizedBox(width: 12),
              VerificationCodeButton(
                phoneController: _newContactController,
                onSendCode: _onSendCodeStep2,
                codeSentState: _step2CodeState,
                isSending: _step2IsSending,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Confirm change button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onChangeContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('确认换绑', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}
