import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/bloc/student_bloc.dart';
import '../../data/repositories/fake_profile_repository.dart';
import '../bloc/profile_bloc.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../../shared/widgets/sams_state_views.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(repository: FakeProfileRepository())..add(const ProfileRequested()),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading || state.status == ProfileStatus.initial) {
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
              appBar: AppBar(
                title: const Text('Profile'),
                centerTitle: true,
              ),
              body: SamsErrorState(
                title: 'Couldn\'t load profile',
                message: state.errorMessage ?? 'Failed to load profile. Please try again.',
                retryLabel: 'Retry',
                onRetry: () => context.read<ProfileBloc>().add(const ProfileRequested()),
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
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white,
                boxShadow: SamsUiTokens.cardShadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 102,
                    height: 102,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: SamsUiTokens.primary.withValues(alpha: 0.9), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEF5),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.person, color: SamsUiTokens.primary, size: 46),
                    ),
                  ),
                  const SizedBox(height: 14),
                  BlocBuilder<StudentBloc, StudentState>(
                    builder: (context, studentState) {
                      final name = studentState is StudentLoaded
                          ? studentState.student.name
                          : overview.name;
                      final id = studentState is StudentLoaded
                          ? studentState.student.id
                          : overview.studentId;

                      return Column(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: $id',
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...options.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProfileOptionRow(
                  title: item.title,
                  subtitle: item.subtitle,
                  icon: item.icon,
                  onTap: () {
                    context.pushNamed(item.routeName);
                  },
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
  const _ProfileOptionRow({required this.title, required this.subtitle, required this.icon, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
      child: SamsPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: SamsUiTokens.cardShadow,
            border: Border.all(color: const Color(0xFFDDE4ED)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                    width: 34,
                    height: 34,
                  decoration: BoxDecoration(
                    color: SamsUiTokens.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                  ),
                    child: Icon(icon, color: SamsUiTokens.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                            fontSize: 11.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
