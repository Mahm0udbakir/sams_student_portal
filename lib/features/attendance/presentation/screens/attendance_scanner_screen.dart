import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AttendanceScannerScreen extends StatelessWidget {
  const AttendanceScannerScreen({super.key, this.courseTitle});

  /// Course the student chose before opening the camera (shown for context only).
  final String? courseTitle;

  @override
  Widget build(BuildContext context) {
    final title = courseTitle == null || courseTitle!.trim().isEmpty
        ? 'Scan attendance'
        : 'Scan: ${courseTitle!.trim()}';

    return Material(
      color: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color(0xFF052941),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
        ),
        body: MobileScanner(
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final code = barcodes.first.rawValue ?? '';
              if (code.isNotEmpty) {
                Navigator.of(context).pop(code);
              }
            }
          },
        ),
      ),
    );
  }
}
