import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Terms & Conditions'),
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 24),
          children: const [
            _NoticeCard(),
            SizedBox(height: 12),
            _TermsSection(
              title: '1. Acceptance of terms',
              content:
                  'By using SAMS Student Portal, you agree to follow these terms and all applicable campus policies.',
            ),
            SizedBox(height: 10),
            _TermsSection(
              title: '2. Student account responsibility',
              content:
                  'You are responsible for maintaining the confidentiality of your login credentials and for all activity under your account.',
            ),
            SizedBox(height: 10),
            _TermsSection(
              title: '3. Acceptable use',
              content:
                  'Do not misuse the service, attempt unauthorized access, upload harmful content, or interfere with other students using the platform.',
            ),
            SizedBox(height: 10),
            _TermsSection(
              title: '4. Information accuracy',
              content:
                  'You should provide accurate and current details in forms, profiles, requests, and support tickets to ensure correct processing.',
            ),
            SizedBox(height: 10),
            _TermsSection(
              title: '5. Service availability',
              content:
                  'The app may be temporarily unavailable during maintenance, upgrades, or network issues. We aim to minimize downtime.',
            ),
            SizedBox(height: 10),
            _TermsSection(
              title: '6. Updates to terms',
              content:
                  'Terms may be revised from time to time. Continued use of the app after changes means you accept the updated terms.',
            ),
            SizedBox(height: 10),
            _TermsSection(
              title: '7. Contact',
              content:
                  'For questions regarding these terms, raise a concern through Help Desk or contact support@sams.edu.',
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063454), Color(0xFF0A4D78)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2D063454),
            blurRadius: 17,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gavel_rounded, color: Color(0xFFD7E9FA), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: SamsLocaleText(
              'Last updated: April 15, 2026. Please review this page periodically for changes.',
              style: TextStyle(
                color: Color(0xFFD7E9FA),
                fontSize: 12.5,
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

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SamsPressable(
      borderRadius: BorderRadius.circular(16),
      enableLift: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.82),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SamsLocaleText(
              title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14.3,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            SamsLocaleText(
              content,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12.8,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
