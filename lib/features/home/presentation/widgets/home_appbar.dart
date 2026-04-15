import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';

PreferredSizeWidget homeAppBar(BuildContext context) {
  return AppBar(
    title: const SamsLocaleText('SAMS Home'),
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: Icon(Icons.notifications),
      ),
    ],
  );
}
