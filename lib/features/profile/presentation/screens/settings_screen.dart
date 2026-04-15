import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/theme/theme_bloc.dart';
import '../../../../shared/bloc/locale_bloc.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showProfilePhoto = true;
  bool _showContactInfo = false;
  bool _allowDataSharing = false;
  bool _allowAnalytics = true;
  bool _pushAlerts = true;
  bool _emailUpdates = false;
  bool _assignmentReminders = true;
  bool _quietHours = false;

  void _onDarkModeChanged(bool value) {
    context.read<ThemeBloc>().toggleDarkMode(value);
    ModernSnackbars.show(
      context,
      message: value ? 'Dark Mode enabled.' : 'Light Mode enabled.',
      type: ModernSnackbarType.success,
    );
  }

  void _onLanguageChanged(String? value) {
    if (value == null) {
      return;
    }

    final selectedLocale = value == 'Arabic'
        ? const Locale('ar')
        : const Locale('en');

    if (selectedLocale == context.read<LocaleBloc>().state) {
      return;
    }

    context.read<LocaleBloc>().setLocale(selectedLocale);
    ModernSnackbars.show(
      context,
      message: 'Language switched to $value.',
      type: ModernSnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select(
      (ThemeBloc bloc) => bloc.state.isDarkMode,
    );
    final selectedLanguage = context.select((LocaleBloc bloc) {
      return bloc.state.languageCode == 'ar' ? 'Arabic' : 'English';
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Settings'),
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 28),
          children: [
            const _SettingsHeaderBanner(),
            const SizedBox(height: 14),
            _SettingsSection(
              title: 'Appearance',
              subtitle: 'Look and feel of your SAMS app experience.',
              icon: Icons.palette_outlined,
              iconColor: Color(0xFF0A4D78),
              children: [
                _SettingSwitchTile(
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark app themes.',
                  value: isDarkMode,
                  onChanged: _onDarkModeChanged,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: 'Language',
              subtitle: 'Choose your preferred app language.',
              icon: Icons.language_rounded,
              iconColor: Color(0xFF105F92),
              children: [
                _SettingDropdownTile(
                  title: 'App Language',
                  subtitle:
                      'Choose the display language for the app interface.',
                  value: selectedLanguage,
                  options: const ['English', 'Arabic'],
                  onChanged: _onLanguageChanged,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: 'Notifications',
              subtitle: 'Control alerts and update reminders.',
              icon: Icons.notifications_active_outlined,
              iconColor: Color(0xFF0E5C8C),
              children: [
                _SettingSwitchTile(
                  title: 'Push alerts',
                  subtitle:
                      'Receive instant notices for attendance and announcements.',
                  value: _pushAlerts,
                  onChanged: (value) => setState(() => _pushAlerts = value),
                ),
                _SettingSwitchTile(
                  title: 'Email updates',
                  subtitle:
                      'Receive periodic summaries and account updates by email.',
                  value: _emailUpdates,
                  onChanged: (value) => setState(() => _emailUpdates = value),
                ),
                _SettingSwitchTile(
                  title: 'Assignment reminders',
                  subtitle:
                      'Get reminders before deadlines and upcoming class tasks.',
                  value: _assignmentReminders,
                  onChanged: (value) =>
                      setState(() => _assignmentReminders = value),
                ),
                _SettingSwitchTile(
                  title: 'Quiet hours',
                  subtitle:
                      'Pause non-critical notifications during study/sleep time.',
                  value: _quietHours,
                  onChanged: (value) => setState(() => _quietHours = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: 'Privacy & Security',
              subtitle: 'Manage visibility, sharing, and data preferences.',
              icon: Icons.privacy_tip_outlined,
              iconColor: SamsUiTokens.primary,
              children: [
                _SettingSwitchTile(
                  title: 'Show profile photo to classmates',
                  subtitle:
                      'Controls visibility of your avatar in student directory.',
                  value: _showProfilePhoto,
                  onChanged: (value) =>
                      setState(() => _showProfilePhoto = value),
                ),
                _SettingSwitchTile(
                  title: 'Show contact information',
                  subtitle:
                      'Allow classmates to see your registered contact details.',
                  value: _showContactInfo,
                  onChanged: (value) =>
                      setState(() => _showContactInfo = value),
                ),
                _SettingSwitchTile(
                  title: 'Share data with campus services',
                  subtitle:
                      'Used to personalize student features and recommendations.',
                  value: _allowDataSharing,
                  onChanged: (value) =>
                      setState(() => _allowDataSharing = value),
                ),
                _SettingSwitchTile(
                  title: 'Allow anonymous analytics',
                  subtitle:
                      'Help improve the SAMS app experience and performance.',
                  value: _allowAnalytics,
                  onChanged: (value) => setState(() => _allowAnalytics = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingsSection(
              title: 'About App',
              subtitle: 'Version info, legal pages, and app details.',
              icon: Icons.info_outline_rounded,
              iconColor: Color(0xFF0A4A77),
              children: [
                _AboutActionTile(
                  title: 'App version',
                  subtitle: 'SAMS Student Portal • v1.0.0',
                  icon: Icons.verified_rounded,
                  onTap: () => _showInfo('You are on the latest version.'),
                ),
                _AboutActionTile(
                  title: 'Terms & Conditions',
                  subtitle: 'Review student platform terms and usage policy.',
                  icon: Icons.description_outlined,
                  onTap: () => _showInfo('Terms page will be connected soon.'),
                ),
                _AboutActionTile(
                  title: 'Privacy policy',
                  subtitle: 'See how your data is handled and protected.',
                  icon: Icons.shield_outlined,
                  onTap: () =>
                      _showInfo('Privacy policy page will be connected soon.'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(String message) {
    ModernSnackbars.show(
      context,
      message: message,
      type: ModernSnackbarType.info,
    );
  }
}

class _SettingsHeaderBanner extends StatelessWidget {
  const _SettingsHeaderBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063454), Color(0xFF0A4D78)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF063454).withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BannerIcon(),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Personalize appearance, language, notifications and account security in one place.',
                  style: TextStyle(
                    color: Color(0xFFE1ECF7),
                    fontSize: 12.7,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerIcon extends StatelessWidget {
  const _BannerIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: const Icon(
        Icons.settings_suggest_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final indexedChildren = children.asMap().entries;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        boxShadow: SamsUiTokens.cardShadow,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 15.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.1,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
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
                    child: Divider(height: 1, thickness: 1),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  const _SettingSwitchTile({
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
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 13.9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.1,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _PremiumSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingDropdownTile extends StatelessWidget {
  const _SettingDropdownTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 13.9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.1,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.34),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                borderRadius: BorderRadius.circular(10),
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 13.2,
                  fontWeight: FontWeight.w700,
                ),
                dropdownColor: colorScheme.surfaceContainerHighest,
                iconEnabledColor: colorScheme.primary,
                onChanged: onChanged,
                items: options
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutActionTile extends StatelessWidget {
  const _AboutActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SamsPressable(
      onTap: onTap,
      enableLift: false,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, size: 18, color: colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 13.9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.1,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumSwitch extends StatelessWidget {
  const _PremiumSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Transform.scale(
      scale: 0.93,
      child: Switch.adaptive(
        value: value,
        activeThumbColor: colorScheme.onPrimary,
        activeTrackColor: colorScheme.primary.withValues(alpha: 0.45),
        inactiveThumbColor: colorScheme.onSurfaceVariant,
        inactiveTrackColor: colorScheme.outlineVariant,
        onChanged: onChanged,
      ),
    );
  }
}
