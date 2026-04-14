import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showManualForm = false;

  void _toggleManualForm() {
    setState(() => _showManualForm = !_showManualForm);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_hero.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SamsUiTokens.brandRed,
                      SamsUiTokens.primary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    SamsUiTokens.brandRed.withValues(alpha: 0.72),
                    const Color(0xFF2A030B).withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(maxHeight: h * 0.53, maxWidth: 520),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(98),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => context.goNamed(AppRouteNames.home),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4E5662),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: SamsUiTokens.brandRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.qr_code_2_rounded, size: 24, color: SamsUiTokens.brandRed),
                          ),
                          label: const Text(
                            'Sign-in with QR code',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('or', style: TextStyle(fontSize: 18, color: Color(0xFF666E7A), fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: _toggleManualForm,
                      child: Text(
                        _showManualForm ? 'Hide manual login' : 'Login manually',
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      child: _showManualForm
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Roll no.',
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => context.goNamed(AppRouteNames.home),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: SamsUiTokens.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 13),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text('Continue'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => context.goNamed(AppRouteNames.signup),
                      child: const Text(
                        'New here? Create an account',
                        style: TextStyle(
                          color: SamsUiTokens.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
