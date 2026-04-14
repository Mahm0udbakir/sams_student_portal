import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../bloc/change_password_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordBloc(),
      child: BlocListener<ChangePasswordBloc, ChangePasswordState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == ChangePasswordStatus.failure && state.feedbackMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.feedbackMessage!)),
            );
          }

          if (state.status == ChangePasswordStatus.success) {
            _currentController.clear();
            _newController.clear();
            _confirmController.clear();
          }
        },
        child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              appBar: AppBar(
                title: const Text('Change Password'),
                centerTitle: true,
              ),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                        boxShadow: SamsUiTokens.cardShadow,
                        border: Border.all(color: SamsUiTokens.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Update your account password',
                            style: TextStyle(
                              color: SamsUiTokens.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Use a strong password with letters, numbers, and symbols.',
                            style: TextStyle(
                              color: SamsUiTokens.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (state.isSuccess) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: SamsUiTokens.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Password changed successfully',
                                style: TextStyle(
                                  color: SamsUiTokens.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          TextField(
                            controller: _currentController,
                            obscureText: _hideCurrent,
                            decoration: InputDecoration(
                              labelText: 'Current Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _hideCurrent = !_hideCurrent),
                                icon: Icon(
                                  _hideCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _newController,
                            obscureText: _hideNew,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              prefixIcon: const Icon(Icons.password_rounded),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _hideNew = !_hideNew),
                                icon: Icon(_hideNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _confirmController,
                            obscureText: _hideConfirm,
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
                              prefixIcon: const Icon(Icons.lock_reset_rounded),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                                icon: Icon(
                                  _hideConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isSubmitting
                                  ? null
                                  : () {
                                      context.read<ChangePasswordBloc>().add(
                                            ChangePasswordSubmitted(
                                              currentPassword: _currentController.text,
                                              newPassword: _newController.text,
                                              confirmPassword: _confirmController.text,
                                            ),
                                          );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SamsUiTokens.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Update Password'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
