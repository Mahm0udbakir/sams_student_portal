import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../core/services/auth_service.dart';

class AnnouncementItem extends Equatable {
  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.attachments = const [],
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final List<String> attachments;

  factory AnnouncementItem.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return AnnouncementItem(
      id: doc.id,
      title: (data['title'] as String?)?.trim().isNotEmpty == true
          ? (data['title'] as String).trim()
          : 'Untitled announcement',
      message: (data['message'] as String?)?.trim() ?? '',
      createdAt: _parseDate(data['createdAt']),
      attachments: _parseAttachments(data['attachments']),
    );
  }

  static DateTime _parseDate(Object? value) {
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

    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static List<String> _parseAttachments(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<String>()
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }

  @override
  List<Object?> get props => [id, title, message, createdAt, attachments];
}

class AnnouncementAuthException implements Exception {
  const AnnouncementAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AnnouncementPermissionDeniedException implements Exception {
  const AnnouncementPermissionDeniedException();
}

class AnnouncementDataException implements Exception {
  const AnnouncementDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AnnouncementRepository {
  AnnouncementRepository({
    FirebaseFirestore? firestore,
    AuthService? authService,
  }) : _firestore = firestore,
       _authService = authService ?? AuthService.instance;

  final FirebaseFirestore? _firestore;
  final AuthService _authService;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  bool get isSignedIn => _authService.isSignedIn;

  Future<void> ensureSignedIn() async {
    if (!isSignedIn) {
      throw const AnnouncementAuthException(
        'Please sign in to view announcements.',
      );
    }
  }

  Future<List<AnnouncementItem>> getAnnouncements() async {
    await ensureSignedIn();

    try {
      final query = await _db
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map(AnnouncementItem.fromDocument)
          .toList(growable: false);
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw const AnnouncementPermissionDeniedException();
      }

      throw AnnouncementDataException(
        error.message ?? 'Failed to load announcements. Please try again.',
      );
    }
  }
}
