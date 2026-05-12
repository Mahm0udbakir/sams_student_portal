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
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: context.tr('University Email')),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement send OTP and navigate to OTP screen
              },
              child: const Text('Send OTP'),
            ),
          ),
        ],
      ),
    );
  }
}
