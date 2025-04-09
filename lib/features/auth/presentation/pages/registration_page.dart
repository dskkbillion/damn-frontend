import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:damn_frontend/features/auth/presentation/bloc/registration/registration_cubit.dart';
import 'package:damn_frontend/features/auth/presentation/bloc/registration/registration_state.dart';
import 'package:damn_frontend/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:damn_frontend/features/auth/presentation/widgets/verification_code_input_field.dart';
import 'package:damn_frontend/features/auth/presentation/widgets/verification_code_button.dart';

// TODO: Implement UI based on designs/RN code for registration

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _inviterIdController = TextEditingController(); // If needed
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _inviterIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Provide RegistrationCubit via BlocProvider

    return Scaffold(
      appBar: AppBar(title: const Text('注册')), // Adjust AppBar
      body: BlocConsumer<RegistrationCubit, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('注册失败: ${state.failure.message}')),
            );
          } else if (state is RegistrationCodeSendFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('验证码发送失败: ${state.failure.message}')),
            );
          } else if (state is RegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('注册成功！请登录')),
            );
            // Navigate back to login page after successful registration
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          bool isLoading = state is RegistrationLoading || state is RegistrationCodeSending;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // TODO: Add Logo or other visual elements
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
                        phoneController: _phoneController,
                        onSendCode: (phone) {
                          context.read<RegistrationCubit>().sendCode(phone);
                        },
                        // Use RegistrationState to control button
                        codeSentState: state is RegistrationCodeSentSuccess ? CodeButtonState.counting : CodeButtonState.idle,
                        isSending: state is RegistrationCodeSending,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // TODO: Add Inviter ID field if required by API
                  // TextFormField(
                  //   controller: _inviterIdController,
                  //   decoration: const InputDecoration(
                  //     labelText: '邀请码 (可选)',
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: isLoading ? null : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<RegistrationCubit>().register(
                              phone: _phoneController.text,
                              code: _codeController.text,
                              // Pass scene/inviterId if needed after confirmation
                              // inviterId: _inviterIdController.text,
                            );
                      }
                    },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('注册'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                       Navigator.of(context).pop(); // Go back to login
                    },
                    child: const Text('已有账号？去登录'),
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
