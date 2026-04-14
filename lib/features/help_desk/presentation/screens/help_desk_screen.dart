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
    await Future<void>.delayed(const Duration(milliseconds: 180));
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
              backgroundColor: SamsUiTokens.scaffoldBackground,
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
            backgroundColor: SamsUiTokens.scaffoldBackground,
            appBar: const SamsAppBar(title: 'Help Desk'),
            body: RefreshIndicator(
              onRefresh: () => _refreshHelpDesk(context),
              color: SamsUiTokens.primary,
              child: SafeArea(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: SamsUiTokens.pageInsets(
                    context,
                    top: 14,
                    bottom: 16,
                  ),
                  children: [
                    Text(
                      'Aug 30, Saturday',
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Divider(height: 1, color: Color(0xFFD8DEE7)),
                    const SizedBox(height: 12),
                    if (complaints.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 72),
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
                          key: ValueKey('${item.department}-${item.message}'),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SamsPressable(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(
                              SamsUiTokens.radiusLg,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  SamsUiTokens.radiusLg,
                                ),
                                boxShadow: SamsUiTokens.cardShadow,
                                border: Border.all(
                                  color: const Color(0xFFDCE3EC),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.department,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFF111827),
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.message,
                                    style: const TextStyle(
                                      color: Color(0xFF4B5563),
                                      fontSize: 13.2,
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Contact',
                                    style: TextStyle(
                                      color: SamsUiTokens.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.contact,
                                    style: const TextStyle(
                                      color: SamsUiTokens.textSecondary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.8,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SamsTapScale(
                        child: ElevatedButton(
                          onPressed: () async {
                            final submittedComplaint = await context
                                .pushNamed<ComplaintEntity>(
                                  AppRouteNames.helpDeskRaise,
                                );

                            if (!context.mounted) {
                              return;
                            }

                            if (submittedComplaint != null) {
                              context.read<HelpDeskBloc>().add(
                                HelpDeskComplaintAdded(
                                  complaint: submittedComplaint,
                                ),
                              );
                              ModernSnackbars.show(
                                context,
                                message: 'Concern submitted successfully',
                                type: ModernSnackbarType.success,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _samsPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          child: const Text('Raise a complaint'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HelpDeskLoadingSkeleton extends StatelessWidget {
  const _HelpDeskLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamsUiTokens.scaffoldBackground,
      appBar: const SamsAppBar(title: 'Help Desk'),
      body: ListView(
        padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 16),
        children: [
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
                height: 116,
                borderRadius: BorderRadius.all(Radius.circular(18)),
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

            return Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              appBar: const SamsAppBar(title: 'Help Desk'),
              body: SafeArea(
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
                                      child: Text(
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            SamsUiTokens.radiusLg,
                          ),
                          boxShadow: SamsUiTokens.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Raise your Concern',
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDepartment,
                              decoration: InputDecoration(
                                labelText: 'Concerned Department',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: _departments
                                  .map(
                                    (department) => DropdownMenuItem<String>(
                                      value: department,
                                      child: Text(department),
                                    ),
                                  )
                                  .toList(),
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Estimated response: within 24 hours',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _concernController,
                              maxLines: 5,
                              maxLength: 500,
                              onChanged: isSubmitting
                                  ? null
                                  : (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Your Concern',
                                alignLabelWithHint: true,
                                hintText: 'Describe your issue here...',
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${_concernController.text.length}/500',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: SamsTapScale(
                          enabled: !isSubmitting,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    final department = _selectedDepartment;
                                    final concern = _concernController.text
                                        .trim();

                                    if (department == null || concern.isEmpty) {
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _samsPrimary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Submit'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
