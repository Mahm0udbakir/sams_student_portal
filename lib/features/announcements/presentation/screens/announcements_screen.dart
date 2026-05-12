import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/announcement_bloc.dart';
import '../../repositories/announcement_repository.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../../shared/widgets/sams_state_views.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key, this.showCreateAction = false});

  final bool showCreateAction;

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late final AnnouncementBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = AnnouncementBloc(repository: AnnouncementRepository())
      ..add(const AnnouncementRequested());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _refreshAnnouncements() async {
    _bloc.add(const AnnouncementRefreshRequested());

    try {
      await _bloc.stream
          .firstWhere((state) => state.status != AnnouncementStatus.loading)
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
        builder: (context, state) {
          if (state.status == AnnouncementStatus.loading ||
              state.status == AnnouncementStatus.initial) {
            return const Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              appBar: SamsAppBar(title: 'Announcements'),
              body: SamsLoadingView(
                title: 'Loading announcements',
                message: 'Fetching latest announcements and attachments...',
              ),
            );
          }

          if (state.status == AnnouncementStatus.requiresSignIn) {
            return _AnnouncementsSignInRequiredView(
              message:
                  state.errorMessage ??
                  'Authentication is required to load announcements.',
              isSigningIn: state.isSigningIn,
              onSignIn: () => context.read<AnnouncementBloc>().add(
                const AnnouncementAnonymousSignInRequested(),
              ),
              onRetry: _refreshAnnouncements,
            );
          }

          if (state.status == AnnouncementStatus.failure) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const SamsAppBar(title: 'Announcements'),
              body: SamsErrorState(
                title: 'Couldn\'t load announcements',
                message:
                    state.errorMessage ??
                    'Failed to load announcements. Please try again.',
                retryLabel: 'Retry',
                icon: Icons.campaign_outlined,
                onRetry: _refreshAnnouncements,
              ),
            );
          }

          final announcements = state.announcements;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: const SamsAppBar(title: 'Announcements'),
            body: Stack(
              children: [
                const Positioned(
                  top: -90,
                  right: -72,
                  child: _AnnouncementsBackdropBubble(),
                ),
                const Positioned(
                  bottom: 98,
                  left: -78,
                  child: _AnnouncementsBackdropBubble(),
                ),
                RefreshIndicator(
                  onRefresh: _refreshAnnouncements,
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  color: SamsUiTokens.primary,
                  child: SafeArea(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: SamsUiTokens.pageInsets(
                        context,
                        top: 14,
                        bottom: 30,
                      ),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: SamsUiTokens.contentMaxWidth,
                            ),
                            child: announcements.isEmpty
                                ? _AnnouncementsEmptyState(
                                    onRefresh: _refreshAnnouncements,
                                  )
                                : _AnnouncementsList(
                                    announcements: announcements,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: widget.showCreateAction
                ? FloatingActionButton.extended(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Announcement creation is disabled for students.',
                          ),
                        ),
                      );
                    },
                    backgroundColor: SamsUiTokens.primary,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Announcement'),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _AnnouncementsEmptyState extends StatelessWidget {
  const _AnnouncementsEmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmptyStateWidget(
          icon: Icons.campaign_rounded,
          title: 'No announcements yet',
          subtitle:
              'You are all caught up. New updates from SAMS will appear here.',
          actionLabel: null,
          onAction: null,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const SamsLocaleText('Refresh Announcements'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SamsUiTokens.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementsSignInRequiredView extends StatelessWidget {
  const _AnnouncementsSignInRequiredView({
    required this.message,
    required this.isSigningIn,
    required this.onSignIn,
    required this.onRetry,
  });

  final String message;
  final bool isSigningIn;
  final VoidCallback onSignIn;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Announcements'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.lock_person_rounded,
                    size: 34,
                    color: SamsUiTokens.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Authentication required',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: isSigningIn ? null : onSignIn,
                    icon: isSigningIn
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_alt_1_rounded),
                    label: Text(
                      isSigningIn ? 'Signing in...' : 'Sign in Anonymously',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: isSigningIn ? null : onRetry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementsList extends StatelessWidget {
  const _AnnouncementsList({required this.announcements});

  final List<AnnouncementItem> announcements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnnouncementsHero(totalCount: announcements.length),
        const SizedBox(height: 12),
        ...announcements.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == announcements.length - 1 ? 0 : 10,
            ),
            child: _AnnouncementListItem(item: item),
          );
        }),
      ],
    );
  }
}

class _AnnouncementsHero extends StatelessWidget {
  const _AnnouncementsHero({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063454), Color(0xFF0A4D78)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF063454).withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.campaign_rounded, color: Color(0xFFD8EAFB), size: 20),
              SizedBox(width: 8),
              SamsLocaleText(
                'Announcements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const SamsLocaleText(
            'Latest updates for doctors and students',
            style: TextStyle(
              color: Color(0xFFE1ECF8),
              fontSize: 12.6,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  '${context.tr('Total announcements')}: $totalCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w700,
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

class _AnnouncementListItem extends StatelessWidget {
  const _AnnouncementListItem({required this.item});

  final AnnouncementItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateLabel = _formatAnnouncementDate(
      context,
      item.createdAt.toLocal(),
    );

    return SamsPressable(
      onTap: () {},
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.8),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: SamsUiTokens.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: SamsUiTokens.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14.2,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.message,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.34,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MetaChip(icon: Icons.schedule_rounded, label: dateLabel),
                _MetaChip(
                  icon: Icons.attach_file_rounded,
                  label:
                      '${item.attachments.length} ${context.tr('Attachments')}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.82),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: SamsUiTokens.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 11.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsBackdropBubble extends StatelessWidget {
  const _AnnouncementsBackdropBubble();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 210,
        height: 210,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              SamsUiTokens.primary.withValues(alpha: 0.1),
              SamsUiTokens.primary.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatAnnouncementDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).languageCode;
  const enMonths = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const arMonths = <String>[
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  final month = locale == 'ar'
      ? arMonths[date.month - 1]
      : enMonths[date.month - 1];

  return locale == 'ar'
      ? '${date.day} $month ${date.year}'
      : '$month ${date.day}, ${date.year}';
}
