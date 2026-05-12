import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../domain/entities/attendance_subject_entity.dart';
import '../bloc/attendance_bloc.dart';
import 'attendance_scanner_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<Widget> buildAttendanceCourseChildren(
  AttendanceClassItem item,
  dynamic visual,
  bool isActionClass,
  bool isMarking,
  BuildContext context,
) {
  final children = <Widget>[];
  children.add(
    Row(
      children: [
        Container(
          width: 5,
          height: 38,
          decoration: BoxDecoration(
            color: visual.accent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.subject,
            style: const TextStyle(
              color: SamsUiTokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: visual.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: visual.accent.withValues(alpha: 0.32)),
          ),
          child: Text(
            '${item.percentage}%',
            style: TextStyle(
              color: visual.accent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
  children.add(const SizedBox(height: 6));
  children.add(
    Row(
      children: [
        Icon(Icons.qr_code_2_rounded, size: 16, color: visual.accent),
        const SizedBox(width: 6),
        Text(
          'Attended: ${item.attendedCount}',
          style: TextStyle(
            color: visual.accent,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ],
    ),
  );
  if (item.scanDates.isNotEmpty) {
    children.add(const SizedBox(height: 6));
    children.add(
      Text(
        'Scan History:',
        style: TextStyle(
          color: SamsUiTokens.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
    children.add(const SizedBox(height: 2));
    children.add(
      SizedBox(
        height: 28,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: item.scanDates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, idx) {
            final date = item.scanDates[idx];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: visual.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                style: TextStyle(
                  color: visual.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  children.add(const SizedBox(height: 6));
  children.add(
    Text(
      _bandLabel(item.percentage),
      style: TextStyle(
        color: visual.accent,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
  if (isActionClass) {
    children.add(const SizedBox(height: 8));
    children.add(
      SizedBox(
        height: 38,
        child: SamsTapScale(
          enabled: !isMarking,
          child: OutlinedButton(
            onPressed: isMarking
                ? null
                : () async {
                    final permissionGranted = await CameraPermissionService().ensureCameraPermission();
                    if (!permissionGranted) {
                      if (context.mounted) {
                        ModernSnackbars.show(
                          context,
                          message: 'Camera permission is required to scan attendance QR codes.',
                          type: ModernSnackbarType.info,
                        );
                      }
                      return;
                    }
                    final scanned = await Navigator.of(context).push<String?>(
                      MaterialPageRoute(
                        builder: (_) => const AttendanceScannerScreen(),
                      ),
                    );
                    if (scanned != null && scanned.isNotEmpty) {
                      String sessionId = scanned;
                      try {
                        final decoded = jsonDecode(scanned);
                        if (decoded is Map && decoded['sessionId'] is String) {
                          sessionId = decoded['sessionId'] as String;
                        }
                      } catch (_) {}
                      context.read<AttendanceBloc>().add(
                        AttendanceRecordRequested(sessionId: sessionId),
                      );
                    }
                  },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: visual.accent.withValues(alpha: 0.75)),
              foregroundColor: visual.accent,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            child: isMarking
                ? SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(visual.accent),
                    ),
                  )
                : const Text('Scan QR Code'),
          ),
        ),
      ),
    );
  }
  return children;
}