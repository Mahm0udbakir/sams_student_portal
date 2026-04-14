import 'package:flutter/material.dart';

PreferredSizeWidget homeAppBar(BuildContext context) {
  return AppBar(
    title: const Text('SAMS Home'),
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: Icon(Icons.notifications),
      ),
    ],
  );
}
