import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_pressable.dart';
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
        listener: (context, state) async {
          if (state.status == ChangePasswordStatus.failure &&
              state.feedbackMessage != null) {
            ModernSnackbars.show(
              context,
              message: state.feedbackMessage!,
              type: ModernSnackbarType.error,
            );
          }

          if (state.status == ChangePasswordStatus.success) {
            _currentController.clear();
            _newController.clear();
            _confirmController.clear();

            ModernSnackbars.show(
              context,
              message: 'Password updated successfully',
              type: ModernSnackbarType.success,
            );

            await Future<void>.delayed(const Duration(milliseconds: 900));
            if (!context.mounted) {
              return;
            }
            Navigator.of(context).maybePop();
          }
        },
        child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
          buildWhen: (previous, current) {
            return previous.status != current.status;
          },
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const SamsAppBar(title: 'Change Password'),
              body: SafeArea(
                child: ListView(
                  padding: SamsUiTokens.pageInsets(
                    context,
                    top: 14,
                    bottom: 20,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          SamsUiTokens.radiusLg,
                        ),
                        boxShadow: SamsUiTokens.cardShadow,
                        border: Border.all(color: SamsUiTokens.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: SamsUiTokens.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const SamsLocaleText(
                              'Security',
                              style: TextStyle(
                                color: SamsUiTokens.primary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const SamsLocaleText(
                            'Update your account password',
                            style: TextStyle(
                              color: SamsUiTokens.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const SamsLocaleText(
                            'Use a strong password with letters, numbers, and symbols.',
                            style: TextStyle(
                              color: SamsUiTokens.textSecondary,
                              fontSize: 12.8,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFE7EDF5)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _currentController,
                            obscureText: _hideCurrent,
                            decoration: InputDecoration(
                              labelText: context.tr('Current Password'),
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _hideCurrent = !_hideCurrent,
                                ),
                                icon: Icon(
                                  _hideCurrent
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _newController,
                            obscureText: _hideNew,
                            decoration: InputDecoration(
                              labelText: context.tr('New Password'),
                              prefixIcon: const Icon(Icons.password_rounded),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _hideNew = !_hideNew),
                                icon: Icon(
                                  _hideNew
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _confirmController,
                            obscureText: _hideConfirm,
                            decoration: InputDecoration(
                              labelText: context.tr('Confirm New Password'),
                              prefixIcon: const Icon(Icons.lock_reset_rounded),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _hideConfirm = !_hideConfirm,
                                ),
                                icon: Icon(
                                  _hideConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: Color(0xFFE7EDF5)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: SamsTapScale(
                              enabled: !state.isSubmitting,
                              child: ElevatedButton(
                                onPressed: state.isSubmitting
                                    ? null
                                    : () {
                                        context.read<ChangePasswordBloc>().add(
                                          ChangePasswordSubmitted(
                                            currentPassword:
                                                _currentController.text,
                                            newPassword: _newController.text,
                                            confirmPassword:
                                                _confirmController.text,
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SamsUiTokens.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const SamsLocaleText('Update Password'),
                              ),
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
