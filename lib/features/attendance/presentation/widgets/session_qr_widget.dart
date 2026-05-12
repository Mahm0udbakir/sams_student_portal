import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/entities/attendance_session_entity.dart';

class SessionQRCode extends StatelessWidget {
  const SessionQRCode({super.key, required this.session});

  final AttendanceSessionEntity session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7E3EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            session.subject,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${session.room} • ${session.sessionId}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF5B6472), fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          QrImageView(
            data: session.qrPayload,
            size: 220,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            'Scan this code to mark attendance',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
