import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../shared/bloc/student_bloc.dart';
import '../../data/repositories/fake_profile_repository.dart';
import '../bloc/profile_bloc.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../../shared/widgets/sams_state_views.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<bool> _showSwitchConfirmationDialog(
    BuildContext context, {
    required String destination,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: SamsUiTokens.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: SamsUiTokens.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: SamsLocaleText(
                  'Confirm switch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: SamsLocaleText(
            'Switch to $destination in demo mode?',
            style: const TextStyle(
              color: SamsUiTokens.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            SamsTapScale(
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const SamsLocaleText('Cancel'),
              ),
            ),
            SamsTapScale(
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamsUiTokens.primary,
                  foregroundColor: Colors.white,
                ),
                child: const SamsLocaleText('Switch'),
              ),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  void _onProfileOptionTap(
    BuildContext context, {
    required String title,
    required String routeName,
  }) async {
    final isSwitchTarget =
        routeName == AppRouteNames.bus || routeName == AppRouteNames.hostel;

    if (!isSwitchTarget) {
      context.pushNamed(routeName);
      return;
    }

    final confirmed = await _showSwitchConfirmationDialog(
      context,
      destination: title.replaceFirst('Switch to ', ''),
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    ModernSnackbars.show(
      context,
      message: '$title activated (demo).',
      type: ModernSnackbarType.success,
    );

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!context.mounted) {
      return;
    }
    context.pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfileBloc(repository: FakeProfileRepository())
            ..add(const ProfileRequested()),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.overview != current.overview ||
              previous.errorMessage != current.errorMessage;
        },
        builder: (context, state) {
          final colorScheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          if (state.status == ProfileStatus.loading ||
              state.status == ProfileStatus.initial) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SamsLoadingView(
                title: 'Loading profile',
                message: 'Fetching your account details and settings...',
              ),
            );
          }

          if (state.status == ProfileStatus.failure || state.overview == null) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const SamsAppBar(title: 'Profile'),
              body: SamsErrorState(
                title: 'Couldn\'t load profile',
                message:
                    state.errorMessage ??
                    'Failed to load profile. Please try again.',
                retryLabel: 'Retry',
                onRetry: () =>
                    context.read<ProfileBloc>().add(const ProfileRequested()),
              ),
            );
          }

          final overview = state.overview!;
          final isDesktop = SamsUiTokens.isDesktopWidth(context);

          final options = [
            (
              title: 'Settings',
              subtitle: 'Appearance, language, notifications and security',
              icon: Icons.settings_rounded,
              routeName: AppRouteNames.settings,
              translateTitle: true,
            ),
            (
              title: 'Session',
              subtitle: overview.sessionSubtitle,
              icon: Icons.calendar_month_rounded,
              routeName: AppRouteNames.session,
              translateTitle: true,
            ),
            (
              title: 'Change Password',
              subtitle: 'Last changed 2 months ago',
              icon: Icons.lock_reset_rounded,
              routeName: AppRouteNames.changePassword,
              translateTitle: true,
            ),
            (
              title: 'Bus',
              subtitle: 'Track route, stops and live bus status',
              icon: Icons.directions_bus_rounded,
              routeName: AppRouteNames.bus,
              translateTitle: true,
            ),
            (
              title: 'Hostel',
              subtitle: 'Access gate pass, allotment and receipts',
              icon: Icons.apartment_rounded,
              routeName: AppRouteNames.hostel,
              translateTitle: true,
            ),
          ];

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: const SamsAppBar(title: 'Profile'),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: SamsUiTokens.contentMaxWidth,
                  ),
                  child: ListView(
                    padding: SamsUiTokens.pageInsets(
                      context,
                      top: 16,
                      bottom: 24,
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: colorScheme.surfaceContainerHighest,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.34 : 0.12,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.82,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: isDesktop ? 136 : 124,
                              height: isDesktop ? 136 : 124,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    SamsUiTokens.primary.withValues(alpha: 0.9),
                                    const Color(0xFF0A5B8D),
                                  ],
                                ),
                                border: Border.all(
                                  color: SamsUiTokens.primary.withValues(
                                    alpha: 0.22,
                                  ),
                                  width: 2.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: SamsUiTokens.primary.withValues(
                                      alpha: 0.20,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.62),
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: SamsUiTokens.primary,
                                  size: 58,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<StudentBloc, StudentState>(
                              buildWhen: (previous, current) {
                                return previous.studentName !=
                                        current.studentName ||
                                    previous.studentId != current.studentId ||
                                    previous.status != current.status;
                              },
                              builder: (context, studentState) {
                                final name =
                                    studentState.studentName ?? overview.name;
                                final id =
                                    studentState.studentId ??
                                    overview.studentId;

                                return Column(
                                  children: [
                                    SamsLocaleText(
                                      name,
                                      style: TextStyle(
                                        color: SamsUiTokens.textPrimary,
                                        fontSize: isDesktop ? 30 : 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),
                                    SamsLocaleText(
                                      'ID: $id',
                                      style: TextStyle(
                                        color: SamsUiTokens.textSecondary,
                                        fontSize: isDesktop ? 14 : 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const SamsLocaleText(
                                      'SAMS Student Portal',
                                      style: TextStyle(
                                        color: SamsUiTokens.primary,
                                        fontSize: 12.2,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            SamsUiTokens.radiusLg,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.34 : 0.12,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.82,
                            ),
                          ),
                        ),
                        child: Column(
                          children: options.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;

                            return _ProfileOptionRow(
                              key: ValueKey(item.routeName),
                              title: item.title,
                              subtitle: item.subtitle,
                              icon: item.icon,
                              translateTitle: item.translateTitle,
                              showDivider: index != options.length - 1,
                              onTap: () {
                                _onProfileOptionTap(
                                  context,
                                  title: item.title,
                                  routeName: item.routeName,
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SamsLocaleText(
                          'SAMS Student App • Version 1.0',
                          style: TextStyle(
                            color: SamsUiTokens.textSecondary.withValues(
                              alpha: 0.85,
                            ),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileOptionRow extends StatelessWidget {
  const _ProfileOptionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.translateTitle = true,
    required this.onTap,
    required this.showDivider,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool translateTitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SamsPressable(
      onTap: onTap,
      enableLift: false,
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: SamsUiTokens.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(icon, color: SamsUiTokens.primary, size: 21),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (translateTitle)
                          SamsLocaleText(
                            title,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          )
                        else
                          Text(
                            title,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        const SizedBox(height: 3),
                        SamsLocaleText(
                          subtitle,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.4,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            if (showDivider)
              Padding(
                padding: EdgeInsets.only(left: 68),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
