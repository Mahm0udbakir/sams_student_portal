import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../utils/auth_feedback.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final PinInputController _otpController = PinInputController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _submitOtp(BuildContext context) {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      return;
    }

    context.read<AuthCubit>().verifyOtp(otp);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified successfully.')),
          );
          context.goNamed(AppRouteNames.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${authErrorTitle(state.type)}: ${authErrorMessage(state.type, state.message)}',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final challenge = state is AuthOtpRequired
            ? state
            : state is AuthError && state.isOtpRelated
            ? AuthOtpRequired(
                verificationId: state.verificationId!,
                email: state.email ?? '',
                name: state.name ?? '',
                expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 10)),
                attemptsRemaining: 0,
                purpose: state.purpose ?? 'signup',
              )
            : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F8FC),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: SamsUiTokens.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.mark_email_read_rounded,
                          color: SamsUiTokens.primary,
                          size: 34,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Verify your email',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          challenge == null
                              ? 'Enter the 6-digit verification code sent to your email.'
                              : 'Code sent to ${challenge.email}',
                          style: const TextStyle(
                            color: Color(0xFF5B6472),
                            fontSize: 13.4,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        MaterialPinField(
                          pinController: _otpController,
                          length: 6,
                          autoFocus: true,
                          keyboardType: TextInputType.number,
                          onChanged: (_) {},
                          onCompleted: (_) => _submitOtp(context),
                          theme: MaterialPinTheme(
                            shape: MaterialPinShape.outlined,
                            cellSize: const Size(50, 54),
                            borderRadius: BorderRadius.circular(14),
                            borderWidth: 1.5,
                            errorColor: SamsUiTokens.primary,
                            errorFillColor: const Color(0xFFF7FBFE),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (challenge != null)
                          Text(
                            'Attempts remaining: ${challenge.attemptsRemaining}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: SamsTapScale(
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () => _submitOtp(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SamsUiTokens.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                              ),
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Verify Code',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () => context
                                        .read<AuthCubit>()
                                        .resendOtp(),
                                child: const Text('Resend code'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextButton(
                                onPressed: () => context.goNamed(AppRouteNames.login),
                                child: const Text('Back to login'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
