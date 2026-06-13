import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/domain/entities/auth_user.dart';

class CurrentUserService {
  CurrentUserService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Future<AuthUser?> loadCurrentUser() async {
    final firebaseUser = await _ensureAuthUser();
    if (firebaseUser == null) {
      return null;
    }

    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return _mapSnapshotToUser(doc, firebaseUser);
      }

      return _buildFallbackUser(firebaseUser);
    } on FirebaseException {
      return _buildFallbackUser(firebaseUser);
    } catch (_) {
      return _buildFallbackUser(firebaseUser);
    }
  }

  Future<User?> _ensureAuthUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return firebaseUser;
    }

    try {
      return await _firebaseAuth.authStateChanges()
          .firstWhere((user) => user != null)
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      return null;
    }
  }

  Stream<AuthUser?> watchCurrentUser() async* {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      yield null;
      return;
    }

    yield* _firestore.collection('users').doc(firebaseUser.uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return _buildFallbackUser(firebaseUser);
      }

      return _mapSnapshotToUser(snapshot, firebaseUser);
    });
  }

  DateTime _parseDate(Object? value) {
    final parsed = _parseDateOrNull(value);
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
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

  String _resolveFullName(
    Map<String, dynamic> data,
    User firebaseUser,
  ) {
    final firstName = (data['firstName'] as String?)?.trim() ?? '';
    final lastName = (data['lastName'] as String?)?.trim() ?? '';
    final combined = [firstName, lastName].where((part) => part.isNotEmpty).join(' ').trim();
    if (combined.isNotEmpty) {
      return combined;
    }

    final name = (data['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final displayName = firebaseUser.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    return 'SAMS Student';
  }

  String _resolveFirstName(
    Map<String, dynamic> data,
    User firebaseUser,
  ) {
    final firstName = (data['firstName'] as String?)?.trim();
    if (firstName != null && firstName.isNotEmpty) {
      return firstName;
    }

    final fallback = _resolveFullName(data, firebaseUser).trim();
    final parts = fallback.split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : 'SAMS';
  }

  String _resolveLastName(
    Map<String, dynamic> data,
    User firebaseUser,
  ) {
    final lastName = (data['lastName'] as String?)?.trim();
    if (lastName != null && lastName.isNotEmpty) {
      return lastName;
    }

    final fallback = _resolveFullName(data, firebaseUser).trim();
    final parts = fallback.split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.sublist(1).join(' ') : 'Student';
  }

  AuthUser _mapSnapshotToUser(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    User firebaseUser,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};

    return AuthUser(
      uid: data['uid'] as String? ?? firebaseUser.uid,
      email: (data['email'] as String?)?.trim() ?? firebaseUser.email ?? '',
      name: _resolveFullName(data, firebaseUser),
      firstName: _resolveFirstName(data, firebaseUser),
      lastName: _resolveLastName(data, firebaseUser),
      studentId: (data['studentId'] as String?)?.trim() ?? '',
      role: (data['role'] as String?)?.trim().isNotEmpty == true
          ? (data['role'] as String).trim()
          : 'student',
      emailVerified: data['emailVerified'] as bool? ?? firebaseUser.emailVerified,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      lastLoginAt: _parseDateOrNull(data['lastLoginAt']),
      department: (data['department'] as String?)?.trim(),
      phoneNumber: (data['phoneNumber'] as String?)?.trim(),
      photoUrl: (data['photoUrl'] as String?)?.trim(),
    );
  }

  AuthUser _buildFallbackUser(User firebaseUser) {
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: _resolveFullName(const <String, dynamic>{}, firebaseUser),
      firstName: _resolveFirstName(const <String, dynamic>{}, firebaseUser),
      lastName: _resolveLastName(const <String, dynamic>{}, firebaseUser),
      studentId: '',
      role: 'student',
      emailVerified: firebaseUser.emailVerified,
      isActive: true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      lastLoginAt: null,
    );
  }
}
