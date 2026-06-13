import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/portal_courses.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/camera_permission_service.dart';
import '../../../../core/services/current_user_service.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../attendance/data/repositories/firestore_attendance_repository.dart';
import '../../../attendance/domain/exceptions/attendance_scan_exception.dart';
import '../../../attendance/domain/usecases/scan_attendance_usecase.dart';
import '../../../attendance/presentation/screens/attendance_scanner_screen.dart';

/// Scan tab: pick one of four courses → camera only → record attendance → success → Attendance screen.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _repository = FirestoreAttendanceRepository();
  final _currentUserService = CurrentUserService();
  bool _recording = false;

  Future<bool> _checkSignedIn() async {
    final user = await _currentUserService.loadCurrentUser();
    if (user == null) {
      if (!mounted) return false;
      ModernSnackbars.show(
        context,
        message: 'Please sign in before scanning attendance.',
        type: ModernSnackbarType.info,
      );
      if (mounted) {
        context.goNamed(AppRouteNames.login);
      }
      return false;
    }
    return true;
  }

  Future<void> _showRecordedDialog(String courseName) async {
    final colorScheme = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.72),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF063454), Color(0xFF0A5A88)],
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_rounded, color: Color(0xFFD7E9FB), size: 22),
                      SizedBox(width: 8),
                      SamsLocaleText(
                        'Attendance recorded',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: const Center(
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: SamsUiTokens.success,
                              size: 44,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SamsLocaleText(
                        'Your attendance for $courseName was saved.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SamsLocaleText(
                        'You can review percentages and scan history on the Attendance screen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SamsTapScale(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            if (context.mounted) {
                              context.goNamed(AppRouteNames.attendanceDetail);
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: SamsUiTokens.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const SamsLocaleText(
                            'View attendance',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const SamsLocaleText(
                          'Scan another course',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onCourseSelected(String course) async {
    if (_recording) return;

    if (!await _checkSignedIn()) {
      return;
    }

    final granted = await CameraPermissionService().ensureCameraPermission();
    if (!mounted) return;
    if (!granted) {
      ModernSnackbars.show(
        context,
        message: 'Camera permission is required to scan attendance QR codes.',
        type: ModernSnackbarType.info,
      );
      return;
    }

    final raw = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AttendanceScannerScreen(courseTitle: course),
      ),
    );

    if (!mounted || raw == null || raw.trim().isEmpty) return;

    setState(() => _recording = true);
    try {
      await ScanAttendanceUseCase(repository: _repository).execute(
        raw.trim(),
        courseSubject: course,
      );
      if (!mounted) return;
      await _showRecordedDialog(course);
    } on AttendanceDuplicateScanException catch (e) {
      if (mounted) {
        ModernSnackbars.show(context, message: e.message, type: ModernSnackbarType.info);
      }
    } on AttendanceScanException catch (e) {
      if (mounted) {
        ModernSnackbars.show(context, message: e.message, type: ModernSnackbarType.error);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ModernSnackbars.show(
          context,
          message: 'Could not record attendance: ${e.message ?? e.code}',
          type: ModernSnackbarType.error,
        );
      }
    } on StateError catch (e) {
      if (mounted) {
        ModernSnackbars.show(
          context,
          message: 'Could not record attendance: ${e.message}',
          type: ModernSnackbarType.error,
        );
      }
    } on ArgumentError catch (e) {
      if (mounted) {
        ModernSnackbars.show(
          context,
          message: e.message,
          type: ModernSnackbarType.error,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Attendance scan error: $error');
      debugPrint('$stackTrace');
      if (mounted) {
        ModernSnackbars.show(
          context,
          message: 'Could not record attendance: ${error.toString()}',
          type: ModernSnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _recording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Scan'),
      body: Stack(
        children: [
          const Positioned(top: -88, right: -72, child: _ScanBackdropBubble()),
          const Positioned(bottom: 96, left: -82, child: _ScanBackdropBubble()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: SamsUiTokens.contentMaxWidth),
                child: ListView(
                  padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 24),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(SamsUiTokens.radiusXl),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF063454), Color(0xFF0A5F93)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF063454).withValues(alpha: 0.26),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.school_rounded, color: Color(0xFFD9EBFB), size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: SamsLocaleText(
                                  'Mark attendance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          SamsLocaleText(
                            'Choose your course, then point the camera at any QR code. Your scan is saved for that course.',
                            style: TextStyle(
                              color: Color(0xFFE1ECF8),
                              fontSize: 12.8,
                              fontWeight: FontWeight.w600,
                              height: 1.38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SamsLocaleText(
                      'Select a course',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SamsLocaleText(
                      'Camera opens immediately after you tap a course. Gallery is not used.',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...PortalCourses.curriculum.map(
                      (name) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CoursePickTile(
                          courseName: name,
                          enabled: !_recording,
                          onTap: () => _onCourseSelected(name),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_recording)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.75)),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        SizedBox(height: 14),
                        SamsLocaleText(
                          'Saving attendance…',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoursePickTile extends StatelessWidget {
  const _CoursePickTile({
    required this.courseName,
    required this.enabled,
    required this.onTap,
  });

  final String courseName;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SamsPressable(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.75)),
          boxShadow: SamsUiTokens.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SamsUiTokens.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_rounded, color: SamsUiTokens.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SamsLocaleText(
                courseName,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              Icons.photo_camera_outlined,
              color: enabled ? SamsUiTokens.primary : cs.onSurfaceVariant.withValues(alpha: 0.5),
              size: 22,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanBackdropBubble extends StatelessWidget {
  const _ScanBackdropBubble();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
