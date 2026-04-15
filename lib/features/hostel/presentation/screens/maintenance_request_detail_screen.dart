import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class MaintenanceRequestDetailScreen extends StatefulWidget {
  const MaintenanceRequestDetailScreen({super.key});

  @override
  State<MaintenanceRequestDetailScreen> createState() =>
      _MaintenanceRequestDetailScreenState();
}

class _MaintenanceRequestDetailScreenState
    extends State<MaintenanceRequestDetailScreen> {
  final TextEditingController _locationController = TextEditingController(
    text: 'Hostel Building B - Room 214',
  );
  final TextEditingController _issueController = TextEditingController(
    text: 'AC is running but not cooling since yesterday night.',
  );

  String _category = 'Electrical';
  String _priority = 'Medium';
  String _visitSlot = 'Today (6:00 PM - 8:00 PM)';

  @override
  void dispose() {
    _locationController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_locationController.text.trim().isEmpty ||
        _issueController.text.trim().isEmpty) {
      ModernSnackbars.show(
        context,
        message: 'Please complete location and issue description.',
        type: ModernSnackbarType.error,
      );
      return;
    }

    ModernSnackbars.show(
      context,
      message: 'Maintenance request submitted. Team will reach out shortly.',
      type: ModernSnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Maintenance Request'),
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 24),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF063454), Color(0xFF0A4A75)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2E063454),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.support_agent_rounded, color: Color(0xFFD7E9FA)),
                  SizedBox(width: 10),
                  Expanded(
                    child: SamsLocaleText(
                      'Average response time: 2.5 hours • Emergency cases are prioritized.',
                      style: TextStyle(
                        color: Color(0xFFD7E9FA),
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _CardSection(
              title: 'Request form',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: context.tr('Category'),
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Electrical',
                        child: SamsLocaleText('Electrical'),
                      ),
                      DropdownMenuItem(
                        value: 'Plumbing',
                        child: SamsLocaleText('Plumbing'),
                      ),
                      DropdownMenuItem(
                        value: 'Furniture',
                        child: SamsLocaleText('Furniture'),
                      ),
                      DropdownMenuItem(
                        value: 'Internet',
                        child: SamsLocaleText('Internet / Network'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: context.tr('Location'),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SamsLocaleText(
                    'Priority',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Low', 'Medium', 'High']
                        .map(
                          (level) => ChoiceChip(
                            label: SamsLocaleText(level),
                            selected: _priority == level,
                            selectedColor: SamsUiTokens.primary.withValues(
                              alpha: 0.14,
                            ),
                            side: BorderSide(
                              color: _priority == level
                                  ? SamsUiTokens.primary.withValues(alpha: 0.32)
                                  : const Color(0xFFDDE5EE),
                            ),
                            labelStyle: TextStyle(
                              color: _priority == level
                                  ? SamsUiTokens.primary
                                  : SamsUiTokens.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                            onSelected: (_) =>
                                setState(() => _priority = level),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _visitSlot,
                    decoration: InputDecoration(
                      labelText: context.tr('Preferred visit slot'),
                      prefixIcon: Icon(Icons.schedule_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Today (6:00 PM - 8:00 PM)',
                        child: SamsLocaleText('Today (6:00 PM - 8:00 PM)'),
                      ),
                      DropdownMenuItem(
                        value: 'Tomorrow (8:00 AM - 10:00 AM)',
                        child: SamsLocaleText('Tomorrow (8:00 AM - 10:00 AM)'),
                      ),
                      DropdownMenuItem(
                        value: 'Tomorrow (4:00 PM - 6:00 PM)',
                        child: SamsLocaleText('Tomorrow (4:00 PM - 6:00 PM)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _visitSlot = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _issueController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: context.tr('Issue description'),
                      hintText: context.tr(
                        'Describe the issue and when it started...',
                      ),
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.build_circle_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _CardSection(
              title: 'Open requests',
              child: Column(
                children: [
                  _OpenTicketRow(
                    code: 'MR-4521',
                    issue: 'Bathroom leakage - Room B118',
                    status: 'In Progress',
                    eta: 'ETA: Today 7:30 PM',
                  ),
                  Divider(height: 16),
                  _OpenTicketRow(
                    code: 'MR-4498',
                    issue: 'Wardrobe door alignment - Room B214',
                    status: 'Scheduled',
                    eta: 'ETA: Tomorrow 9:00 AM',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SamsTapScale(
              child: ElevatedButton.icon(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamsUiTokens.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(SamsUiTokens.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.construction_rounded),
                label: const SamsLocaleText('Submit maintenance request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SamsPressable(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDE5EE)),
          boxShadow: SamsUiTokens.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SamsLocaleText(
              title,
              style: const TextStyle(
                color: SamsUiTokens.textPrimary,
                fontSize: 15.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _OpenTicketRow extends StatelessWidget {
  const _OpenTicketRow({
    required this.code,
    required this.issue,
    required this.status,
    required this.eta,
  });

  final String code;
  final String issue;
  final String status;
  final String eta;

  @override
  Widget build(BuildContext context) {
    final isInProgress = status == 'In Progress';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: SamsUiTokens.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.handyman_rounded,
            size: 18,
            color: SamsUiTokens.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SamsLocaleText(
                '$code • $issue',
                style: const TextStyle(
                  color: SamsUiTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              SamsLocaleText(
                eta,
                style: const TextStyle(
                  color: SamsUiTokens.textSecondary,
                  fontSize: 12.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: isInProgress
                ? const Color(0xFFEAF3FF)
                : const Color(0xFFFFF6E9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: SamsLocaleText(
            status,
            style: TextStyle(
              color: isInProgress
                  ? SamsUiTokens.primary
                  : const Color(0xFFB7791F),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
