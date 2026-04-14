import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showProfilePhoto = true;
  bool _showContactInfo = false;
  bool _allowDataSharing = false;
  bool _allowAnalytics = true;
  bool _pushAlerts = true;
  bool _emailUpdates = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: SamsUiTokens.scaffoldBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: SamsUiTokens.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Privacy'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 20),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                boxShadow: SamsUiTokens.cardShadow,
                border: Border.all(color: const Color(0xFFDDE4ED)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: SamsUiTokens.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Manage privacy and notification preferences for your SAMS account.',
                      style: TextStyle(
                        color: SamsUiTokens.textSecondary,
                        fontSize: 12.8,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: 'Profile Visibility',
              children: [
                _SettingTile(
                  title: 'Show profile photo to classmates',
                  subtitle: 'Controls visibility of your avatar in student directory.',
                  value: _showProfilePhoto,
                  onChanged: (value) => setState(() => _showProfilePhoto = value),
                ),
                _SettingTile(
                  title: 'Show contact information',
                  subtitle: 'Allow classmates to see your registered contact details.',
                  value: _showContactInfo,
                  onChanged: (value) => setState(() => _showContactInfo = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: 'Data Sharing',
              children: [
                _SettingTile(
                  title: 'Share data with campus services',
                  subtitle: 'Used to personalize student features and recommendations.',
                  value: _allowDataSharing,
                  onChanged: _isSaving ? null : (value) => setState(() => _allowDataSharing = value),
                ),
                _SettingTile(
                  title: 'Allow anonymous analytics',
                  subtitle: 'Help improve the SAMS app experience and performance.',
                  value: _allowAnalytics,
                  onChanged: _isSaving ? null : (value) => setState(() => _allowAnalytics = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: 'Notification Preferences',
              children: [
                _SettingTile(
                  title: 'Push alerts',
                  subtitle: 'Receive instant notices for attendance and announcements.',
                  value: _pushAlerts,
                  onChanged: _isSaving ? null : (value) => setState(() => _pushAlerts = value),
                ),
                _SettingTile(
                  title: 'Email updates',
                  subtitle: 'Receive periodic summaries and account updates by email.',
                  value: _emailUpdates,
                  onChanged: _isSaving ? null : (value) => setState(() => _emailUpdates = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                boxShadow: SamsUiTokens.cardShadow,
                border: Border.all(color: SamsUiTokens.divider),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last updated: Apr 14, 2026 • 11:40 AM',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your data is encrypted in transit and stored according to SAMS policy v3.2.',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: SamsTapScale(
                enabled: !_isSaving,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() => _isSaving = true);
                          await Future<void>.delayed(const Duration(milliseconds: 550));
                          if (!mounted) {
                            return;
                          }
                          setState(() => _isSaving = false);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Privacy preferences saved successfully.')),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SamsUiTokens.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save Preferences'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final indexedChildren = children.asMap().entries;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        boxShadow: SamsUiTokens.cardShadow,
        border: Border.all(color: const Color(0xFFDDE4ED)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SamsUiTokens.textPrimary,
                    fontSize: 15.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          ...indexedChildren.map((entry) {
            final index = entry.key;
            final child = entry.value;

            return Column(
              children: [
                child,
                if (index != children.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 14, right: 14),
                    child: Divider(height: 1, thickness: 1, color: Color(0xFFE7EDF5)),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SamsUiTokens.textPrimary,
                    fontSize: 13.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
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
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            activeThumbColor: SamsUiTokens.primary,
            activeTrackColor: SamsUiTokens.primary.withValues(alpha: 0.35),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
