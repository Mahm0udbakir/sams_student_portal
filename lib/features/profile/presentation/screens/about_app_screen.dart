import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'About App'),
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 24),
          children: [
            const _AppIntroCard(),
            const SizedBox(height: 14),
            const _AboutSectionCard(
              title: 'What SAMS Student Portal does',
              icon: Icons.dashboard_customize_rounded,
              children: [
                _BulletText(
                  'Keeps your attendance, schedule, messages, and campus updates in one place.',
                ),
                _BulletText(
                  'Provides quick access to hostel, transport, and support workflows.',
                ),
                _BulletText(
                  'Designed to reduce paperwork and help students complete tasks faster.',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _AboutSectionCard(
              title: 'Support and contact',
              icon: Icons.support_agent_rounded,
              children: [
                _KeyValueText(
                  label: 'Help Desk',
                  value: 'Open a concern from the app',
                ),
                SizedBox(height: 8),
                _KeyValueText(
                  label: 'Support Email',
                  value: 'support@sams.edu',
                ),
                SizedBox(height: 8),
                _KeyValueText(
                  label: 'Support Hours',
                  value: 'Mon - Sat, 8:00 AM - 6:00 PM',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AboutSectionCard(
              title: 'Legal',
              icon: Icons.gavel_rounded,
              children: [
                _LegalActionTile(
                  title: 'Terms & Conditions',
                  subtitle: 'Read usage terms and student responsibilities.',
                  onTap: () =>
                      context.pushNamed(AppRouteNames.termsAndConditions),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Divider(height: 1),
                ),
                _LegalActionTile(
                  title: 'Privacy policy',
                  subtitle:
                      'Understand how your data is collected and protected.',
                  onTap: () => context.pushNamed(AppRouteNames.privacyPolicy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppIntroCard extends StatelessWidget {
  const _AppIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063454), Color(0xFF0A5B8D)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E063454),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_rounded, color: Color(0xFFD7E9FA)),
              SizedBox(width: 8),
              SamsLocaleText(
                'SAMS Student Portal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(label: 'Version', value: '1.0.0'),
              _MetaPill(label: 'Platform', value: 'Flutter'),
              _MetaPill(label: 'Release', value: '2026.04'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${context.tr(label)}: ',
              style: const TextStyle(
                color: Color(0xFFD7E9FA),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: context.tr(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSectionCard extends StatelessWidget {
  const _AboutSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SamsPressable(
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
      enableLift: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
          border: Border.all(color: const Color(0xFFDDE5EE)),
          boxShadow: SamsUiTokens.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: SamsUiTokens.primary, size: 20),
                const SizedBox(width: 8),
                SamsLocaleText(
                  title,
                  style: const TextStyle(
                    color: SamsUiTokens.textPrimary,
                    fontSize: 15.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 7, color: SamsUiTokens.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SamsLocaleText(
              text,
              style: const TextStyle(
                color: SamsUiTokens.textSecondary,
                fontSize: 12.8,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValueText extends StatelessWidget {
  const _KeyValueText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${context.tr(label)}: ',
            style: const TextStyle(
              color: SamsUiTokens.textPrimary,
              fontSize: 12.9,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: context.tr(value),
            style: const TextStyle(
              color: SamsUiTokens.textSecondary,
              fontSize: 12.9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalActionTile extends StatelessWidget {
  const _LegalActionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SamsPressable(
      onTap: onTap,
      enableLift: false,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 11, 2, 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SamsLocaleText(
                    title,
                    style: const TextStyle(
                      color: SamsUiTokens.textPrimary,
                      fontSize: 13.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SamsLocaleText(
                    subtitle,
                    style: const TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: SamsUiTokens.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
