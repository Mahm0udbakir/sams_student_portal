import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/portal_courses.dart';
import '../../../../core/services/current_user_service.dart';
import '../../domain/entities/attendance_overview_entity.dart';
import '../../domain/entities/attendance_session_entity.dart';
import '../../domain/exceptions/attendance_scan_exception.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_overview_model.dart';
import '../models/attendance_session_model.dart';
import '../models/attendance_subject_model.dart';

class FirestoreAttendanceRepository implements AttendanceRepository {
  FirestoreAttendanceRepository({
    FirebaseFirestore? firestore,
    CurrentUserService? currentUserService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUserService = currentUserService ?? CurrentUserService();

  final FirebaseFirestore _firestore;
  final CurrentUserService _currentUserService;

  static const sessionsCollection = 'attendance_sessions';
  static const recordsCollection = 'attendance_records';

  @override
  Future<AttendanceSessionEntity> createAttendanceSession({
    required String subject,
    required String room,
    required DateTime startAt,
    required DateTime endAt,
    bool isActive = true,
  }) async {
    final sessionDoc = _firestore.collection(sessionsCollection).doc();
    final currentUser = await _currentUserService.loadCurrentUser();
    final resolvedStartAt = startAt.toUtc();
    final resolvedEndAt = endAt.toUtc();
    final dateOnly = DateTime.utc(
      resolvedStartAt.year,
      resolvedStartAt.month,
      resolvedStartAt.day,
    );
    final timeLabel = _formatTimeLabel(resolvedStartAt);
    final qrPayload = jsonEncode({
      'sessionId': sessionDoc.id,
      'subject': subject.trim(),
      'room': room.trim(),
      'startAt': resolvedStartAt.toIso8601String(),
      'endAt': resolvedEndAt.toIso8601String(),
    });

    await sessionDoc.set({
      'sessionId': sessionDoc.id,
      'subject': subject.trim(),
      'room': room.trim(),
      'date': Timestamp.fromDate(dateOnly),
      'time': timeLabel,
      'startAt': Timestamp.fromDate(resolvedStartAt),
      'endAt': Timestamp.fromDate(resolvedEndAt),
      'isActive': isActive,
      'createdBy': currentUser?.uid,
      'qrPayload': qrPayload,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return AttendanceSessionModel(
      sessionId: sessionDoc.id,
      subject: subject.trim(),
      room: room.trim(),
      startAt: startAt.toUtc(),
      endAt: endAt.toUtc(),
      isActive: isActive,
      qrPayload: qrPayload,
    );
  }

  @override
  Stream<List<AttendanceSessionEntity>> watchActiveSessions() {
    return _firestore
        .collection(sessionsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(_mapSessionDoc)
              .whereType<AttendanceSessionEntity>()
              .toList(growable: false),
        );
  }

  @override
  Future<AttendanceOverviewEntity> getAttendanceOverview() async {
    final user = await _currentUserService.loadCurrentUser();
    if (user == null) {
      return AttendanceOverviewModel(
        overallPercent: 0,
        subjects: PortalCourses.curriculum
            .map(
              (name) => AttendanceSubjectModel(
                subject: name,
                percentage: 0,
                attendedCount: 0,
                scheduledSessionCount: 12,
                scanDates: const [],
              ),
            )
            .toList(growable: false),
      );
    }

    final sessionsSnap = await _firestore.collection(sessionsCollection).get();
    final sessionSubjects = <String, String>{};
    final totalBySubject = <String, int>{};

    for (final session in sessionsSnap.docs) {
      final id = session.id;
      final data = session.data();
      final sid = (data['sessionId'] as String?)?.trim().isNotEmpty == true
          ? (data['sessionId'] as String).trim()
          : id;
      final subject = (data['subject'] as String?)?.trim() ?? 'General';
      sessionSubjects[sid] = subject;
      totalBySubject[subject] = (totalBySubject[subject] ?? 0) + 1;
    }

    for (final course in PortalCourses.curriculum) {
      totalBySubject.putIfAbsent(course, () => 0);
    }

    final recordsSnap = await _firestore
        .collection(recordsCollection)
        .where('studentUid', isEqualTo: user.uid)
        .get();

    final attendedBySubject = <String, int>{};
    final scanDatesBySubject = <String, List<DateTime>>{};

    for (final doc in recordsSnap.docs) {
      final data = doc.data();
      final sid = data['sessionId'] as String?;
      final recordSubject = (data['subject'] as String?)?.trim();
      final subject = (recordSubject != null && recordSubject.isNotEmpty)
          ? recordSubject
          : (sid != null ? (sessionSubjects[sid] ?? 'General') : 'General');

      attendedBySubject[subject] = (attendedBySubject[subject] ?? 0) + 1;

      final timestamp = data['timestamp'];
      DateTime? scanDate;
      if (timestamp is Timestamp) {
        scanDate = timestamp.toDate();
      } else if (timestamp is DateTime) {
        scanDate = timestamp;
      }
      if (scanDate != null) {
        scanDatesBySubject.putIfAbsent(subject, () => []).add(scanDate);
      }
    }

    const defaultScheduledSessions = 12;
    final subjects = <AttendanceSubjectModel>[];
    for (final course in PortalCourses.curriculum) {
      final total = totalBySubject[course] ?? 0;
      final scheduled = total > 0 ? total : defaultScheduledSessions;
      final attended = attendedBySubject[course] ?? 0;
      final percentage = ((attended / scheduled) * 100).round().clamp(0, 100);
      final dates = scanDatesBySubject[course] ?? [];
      dates.sort((a, b) => b.compareTo(a));
      subjects.add(
        AttendanceSubjectModel(
          subject: course,
          percentage: percentage,
          attendedCount: attended,
          scheduledSessionCount: scheduled,
          scanDates: List<DateTime>.unmodifiable(dates),
        ),
      );
    }

    for (final entry in totalBySubject.entries) {
      if (PortalCourses.curriculum.contains(entry.key)) {
        continue;
      }
      final total = entry.value;
      final attended = attendedBySubject[entry.key] ?? 0;
      final denominator = total > 0 ? total : (attended > 0 ? attended : 1);
      final percentage = ((attended / denominator) * 100).round().clamp(0, 100);
      final dates = scanDatesBySubject[entry.key] ?? [];
      dates.sort((a, b) => b.compareTo(a));
      subjects.add(
        AttendanceSubjectModel(
          subject: entry.key,
          percentage: percentage,
          attendedCount: attended,
          scheduledSessionCount: total,
          scanDates: List<DateTime>.unmodifiable(dates),
        ),
      );
    }

    final totalSessions = sessionsSnap.docs.length;
    final attendedTotal = recordsSnap.docs.length;

    var overallFromCurriculum = 0;
    if (subjects.isNotEmpty) {
      final coreLen = PortalCourses.curriculum.length.clamp(0, subjects.length);
      final core = subjects.take(coreLen).toList(growable: false);
      overallFromCurriculum = core.isEmpty
          ? 0
          : (core.map((s) => s.percentage).fold<int>(0, (a, b) => a + b) ~/ core.length);
    }

    final overall = totalSessions == 0
        ? overallFromCurriculum
        : ((attendedTotal / totalSessions) * 100).round().clamp(0, 100);

    return AttendanceOverviewModel(
      overallPercent: overall,
      subjects: subjects,
    );
  }

  @override
  Future<void> recordAttendance({
    required String sessionId,
    required String courseSubject,
  }) async {
    final user = await _currentUserService.loadCurrentUser();
    if (user == null) {
      throw const AttendanceScanException(
        'No signed-in user. Please sign in and try again.',
      );
    }

    final trimmedSession = sessionId.trim();
    if (trimmedSession.isEmpty) {
      throw const AttendanceScanException('Invalid scan (empty code).');
    }

    final subject = courseSubject.trim();

    try {
      await _firestore.collection(recordsCollection).add({
        'sessionId': trimmedSession,
        'subject': subject,
        'studentUid': user.uid,
        'studentId': user.studentId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw AttendanceScanException(
        'Failed to record attendance: ${error.message ?? 'Firestore write error.'}',
      );
    }
  }

  @override
  Stream<AttendanceOverviewEntity> watchAttendanceOverview() async* {
    final user = await _currentUserService.loadCurrentUser();
    final fallbackOverview = AttendanceOverviewModel(
      overallPercent: 0,
      subjects: PortalCourses.curriculum
          .map(
            (name) => AttendanceSubjectModel(
              subject: name,
              percentage: 0,
              attendedCount: 0,
              scheduledSessionCount: 12,
              scanDates: const [],
            ),
          )
          .toList(growable: false),
    );

    if (user == null) {
      yield fallbackOverview;
      return;
    }

    final controller = StreamController<AttendanceOverviewEntity>();

    final sessionsSub = _firestore.collection(sessionsCollection).snapshots().listen(
      (_) async {
        try {
          if (!controller.isClosed) {
            controller.add(await getAttendanceOverview());
          }
        } catch (_) {
          if (!controller.isClosed) {
            controller.add(fallbackOverview);
          }
        }
      },
      onError: (_) {
        if (!controller.isClosed) {
          controller.add(fallbackOverview);
        }
      },
    );

    final recordsSub = _firestore
        .collection(recordsCollection)
        .where('studentUid', isEqualTo: user.uid)
        .snapshots()
        .listen(
      (_) async {
        try {
          if (!controller.isClosed) {
            controller.add(await getAttendanceOverview());
          }
        } catch (_) {
          if (!controller.isClosed) {
            controller.add(fallbackOverview);
          }
        }
      },
      onError: (_) {
        if (!controller.isClosed) {
          controller.add(fallbackOverview);
        }
      },
    );

    try {
      controller.add(await getAttendanceOverview());
    } catch (_) {
      if (!controller.isClosed) {
        controller.add(fallbackOverview);
      }
    }

    controller.onCancel = () async {
      await sessionsSub.cancel();
      await recordsSub.cancel();
      await controller.close();
    };

    yield* controller.stream;
  }

  AttendanceSessionEntity? _mapSessionDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final startAt = _parseDateOrNull(data['startAt']) ??
        _parseDateOrNull(data['date']) ??
        DateTime.now().toUtc();
    final endAt = _parseDateOrNull(data['endAt']) ??
        startAt.add(const Duration(hours: 1, minutes: 30));
    final sessionId = (data['sessionId'] as String?)?.trim().isNotEmpty == true
        ? (data['sessionId'] as String).trim()
        : doc.id;

    return AttendanceSessionModel(
      sessionId: sessionId,
      subject: (data['subject'] as String?)?.trim() ?? 'General',
      room: (data['room'] as String?)?.trim() ?? 'Main hall',
      startAt: startAt,
      endAt: endAt,
      isActive: data['isActive'] as bool? ?? false,
      qrPayload: (data['qrPayload'] as String?)?.trim() ??
          jsonEncode({'sessionId': sessionId}),
    );
  }

  static String _formatTimeLabel(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime? _parseDateOrNull(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }

    if (value is DateTime) {
      return value.toUtc();
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.toUtc();
      }
    }

    return null;
  }
}
