import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agreeTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final compact = SamsUiTokens.isCompactWidth(context);
    final horizontalPadding = compact ? 14.0 : 20.0;
    final topPadding = compact ? 14.0 : 18.0;
    final bottomPadding = compact ? 10.0 : 16.0;

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
                    colors: [SamsUiTokens.brandBlue, SamsUiTokens.primary],
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
                    SamsUiTokens.brandBlue.withValues(alpha: 0.72),
                    const Color(0xFF02253D).withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.80,
                  maxWidth: 520,
                ),
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  bottomPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(88),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SamsLocaleText(
                        'Welcome.',
                        style: TextStyle(
                          color: SamsUiTokens.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const SamsLocaleText(
                        'Create your SAMS account to continue.',
                        style: TextStyle(
                          color: SamsUiTokens.textSecondary,
                          fontSize: 12.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: context.tr('Name'),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  SamsUiTokens.radiusMd,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              labelText: context.tr('Roll no.'),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  SamsUiTokens.radiusMd,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: context.tr('Password'),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  SamsUiTokens.radiusMd,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: context.tr('Confirm Password'),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  SamsUiTokens.radiusMd,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            value: _agreeTerms,
                            onChanged: (value) =>
                                setState(() => _agreeTerms = value ?? false),
                            activeColor: SamsUiTokens.primary,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const SamsLocaleText(
                              'I agree to the Terms and Conditions',
                              style: TextStyle(
                                fontSize: 12.8,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: SamsTapScale(
                              enabled: _agreeTerms,
                              child: ElevatedButton(
                                onPressed: _agreeTerms
                                    ? () => context.goNamed(AppRouteNames.home)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SamsUiTokens.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFFB7C1CB,
                                  ),
                                  disabledForegroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                ),
                                child: const SamsLocaleText(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SamsTapScale(
                            child: TextButton(
                              onPressed: () =>
                                  context.goNamed(AppRouteNames.login),
                              child: const SamsLocaleText(
                                'Already have an account? Login',
                                style: TextStyle(
                                  color: SamsUiTokens.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
        ],
      ),
    );
  }
}
