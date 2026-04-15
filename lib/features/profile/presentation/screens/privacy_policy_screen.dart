import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Privacy Policy'),
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 24),
          children: const [
            _PrivacyHeaderCard(),
            SizedBox(height: 12),
            _PrivacySection(
              title: '1. Data we collect',
              content:
                  'We may collect profile details, student identifiers, app preferences, usage logs, and request data required to provide student services.',
            ),
            SizedBox(height: 10),
            _PrivacySection(
              title: '2. How we use data',
              content:
                  'Your data is used to deliver core features such as attendance tracking, notifications, help desk requests, and service personalization.',
            ),
            SizedBox(height: 10),
            _PrivacySection(
              title: '3. Data sharing',
              content:
                  'Data may be shared with authorized campus departments only when needed to fulfill academic, hostel, transport, or support operations.',
            ),
            SizedBox(height: 10),
            _PrivacySection(
              title: '4. Security measures',
              content:
                  'We use administrative and technical safeguards to protect student information against unauthorized access, alteration, or disclosure.',
            ),
            SizedBox(height: 10),
            _PrivacySection(
              title: '5. Data retention',
              content:
                  'Information is retained for the period necessary to provide services, comply with institutional policies, and meet legal obligations.',
            ),
            SizedBox(height: 10),
            _PrivacySection(
              title: '6. Your choices',
              content:
                  'You can manage visibility settings, notification preferences, and language options from the Settings page at any time.',
            ),
            SizedBox(height: 10),
            _PrivacySection(
              title: '7. Contact us',
              content:
                  'For privacy-related concerns, please raise a Help Desk ticket or write to privacy@sams.edu.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyHeaderCard extends StatelessWidget {
  const _PrivacyHeaderCard();

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
          Icon(Icons.shield_rounded, color: Color(0xFFD7E9FA), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: SamsLocaleText(
              'We are committed to protecting your student data and being clear about how it is used.',
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

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.title, required this.content});

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
