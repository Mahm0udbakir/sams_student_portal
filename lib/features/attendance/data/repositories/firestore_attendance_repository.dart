import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

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
      throw StateError('No signed-in user');
    }

    final sessionsSnap = await _firestore.collection(sessionsCollection).get();
    final sessions = sessionsSnap.docs;
    final totalSessions = sessions.length;

    final Map<String, String> sessionSubjects = {};
    final Map<String, int> totalBySubject = {};

    for (final session in sessions) {
      final id = session.id;
      final subject = (session.data()['subject'] as String?)?.trim() ?? 'General';
      sessionSubjects[id] = subject;
      totalBySubject[subject] = (totalBySubject[subject] ?? 0) + 1;
    }

    final recordsSnap = await _firestore
        .collection(recordsCollection)
        .where('studentUid', isEqualTo: user.uid)
        .get();

    final attendedSessionIds = recordsSnap.docs
        .map((doc) => doc.data()['sessionId'] as String?)
        .whereType<String>()
        .toSet();


    // Map subject -> List<DateTime> of scan dates
    final Map<String, List<DateTime>> scanDatesBySubject = {};
    for (final doc in recordsSnap.docs) {
      final sid = doc.data()['sessionId'] as String?;
      if (sid == null) continue;
      final subject = sessionSubjects[sid] ?? 'General';
      final timestamp = doc.data()['timestamp'];
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

    final subjects = <AttendanceSubjectModel>[];
    for (final entry in totalBySubject.entries) {
      final total = entry.value;
      final attended = attendedBySubject[entry.key] ?? 0;
      final percentage = total == 0 ? 0 : ((attended / total) * 100).round();
      // We'll extend AttendanceSubjectModel later to include attendedCount and scanDates
      subjects.add(AttendanceSubjectModel(
        subject: entry.key,
        percentage: percentage,
        // Custom fields for UI: attendedCount and scanDates
        attendedCount: attended,
        scanDates: scanDatesBySubject[entry.key] ?? [],
      ));
    }

    final attendedTotal = attendedSessionIds.length;
    final overall = totalSessions == 0 ? 0 : ((attendedTotal / totalSessions) * 100).round();

    return AttendanceOverviewModel(
      overallPercent: overall,
      subjects: subjects,
    );
  }

  @override
  Future<void> recordAttendance({required String sessionId}) async {
    final user = await _currentUserService.loadCurrentUser();
    if (user == null) {
      throw StateError('No signed-in user');
    }

    final sessionDoc = await _firestore.collection(sessionsCollection).doc(sessionId).get();
    if (!sessionDoc.exists) {
      throw const AttendanceSessionNotFoundException();
    }

    final recordDoc = _firestore.collection(recordsCollection).doc('${user.uid}_$sessionId');
    final existing = await recordDoc.get();
    if (existing.exists) {
      throw const AttendanceDuplicateScanException();
    }

    await recordDoc.set({
      'sessionId': sessionId,
      'studentUid': user.uid,
      'studentId': user.studentId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<AttendanceOverviewEntity> watchAttendanceOverview() async* {
    final user = await _currentUserService.loadCurrentUser();
    if (user == null) {
      throw StateError('No signed-in user');
    }

    final controller = StreamController<AttendanceOverviewEntity>();

    final sessionsSub = _firestore.collection(sessionsCollection).snapshots().listen((_) async {
      try {
        if (!controller.isClosed) {
          controller.add(await getAttendanceOverview());
        }
      } catch (_) {}
    });

    final recordsSub = _firestore
        .collection(recordsCollection)
        .where('studentUid', isEqualTo: user.uid)
        .snapshots()
        .listen((_) async {
      try {
        if (!controller.isClosed) {
          controller.add(await getAttendanceOverview());
        }
      } catch (_) {}
    });

    try {
      controller.add(await getAttendanceOverview());
    } catch (_) {}

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

