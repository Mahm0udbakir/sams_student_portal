import 'package:flutter/material.dart';

import 'settings_screen.dart';

/// Legacy compatibility screen.
///
/// Privacy controls were moved to `SettingsScreen` in Phase 9.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}
