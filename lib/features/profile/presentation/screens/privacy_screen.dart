import 'package:flutter/material.dart';

import 'privacy_policy_screen.dart';

/// Legacy compatibility screen.
///
/// Preserves backward compatibility for old privacy route names.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrivacyPolicyScreen();
  }
}
