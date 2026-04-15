import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../data/repositories/fake_help_desk_repository.dart';
import '../../domain/entities/complaint_entity.dart';
import '../bloc/help_desk_bloc.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../../../shared/widgets/sams_state_views.dart';

class HelpDeskScreen extends StatelessWidget {
  const HelpDeskScreen({super.key});

  static const Color _samsPrimary = SamsUiTokens.primary;

  Future<void> _refreshHelpDesk(BuildContext context) async {
    final bloc = context.read<HelpDeskBloc>();
    bloc.add(const HelpDeskRequested());
    try {
      await bloc.stream
          .firstWhere((state) => state.status != HelpDeskStatus.loading)
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  Future<void> _openRaiseConcern(BuildContext context) async {
    final submittedComplaint = await context.pushNamed<ComplaintEntity>(
      AppRouteNames.helpDeskRaise,
    );

    if (!context.mounted || submittedComplaint == null) {
      return;
    }

    context.read<HelpDeskBloc>().add(
      HelpDeskComplaintAdded(complaint: submittedComplaint),
    );
    ModernSnackbars.show(
      context,
      message: 'Concern submitted successfully',
      type: ModernSnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HelpDeskBloc(repository: FakeHelpDeskRepository())
            ..add(const HelpDeskRequested()),
      child: BlocBuilder<HelpDeskBloc, HelpDeskState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.complaints != current.complaints ||
              previous.errorMessage != current.errorMessage;
        },
        builder: (context, state) {
          if (state.status == HelpDeskStatus.loading ||
              state.status == HelpDeskStatus.initial) {
            return const _HelpDeskLoadingSkeleton();
          }

          if (state.status == HelpDeskStatus.failure) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const SamsAppBar(title: 'Help Desk'),
              body: SamsErrorState(
                title: 'Couldn\'t load help desk',
                message:
                    state.errorMessage ??
                    'Failed to load help desk requests. Please try again.',
                retryLabel: 'Retry',
                onRetry: () =>
                    context.read<HelpDeskBloc>().add(const HelpDeskRequested()),
              ),
            );
          }

          final complaints = state.complaints;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: const SamsAppBar(title: 'Help Desk'),
            body: Stack(
              children: [
                const Positioned(
                  top: -90,
                  right: -72,
                  child: _HelpDeskBackdropBubble(),
                ),
                const Positioned(
                  bottom: 100,
                  left: -82,
                  child: _HelpDeskBackdropBubble(),
                ),
                RefreshIndicator(
                  onRefresh: () => _refreshHelpDesk(context),
                  color: SamsUiTokens.primary,
                  child: SafeArea(
                    child: ListView(
                      key: const PageStorageKey<String>('helpDeskMainList'),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: SamsUiTokens.pageInsets(
                        context,
                        top: 14,
                        bottom: 18,
                      ),
                      children: [
                        _HelpDeskHeroCard(totalOpenRequests: complaints.length),
                        const SizedBox(height: 12),
                        if (complaints.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 72),
                            child: EmptyStateWidget(
                              icon: Icons.support_agent_rounded,
                              title: 'No complaints right now',
                              subtitle:
                                  'Great! You have no active concerns at the moment.',
                              actionLabel: 'Check Again',
                              onAction: () => context.read<HelpDeskBloc>().add(
                                const HelpDeskRequested(),
                              ),
                            ),
                          )
                        else
                          ...complaints.asMap().entries.map((entry) {
                            final item = entry.value;

                            return Padding(
                              key: ValueKey(
                                '${item.department}-${item.message}',
                              ),
                              padding: EdgeInsets.only(
                                bottom: entry.key == complaints.length - 1
                                    ? 0
                                    : 10,
                              ),
                              child: _ComplaintCard(item: item),
                            );
                          }),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SamsTapScale(
                            child: ElevatedButton.icon(
                              onPressed: () => _openRaiseConcern(context),
                              icon: const Icon(Icons.add_comment_rounded),
                              label: const SamsLocaleText('Raise a complaint'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _samsPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size.fromHeight(52),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HelpDeskHeroCard extends StatelessWidget {
  const _HelpDeskHeroCard({required this.totalOpenRequests});

  final int totalOpenRequests;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063454), Color(0xFF0A5F93)],
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
              Icon(Icons.support_agent_rounded, color: Color(0xFFD8EAFB)),
              SizedBox(width: 8),
              SamsLocaleText(
                'Help Desk',
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
            'Support and contact',
            style: TextStyle(
              color: Color(0xFFE1ECF8),
              fontSize: 12.6,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroPill(
                text: '${context.tr('Open requests')}: $totalOpenRequests',
              ),
              _HeroPill(
                text: context.tr('Estimated response: within 24 hours'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.item});

  final ComplaintEntity item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _accentForDepartment(item.department);

    return SamsPressable(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      enableLift: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.14),
              accent.withValues(alpha: 0.06),
            ],
          ),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.72),
          ),
          boxShadow: SamsUiTokens.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.campaign_rounded, color: accent, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SamsLocaleText(
                        item.department,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SamsLocaleText(
                        'Updated 2 mins ago',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.78,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.62),
                ),
              ),
              child: SamsLocaleText(
                item.message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12.7,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.perm_contact_calendar_rounded,
                  color: accent,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: SamsLocaleText(
                    item.contact,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12.1,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _accentForDepartment(String department) {
    final normalized = department.toLowerCase();
    if (normalized.contains('it')) {
      return const Color(0xFF4A78D3);
    }
    if (normalized.contains('transport')) {
      return const Color(0xFF0E8F54);
    }
    if (normalized.contains('library')) {
      return const Color(0xFFC17A1D);
    }
    if (normalized.contains('hostel')) {
      return const Color(0xFF7A4FD6);
    }
    return SamsUiTokens.primary;
  }
}

class _HelpDeskBackdropBubble extends StatelessWidget {
  const _HelpDeskBackdropBubble();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpDeskLoadingSkeleton extends StatelessWidget {
  const _HelpDeskLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Help Desk'),
      body: ListView(
        padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 16),
        children: [
          const ShimmerWidget(
            height: 96,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          const SizedBox(height: 10),
          const SamsLoadingView(
            title: 'Loading your concerns...',
            message: 'Fetching your latest complaints and help desk updates...',
          ),
          const SizedBox(height: 8),
          ...List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == 2 ? 0 : 10),
              child: const ShimmerWidget(
                height: 148,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RaiseConcernScreen extends StatefulWidget {
  const RaiseConcernScreen({super.key});

  @override
  State<RaiseConcernScreen> createState() => _RaiseConcernScreenState();
}

class _RaiseConcernScreenState extends State<RaiseConcernScreen> {
  static const Color _samsPrimary = SamsUiTokens.primary;
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _concernController = TextEditingController();
  String? _selectedDepartment;
  final _departments = const [
    'Transport Department',
    'Hostel Office',
    'Academic Cell',
    'Accounts Office',
    'IT Support',
  ];

  @override
  void dispose() {
    _departmentController.dispose();
    _concernController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HelpDeskBloc(repository: FakeHelpDeskRepository())
            ..add(const HelpDeskRequested()),
      child: BlocListener<HelpDeskBloc, HelpDeskState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus &&
            current.submissionStatus == HelpDeskSubmissionStatus.success,
        listener: (context, state) async {
          final message = state.submissionMessage;
          if (message == null || message.isEmpty) {
            return;
          }

          final department = _selectedDepartment;
          final concernText = _concernController.text.trim();
          final submittedComplaint = (department == null || concernText.isEmpty)
              ? null
              : ComplaintEntity(
                  department: department,
                  message: concernText,
                  contact: 'Help Desk Team\nExt. 101',
                );

          setState(() {
            _selectedDepartment = null;
            _departmentController.clear();
            _concernController.clear();
          });

          context.read<HelpDeskBloc>().add(
            const HelpDeskSubmissionNoticeCleared(),
          );

          await Future<void>.delayed(const Duration(milliseconds: 220));
          if (!context.mounted) {
            return;
          }
          context.pop(submittedComplaint);
        },
        child: BlocBuilder<HelpDeskBloc, HelpDeskState>(
          buildWhen: (previous, current) {
            return previous.submissionStatus != current.submissionStatus;
          },
          builder: (context, state) {
            final isSubmitting =
                state.submissionStatus == HelpDeskSubmissionStatus.submitting;
            final colorScheme = Theme.of(context).colorScheme;

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const SamsAppBar(title: 'Help Desk'),
              body: Stack(
                children: [
                  const Positioned(
                    top: -92,
                    right: -74,
                    child: _HelpDeskBackdropBubble(),
                  ),
                  const Positioned(
                    bottom: 120,
                    left: -86,
                    child: _HelpDeskBackdropBubble(),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: SamsUiTokens.pageInsets(
                        context,
                        top: 14,
                        bottom: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: isSubmitting
                                ? Container(
                                    key: const ValueKey('submitting-banner'),
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE9F1F9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFCADCED),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: SamsLocaleText(
                                            'Submitting your concern...',
                                            style: TextStyle(
                                              color: SamsUiTokens.textPrimary,
                                              fontSize: 12.8,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('submitting-banner-hidden'),
                                  ),
                          ),
                          const _RaiseConcernHeaderCard(),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  14,
                                  14,
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.72),
                                  ),
                                  boxShadow: SamsUiTokens.cardShadow,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SamsLocaleText(
                                      'Request form',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15.2,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedDepartment,
                                      decoration: InputDecoration(
                                        labelText: context.tr(
                                          'Concerned Department',
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.apartment_rounded,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      items: _departments
                                          .map(
                                            (department) =>
                                                DropdownMenuItem<String>(
                                                  value: department,
                                                  child: SamsLocaleText(
                                                    department,
                                                  ),
                                                ),
                                          )
                                          .toList(growable: false),
                                      onChanged: isSubmitting
                                          ? null
                                          : (value) {
                                              setState(() {
                                                _selectedDepartment = value;
                                                _departmentController.text =
                                                    value ?? '';
                                              });
                                            },
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _concernController,
                                      maxLines: 5,
                                      maxLength: 500,
                                      onChanged: isSubmitting
                                          ? null
                                          : (_) => setState(() {}),
                                      decoration: InputDecoration(
                                        labelText: context.tr('Your Concern'),
                                        alignLabelWithHint: true,
                                        hintText: context.tr(
                                          'Describe your issue here...',
                                        ),
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.only(bottom: 72),
                                          child: Icon(Icons.edit_note_rounded),
                                        ),
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: SamsLocaleText(
                                        '${_concernController.text.length}/500',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11.8,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: SamsTapScale(
                              enabled: !isSubmitting,
                              child: ElevatedButton.icon(
                                onPressed: isSubmitting
                                    ? null
                                    : () {
                                        final department = _selectedDepartment;
                                        final concern = _concernController.text
                                            .trim();

                                        if (department == null ||
                                            concern.isEmpty) {
                                          ModernSnackbars.show(
                                            context,
                                            message:
                                                'Please select department and enter your concern.',
                                            type: ModernSnackbarType.warning,
                                          );
                                          return;
                                        }

                                        context.read<HelpDeskBloc>().add(
                                          HelpDeskConcernSubmitted(
                                            department: department,
                                            concern: concern,
                                          ),
                                        );
                                      },
                                icon: isSubmitting
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.send_rounded),
                                label: SamsLocaleText(
                                  isSubmitting
                                      ? 'Submitting your concern...'
                                      : 'Submit',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _samsPrimary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize: const Size.fromHeight(52),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RaiseConcernHeaderCard extends StatelessWidget {
  const _RaiseConcernHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063454), Color(0xFF0A4D78)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF063454).withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_document, color: Color(0xFFD9EAFB), size: 19),
              SizedBox(width: 8),
              SamsLocaleText(
                'Raise your Concern',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          SamsLocaleText(
            'Estimated response: within 24 hours',
            style: TextStyle(
              color: Color(0xFFE1ECF8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
