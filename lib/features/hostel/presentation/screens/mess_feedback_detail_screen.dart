import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class MessFeedbackDetailScreen extends StatefulWidget {
  const MessFeedbackDetailScreen({super.key});

  @override
  State<MessFeedbackDetailScreen> createState() =>
      _MessFeedbackDetailScreenState();
}

class _MessFeedbackDetailScreenState extends State<MessFeedbackDetailScreen> {
  String _mealType = 'Lunch';
  double _taste = 4;
  double _hygiene = 4;
  double _variety = 3;
  final TextEditingController _notesController = TextEditingController(
    text: 'Please add more grilled options and fresh fruit in dinner.',
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_notesController.text.trim().isEmpty) {
      ModernSnackbars.show(
        context,
        message: 'Please add a short comment before submitting feedback.',
        type: ModernSnackbarType.error,
      );
      return;
    }

    ModernSnackbars.show(
      context,
      message: 'Mess feedback submitted. Thanks for helping improve service.',
      type: ModernSnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final avg = ((_taste + _hygiene + _variety) / 3).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Mess Feedback'),
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
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2A063454),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SamsLocaleText(
                    'Today\'s food experience',
                    style: TextStyle(
                      color: Color(0xFFD8EBFB),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SamsLocaleText(
                    'Current average rating: $avg / 5.0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _FeedbackCard(
              title: 'Feedback form',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SamsLocaleText(
                    'Meal type',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Breakfast', 'Lunch', 'Dinner']
                        .map(
                          (meal) => ChoiceChip(
                            label: SamsLocaleText(meal),
                            selected: _mealType == meal,
                            selectedColor: SamsUiTokens.primary.withValues(
                              alpha: 0.14,
                            ),
                            side: BorderSide(
                              color: _mealType == meal
                                  ? SamsUiTokens.primary.withValues(alpha: 0.32)
                                  : const Color(0xFFDDE5EE),
                            ),
                            labelStyle: TextStyle(
                              color: _mealType == meal
                                  ? SamsUiTokens.primary
                                  : SamsUiTokens.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                            onSelected: (_) => setState(() => _mealType = meal),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 10),
                  _RatingSlider(
                    label: 'Taste',
                    value: _taste,
                    onChanged: (value) => setState(() => _taste = value),
                  ),
                  _RatingSlider(
                    label: 'Hygiene',
                    value: _hygiene,
                    onChanged: (value) => setState(() => _hygiene = value),
                  ),
                  _RatingSlider(
                    label: 'Variety',
                    value: _variety,
                    onChanged: (value) => setState(() => _variety = value),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: context.tr('Comments'),
                      hintText: context.tr('Share what can be improved...'),
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _FeedbackCard(
              title: 'Recent submissions',
              child: Column(
                children: [
                  _RecentFeedbackRow(
                    date: '14 Apr 2026',
                    meal: 'Dinner',
                    score: '4.2/5',
                    note: 'Good quality, but dessert options were limited.',
                  ),
                  Divider(height: 16),
                  _RecentFeedbackRow(
                    date: '13 Apr 2026',
                    meal: 'Lunch',
                    score: '3.9/5',
                    note: 'Please reduce oil in rice dishes.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SamsTapScale(
              child: ElevatedButton.icon(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamsUiTokens.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(SamsUiTokens.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.rate_review_rounded),
                label: const SamsLocaleText('Submit mess feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.title, required this.child});

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

class _RatingSlider extends StatelessWidget {
  const _RatingSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SamsLocaleText(
                label,
                style: const TextStyle(
                  color: SamsUiTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              SamsLocaleText(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  color: SamsUiTokens.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 8,
            activeColor: SamsUiTokens.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _RecentFeedbackRow extends StatelessWidget {
  const _RecentFeedbackRow({
    required this.date,
    required this.meal,
    required this.score,
    required this.note,
  });

  final String date;
  final String meal;
  final String score;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: SamsUiTokens.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.restaurant_menu_rounded,
            size: 17,
            color: SamsUiTokens.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SamsLocaleText(
                '$meal • $date',
                style: const TextStyle(
                  color: SamsUiTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              SamsLocaleText(
                note,
                style: const TextStyle(
                  color: SamsUiTokens.textSecondary,
                  fontSize: 12.4,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SamsLocaleText(
          score,
          style: const TextStyle(
            color: SamsUiTokens.primary,
            fontWeight: FontWeight.w800,
            fontSize: 12.8,
          ),
        ),
      ],
    );
  }
}
