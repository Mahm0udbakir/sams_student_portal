import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../shared/bloc/student_bloc.dart';
import '../../data/repositories/fake_profile_repository.dart';
import '../bloc/profile_bloc.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
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
                child: Text(
                  'Confirm switch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Text(
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
                child: const Text('Cancel'),
              ),
            ),
            SamsTapScale(
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamsUiTokens.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Switch'),
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title activated (demo).')));

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
        builder: (context, state) {
          if (state.status == ProfileStatus.loading ||
              state.status == ProfileStatus.initial) {
            return const Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              body: SamsLoadingView(
                title: 'Loading profile',
                message: 'Fetching your account details and settings...',
              ),
            );
          }

          if (state.status == ProfileStatus.failure || state.overview == null) {
            return Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              appBar: AppBar(title: const Text('Profile'), centerTitle: true),
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

          final options = [
            (
              title: 'Session',
              subtitle: overview.sessionSubtitle,
              icon: Icons.calendar_month_rounded,
              routeName: AppRouteNames.session,
            ),
            (
              title: 'Change Password',
              subtitle: 'Last changed 2 months ago',
              icon: Icons.lock_reset_rounded,
              routeName: AppRouteNames.changePassword,
            ),
            (
              title: 'Privacy',
              subtitle: 'Manage app permissions and data visibility',
              icon: Icons.privacy_tip_rounded,
              routeName: AppRouteNames.privacy,
            ),
            (
              title: 'Switch to SAMS Bus',
              subtitle: 'Track route, stops and live bus status',
              icon: Icons.directions_bus_rounded,
              routeName: AppRouteNames.bus,
            ),
            (
              title: 'Switch to SAMS Hostel',
              subtitle: 'Access gate pass, allotment and receipts',
              icon: Icons.apartment_rounded,
              routeName: AppRouteNames.hostel,
            ),
          ];

          return Scaffold(
            backgroundColor: SamsUiTokens.scaffoldBackground,
            appBar: AppBar(title: const Text('Profile'), centerTitle: true),
            body: SafeArea(
              child: ListView(
                padding: SamsUiTokens.pageInsets(context, top: 16, bottom: 24),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.white,
                      boxShadow: SamsUiTokens.cardShadow,
                      border: Border.all(color: const Color(0xFFDCE4EE)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 124,
                          height: 124,
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
                              color: const Color(0xFFEAF1F8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.9),
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
                                studentState.studentId ?? overview.studentId;

                            return Column(
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: SamsUiTokens.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'ID: $id',
                                  style: const TextStyle(
                                    color: SamsUiTokens.textSecondary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        SamsUiTokens.radiusLg,
                      ),
                      boxShadow: SamsUiTokens.cardShadow,
                      border: Border.all(color: const Color(0xFFDDE4ED)),
                    ),
                    child: Column(
                      children: options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return _ProfileOptionRow(
                          title: item.title,
                          subtitle: item.subtitle,
                          icon: item.icon,
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
                    child: Text(
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
          );
        },
      ),
    );
  }
}

class _ProfileOptionRow extends StatelessWidget {
  const _ProfileOptionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.showDivider,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return SamsPressable(
      onTap: onTap,
      enableLift: false,
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                        Text(
                          title,
                          style: const TextStyle(
                            color: SamsUiTokens.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: SamsUiTokens.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.4,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
            if (showDivider)
              const Padding(
                padding: EdgeInsets.only(left: 68),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE7EDF5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
