import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/bind_contact_cubit.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_button.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_input_field.dart';

class BindContactPage extends StatefulWidget {
  final BindContactType contactType;

  const BindContactPage({
    Key? key,
    required this.contactType,
  }) : super(key: key);

  @override
  State<BindContactPage> createState() => _BindContactPageState();
}

class _BindContactPageState extends State<BindContactPage> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get _isEmail => widget.contactType == BindContactType.email;

  String get _title => _isEmail ? '绑定邮箱' : '绑定手机号';
  String get _contactLabel => _isEmail ? '邮箱地址' : '手机号';
  String get _contactHint => _isEmail ? '请输入邮箱地址' : '请输入手机号';

  static const Color primaryColor = Color(0xFFB66D0E);
  static const Color buttonBackgroundColor = Color(0xFFC58C4A);

  @override
  void dispose() {
    _contactController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  CodeButtonState _mapToCodeButtonState(BindContactState state) {
    if (state is BindContactCodeSent) {
      return CodeButtonState.counting;
    }
    return CodeButtonState.idle;
  }

  bool _isSendingCode(BindContactState state) {
    return state is BindContactSendingCode;
  }

  String? _validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入$_contactLabel';
    }
    if (_isEmail) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(value)) {
        return '请输入有效的邮箱地址';
      }
    } else {
      final phoneRegex = RegExp(r'^\d{7,15}$');
      if (!phoneRegex.hasMatch(value)) {
        return '请输入有效的手机号';
      }
    }
    return null;
  }

  Future<void> _onSendCode(String contact) async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<BindContactCubit>().sendCode(contact);
    }
  }

  void _onBind() {
    if (_formKey.currentState?.validate() ?? false) {
      final contact = _contactController.text.trim();
      final code = _codeController.text.trim();
      if (code.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入验证码')),
        );
        return;
      }
      context.read<BindContactCubit>().bind(contact, code, widget.contactType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocListener<BindContactCubit, BindContactState>(
          listener: (context, state) {
            if (state is BindContactCodeSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('验证码已发送'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is BindContactCodeSendFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is BindContactSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('绑定成功'),
                  backgroundColor: Colors.green,
                ),
              );
              // 返回上一页并传递成功标记
              context.pop(true);
            } else if (state is BindContactFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // 联系方式输入框
                  TextFormField(
                    controller: _contactController,
                    keyboardType: _isEmail
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: _contactLabel,
                      hintText: _contactHint,
                      prefixIcon: Icon(
                        _isEmail ? Icons.email_outlined : Icons.phone_outlined,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: _validateContact,
                  ),
                  const SizedBox(height: 16),
                  // 验证码输入框 + 发送按钮
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: VerificationCodeInputField(
                          controller: _codeController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      BlocBuilder<BindContactCubit, BindContactState>(
                        builder: (context, state) {
                          return VerificationCodeButton(
                            phoneController: _contactController,
                            onSendCode: _onSendCode,
                            codeSentState: _mapToCodeButtonState(state),
                            isSending: _isSendingCode(state),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // 确认绑定按钮
                  SizedBox(
                    width: double.infinity,
                    child: BlocBuilder<BindContactCubit, BindContactState>(
                      builder: (context, state) {
                        final isBinding = state is BindContactBinding;
                        return ElevatedButton(
                          onPressed: isBinding ? null : _onBind,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBackgroundColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                buttonBackgroundColor.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isBinding
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  '确认绑定',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
