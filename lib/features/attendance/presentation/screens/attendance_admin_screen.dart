import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/current_user_service.dart';
import '../../data/models/attendance_session_model.dart';
import '../../data/repositories/firestore_attendance_repository.dart';
import '../../domain/entities/attendance_session_entity.dart';
import '../../domain/usecases/create_attendance_session_usecase.dart';
import '../widgets/session_qr_widget.dart';

class AttendanceAdminScreen extends StatefulWidget {
  const AttendanceAdminScreen({super.key});

  @override
  State<AttendanceAdminScreen> createState() => _AttendanceAdminScreenState();
}

class _AttendanceAdminScreenState extends State<AttendanceAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _roomController = TextEditingController();
  final _repository = FirestoreAttendanceRepository();
  final _currentUserService = CurrentUserService();
  final _firestore = FirebaseFirestore.instance;
  AttendanceSessionEntity? _createdSession;
  bool _isLoading = false;
  bool _isCreatingSample = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _createSession() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final startAt = DateTime.now().toUtc();
      final endAt = startAt.add(const Duration(hours: 1, minutes: 30));
      final session = await CreateAttendanceSessionUseCase(
        repository: _repository,
      ).execute(
        CreateAttendanceSessionParams(
          subject: _subjectController.text.trim(),
          room: _roomController.text.trim(),
          startAt: startAt,
          endAt: endAt,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() => _createdSession = session);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance session created.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createSampleSession() async {
    if (_isCreatingSample) {
      return;
    }

    setState(() => _isCreatingSample = true);
    try {
      final now = DateTime.now().toUtc();
      final subject = _subjectController.text.trim().isEmpty
          ? 'Sample Attendance'
          : _subjectController.text.trim();
      final room = _roomController.text.trim().isEmpty
          ? 'Demo Room'
          : _roomController.text.trim();
      final currentUser = await _currentUserService.loadCurrentUser();
      final sessionDoc = _firestore.collection('attendance_sessions').doc();
      final sessionId = sessionDoc.id;
      final qrPayload = jsonEncode({'sessionId': sessionId});
      final dateOnly = DateTime.utc(now.year, now.month, now.day);
      final timeLabel = _formatTimeLabel(now);

      await sessionDoc.set({
        'sessionId': sessionId,
        'subject': subject,
        'date': Timestamp.fromDate(dateOnly),
        'time': timeLabel,
        'room': room,
        'isActive': true,
        'createdBy': currentUser?.uid,
        'startAt': Timestamp.fromDate(now),
        'endAt': Timestamp.fromDate(now.add(const Duration(hours: 1))),
        'qrPayload': qrPayload,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _createdSession = AttendanceSessionModel(
          sessionId: sessionId,
          subject: subject,
          room: room,
          startAt: now,
          endAt: now.add(const Duration(hours: 1)),
          isActive: true,
          qrPayload: qrPayload,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sample attendance session created: $sessionId')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingSample = false);
      }
    }
  }

  static String _formatTimeLabel(DateTime utcTime) {
    final local = utcTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Create a live QR session or seed a sample attendance_sessions document for testing.',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Enter a subject' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(labelText: 'Room'),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Enter a room' : null,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createSession,
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create session QR'),
                    ),
                    OutlinedButton(
                      onPressed:
                          _isCreatingSample ? null : _createSampleSession,
                      child: _isCreatingSample
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create sample Firestore doc'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_createdSession != null) ...[
            const SizedBox(height: 20),
            SessionQRCode(session: _createdSession!),
          ],
        ],
      ),
    );
  }
}
