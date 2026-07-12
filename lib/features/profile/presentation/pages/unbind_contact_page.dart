import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_button.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_input_field.dart';
import 'package:dskk_flutter_refactor/features/profile/presentation/bloc/profile_bloc.dart';

class UnbindContactPage extends StatefulWidget {
  final String contactType; // "phone" or "email"
  final String currentContact;

  const UnbindContactPage({
    super.key,
    required this.contactType,
    required this.currentContact,
  });

  @override
  State<UnbindContactPage> createState() => _UnbindContactPageState();
}

class _UnbindContactPageState extends State<UnbindContactPage> {
  final TextEditingController _codeController = TextEditingController();

  CodeButtonState _codeState = CodeButtonState.idle;
  bool _isSendingCode = false;
  bool _isSubmitting = false;

  bool get _isEmail => widget.contactType == 'email';


  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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

  Future<void> _onSendCode(String _) async {
    setState(() => _isSendingCode = true);
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
            _codeState = CodeButtonState.counting;
            _isSendingCode = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('验证码已发送'), backgroundColor: AppColors.success),
          );
          Future.delayed(const Duration(seconds: 60), () {
            if (mounted && _codeState == CodeButtonState.counting) {
              setState(() => _codeState = CodeButtonState.idle);
            }
          });
        }
      } else {
        final errorMsg = response.data['msg'] ?? '发送验证码失败';
        if (mounted) {
          setState(() => _isSendingCode = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isSendingCode = false);
        final msg = (e.response?.data is Map && e.response?.data['msg'] != null)
            ? e.response?.data['msg']
            : '发送验证码失败，请检查网络连接';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _onUnbind() async {
    final code = _codeController.text.trim();
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
        '/api/member/unbind-contact',
        data: {
          'contact': widget.currentContact,
          'code': code,
        },
      );
      if (response.statusCode == 200 &&
          (response.data['code'] == 200 || response.data['code'] == 0)) {
        if (mounted) {
          // Refresh profile
          GetIt.instance<ProfileBloc>().add(const GetUserProfileEvent(skipCache: true));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('解绑成功'), backgroundColor: AppColors.success),
          );
          context.pop(true);
        }
      } else {
        final errorMsg = response.data['msg'] ?? '解绑失败';
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
            : '解绑失败，请检查网络连接';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dummyController = TextEditingController(text: widget.currentContact);
    final contactLabel = _isEmail ? '邮箱' : '手机号';

    return Scaffold(
        backgroundColor: AppColors.backgroundSecondary,
        appBar: AppBar(
          title: Text('解绑$contactLabel'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '解绑后，您将无法使用该$contactLabel登录',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Main card
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                tintOpacity: 0.62,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前$contactLabel',
                      style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _maskContact(widget.currentContact),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    const Text(
                      '验证身份',
                      style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: VerificationCodeInputField(controller: _codeController),
                        ),
                        const SizedBox(width: 12),
                        VerificationCodeButton(
                          phoneController: dummyController,
                          onSendCode: _onSendCode,
                          codeSentState: _codeState,
                          isSending: _isSendingCode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Confirm unbind button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _onUnbind,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: AppColors.error.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                          ),
                        )
                      : const Text('确认解绑', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  '解绑操作不可撤销',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
