import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AttendanceScannerScreen extends StatefulWidget {
  const AttendanceScannerScreen({super.key, this.courseTitle});

  /// Course the student chose before opening the camera (shown for context only).
  final String? courseTitle;

  @override
  State<AttendanceScannerScreen> createState() => _AttendanceScannerScreenState();
}

class _AttendanceScannerScreenState extends State<AttendanceScannerScreen> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.courseTitle == null || widget.courseTitle!.trim().isEmpty
        ? 'Scan attendance'
        : 'Scan: ${widget.courseTitle!.trim()}';

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
            if (_hasScanned) return;
            final barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final barcode = barcodes.first;
              final code = (barcode.rawValue ?? barcode.displayValue ?? '').trim();
              if (code.isNotEmpty) {
                _hasScanned = true;
                debugPrint('Attendance QR scanned: $code');
                if (mounted) {
                  Navigator.of(context).maybePop(code);
                }
              }
            }
          },
        ),
      ),
    );
  }
}
