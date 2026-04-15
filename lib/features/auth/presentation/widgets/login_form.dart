import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: context.tr('Email')),
          ),
          const SizedBox(height: 12),
          TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: context.tr('Password')),
          ),
        ],
      ),
    );
  }
}
