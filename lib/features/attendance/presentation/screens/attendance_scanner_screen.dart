import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AttendanceScannerScreen extends StatelessWidget {
  const AttendanceScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Attendance')),
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
    );
  }
}
