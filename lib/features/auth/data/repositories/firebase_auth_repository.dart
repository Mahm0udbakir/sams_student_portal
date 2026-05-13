import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/config/env.dart';
import '../../../../core/services/brevo_email_service.dart';
import '../../domain/entities/auth_error.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    Dio? dio,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _brevoEmailService = BrevoEmailService(dio: dio);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final BrevoEmailService _brevoEmailService;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _otpChallenges =>
      _firestore.collection('auth_otps');

  @override
  Future<AuthResult<AuthUser>> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? studentId,
    String? department,
  }) async {
    if (!_isAllowedEmail(email)) {
      return const AuthFailure<AuthUser>(
        type: AuthErrorType.emailNotAllowed,
        message: 'Use your approved university email address.',
      );
    }

    try {
      debugPrint('[FIREBASE DEBUG] ProjectId: \\${FirebaseAuth.instance.app.options.projectId}');
      await Future.delayed(const Duration(seconds: 3)); // Temporary workaround for propagation
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.unknown,
          message: 'Could not create your account. Please try again.',
        );
      }

      final trimmedName = name.trim();
      if (trimmedName.isNotEmpty) {
        await user.updateDisplayName(trimmedName);
        await user.reload();
      }

      final created = await createUserDocument(
        uid: user.uid,
        email: user.email ?? email.trim(),
        name: trimmedName.isNotEmpty ? trimmedName : email.trim().split('@').first,
        firstName: firstName,
        lastName: lastName,
        studentId: studentId,
        department: department,
        emailVerified: false,
      );

      if (created is AuthFailure<AuthUser>) {
        return created;
      }

      final otpResult = await sendOtp(
        email: email.trim(),
        name: trimmedName.isNotEmpty ? trimmedName : 'Student',
        purpose: 'signup',
      );

      if (otpResult is AuthFailure<void>) {
        return AuthFailure<AuthUser>(
          type: otpResult.type,
          message: otpResult.message,
        );
      }

      if (otpResult is AuthOtpChallenge<void>) {
        return AuthOtpChallenge<AuthUser>(
          verificationId: otpResult.verificationId,
          email: otpResult.email,
          name: otpResult.name,
          expiresAt: otpResult.expiresAt,
          attemptsRemaining: otpResult.attemptsRemaining,
        );
      }

      return const AuthFailure<AuthUser>(
        type: AuthErrorType.unknown,
        message: 'Could not start email verification.',
      );
    } on FirebaseAuthException catch (error) {
      debugPrint('[FIREBASE AUTH ERROR] code: \\${error.code}, message: \\${error.message}');
      debugPrint('[FIREBASE DEBUG] ProjectId: \\${FirebaseAuth.instance.app.options.projectId}');
      // If operation-not-allowed, wait and retry once (Email/Password may need time to enable)
      if (error.code == 'operation-not-allowed') {
        await Future.delayed(const Duration(seconds: 2));
        try {
          final credential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
          final user = credential.user;
          if (user == null) {
            return const AuthFailure<AuthUser>(
              type: AuthErrorType.unknown,
              message: 'Could not create your account. Please try again.',
            );
          }
          // ... (repeat user doc creation and OTP logic if needed)
          // For brevity, just return a better error for now
          return AuthFailure<AuthUser>(
            type: AuthErrorType.operationNotAllowed,
            message: 'Email/Password sign-in is not enabled yet. Please wait a few minutes and try again. [code: operation-not-allowed]',
          );
        } catch (e) {
          debugPrint('[FIREBASE AUTH ERROR RETRY] $e');
        }
      }
      return AuthFailure<AuthUser>(
        type: _mapAuthException(error),
        message: _messageForAuthException(error) + '\n[code: ' + error.code + ']'
          + (error.code == 'operation-not-allowed' ? '\nEmail/Password sign-in may take a few minutes to enable after you turn it on in the Firebase Console.' : ''),
      );
    } on FirebaseException catch (error) {
      debugPrint('[FIREBASE ERROR] code: \\${error.code}, message: \\${error.message}');
      debugPrint('[FIREBASE DEBUG] ProjectId: \\${FirebaseAuth.instance.app.options.projectId}');
      return AuthFailure<AuthUser>(
        type: _mapFirestoreException(error),
        message: (error.message ?? 'Could not create your account. Please try again.') + '\n[code: ' + (error.code ?? 'unknown') + ']',
      );
    } catch (e) {
      debugPrint('[GENERIC SIGNUP ERROR] $e');
      return const AuthFailure<AuthUser>(
        type: AuthErrorType.unknown,
        message: 'Could not create your account. Please try again.',
      );
    }
  }

  @override
  Future<AuthResult<AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return const AuthFailure<AuthUser>(
      type: AuthErrorType.operationNotAllowed,
      message: 'Password sign-in is disabled. Use university email and OTP. If you just enabled Email/Password in Firebase Console, please wait a few minutes and try again.',
    );
  }

  @override
  Future<AuthResult<void>> sendOtp({
    required String email,
    required String name,
    required String purpose,
  }) async {
    final verificationId = _otpChallenges.doc().id;
    final otp = _generateOtp();
    final expiresAt = DateTime.now().toUtc().add(const Duration(minutes: 10));

    try {
      await _otpChallenges.doc(verificationId).set({
        'verificationId': verificationId,
        'email': email.trim(),
        'name': name.trim(),
        'purpose': purpose,
        'otp': otp,
        'attempts': 0,
        'maxAttempts': 5,
        'consumed': false,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

      await _sendBrevoOtpEmail(
        email: email.trim(),
        name: name.trim().isNotEmpty ? name.trim() : 'Student',
        otp: otp,
        purpose: purpose,
        expiresAt: expiresAt,
      );

      return AuthOtpChallenge<void>(
        verificationId: verificationId,
        email: email.trim(),
        name: name.trim(),
        expiresAt: expiresAt,
        attemptsRemaining: 5,
      );
    } on FirebaseException catch (error) {
      return AuthFailure<void>(
        type: _mapFirestoreException(error),
        message: error.message ?? 'Could not send the verification code.',
      );
    } catch (error) {
      if (kDebugMode) {
        return AuthOtpChallenge<void>(
          verificationId: verificationId,
          email: email.trim(),
          name: name.trim(),
          expiresAt: expiresAt,
          attemptsRemaining: 5,
        );
      }

      return AuthFailure<void>(
        type: AuthErrorType.unknown,
        message: error.toString().isNotEmpty
            ? error.toString()
            : 'Could not send the verification code.',
      );
    }
  }

  @override
  Future<AuthResult<AuthUser>> verifyOtp({
    required String verificationId,
    required String otp,
    String? purposeHint,
  }) async {
    final hint = purposeHint?.trim().toLowerCase();
    if (hint == 'login') {
      return _verifyLoginOtpWithCallable(verificationId: verificationId, otp: otp);
    }

    try {
      final docRef = _otpChallenges.doc(verificationId.trim());
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.invalidVerificationId,
          message: 'OTP session was not found. Please request a new code.',
        );
      }

      final data = snapshot.data() ?? <String, dynamic>{};
      final purpose = (data['purpose'] as String?)?.trim().toLowerCase() ?? 'signup';

      if (purpose == 'login') {
        return _verifyLoginOtpWithCallable(verificationId: verificationId, otp: otp);
      }

      if (data['consumed'] == true) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.otpAlreadyUsed,
          message: 'This verification code was already used.',
        );
      }

      final expiresAt = _parseDate(data['expiresAt']);
      if (DateTime.now().toUtc().isAfter(expiresAt)) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.otpExpired,
          message: 'This verification code expired. Please request a new one.',
        );
      }

      final attempts = (data['attempts'] as int?) ?? 0;
      final maxAttempts = (data['maxAttempts'] as int?) ?? 5;
      if (attempts >= maxAttempts) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.otpTooManyAttempts,
          message:
              'Too many failed attempts. Please request a new verification code.',
        );
      }

      final storedOtp = (data['otp'] as String?)?.trim() ?? '';
      if (storedOtp != otp.trim()) {
        await docRef.update({'attempts': FieldValue.increment(1)});

        return AuthFailure<AuthUser>(
          type: AuthErrorType.otpInvalid,
          message: 'Invalid verification code. Please try again.',
        );
      }

      await docRef.update({
        'consumed': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      final email = (data['email'] as String?)?.trim();
      final name = (data['name'] as String?)?.trim();
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.userNotFound,
          message: 'Signed in user was not found. Please try signing up again.',
        );
      }

      final resolvedEmail = email ?? user.email ?? '';
      final resolvedName = name ?? user.displayName?.trim() ?? resolvedEmail;

      final created = await createUserDocument(
        uid: user.uid,
        email: resolvedEmail,
        name: resolvedName,
        emailVerified: true,
      );

      if (created is AuthFailure<AuthUser>) {
        return created;
      }

      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.userNotFound,
          message: 'Your verified account was not found.',
        );
      }

      return AuthSuccess<AuthUser>(currentUser);
    } on FirebaseException catch (error) {
      return AuthFailure<AuthUser>(
        type: _mapFirestoreException(error),
        message: error.message ?? 'Could not verify the code.',
      );
    } catch (_) {
      return const AuthFailure<AuthUser>(
        type: AuthErrorType.unknown,
        message: 'Could not verify the code. Please try again.',
      );
    }
  }

  Future<AuthResult<AuthUser>> _verifyLoginOtpWithCallable({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('exchangeLoginOtp');
      final result = await callable.call({
        'verificationId': verificationId.trim(),
        'otp': otp.trim(),
      });

      final raw = result.data;
      if (raw is! Map) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.unknown,
          message: 'Login service returned an unexpected response.',
        );
      }
      final token = raw['customToken'] as String?;
      if (token == null || token.isEmpty) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.unknown,
          message: 'Login service returned an empty token.',
        );
      }

      await _firebaseAuth.signInWithCustomToken(token);

      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.userNotFound,
          message: 'Your account profile was not found after sign-in.',
        );
      }

      final refreshed = await createUserDocument(
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.name,
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        studentId: currentUser.studentId,
        department: currentUser.department,
        emailVerified: true,
      );

      if (refreshed is AuthSuccess<AuthUser>) {
        return AuthSuccess<AuthUser>(refreshed.data);
      }

      return AuthSuccess<AuthUser>(currentUser);
    } on FirebaseFunctionsException catch (error) {
      return AuthFailure<AuthUser>(
        type: _mapFunctionsException(error),
        message: error.message ?? 'Could not complete OTP login.',
      );
    } catch (error) {
      return AuthFailure<AuthUser>(
        type: AuthErrorType.unknown,
        message:
            'OTP login requires the exchangeLoginOtp Cloud Function. '
            'Deploy functions/ (see repository docs) or check your connection. '
            '(${error.toString()})',
      );
    }
  }

  @override
  Future<AuthResult<AuthUser>> createUserDocument({
    required String uid,
    required String email,
    required String name,
    String? firstName,
    String? lastName,
    String? studentId,
    String? department,
    bool emailVerified = false,
  }) async {
    final now = DateTime.now().toUtc();
    final userRef = _users.doc(uid);
    final resolvedNameParts = _splitName(
      name,
      firstName: firstName,
      lastName: lastName,
    );

    try {
      await userRef.set({
        'uid': uid,
        'email': email.trim(),
        'name': name.trim(),
        'firstName': resolvedNameParts.$1,
        'lastName': resolvedNameParts.$2,
        'studentId': (studentId ?? '').trim(),
        'department': department?.trim(),
        'role': 'student',
        'emailVerified': emailVerified,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final created = await userRef.get();
      final user = _authUserFromSnapshot(created);
      if (user == null) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.documentCreationFailed,
          message: 'Could not load your user profile.',
        );
      }

      return AuthSuccess<AuthUser>(
        user.copyWith(
          updatedAt: now,
          lastLoginAt: now,
          emailVerified: emailVerified,
        ),
      );
    } on FirebaseException catch (error) {
      return AuthFailure<AuthUser>(
        type: _mapFirestoreException(error),
        message: error.message ?? 'Could not create your profile document.',
      );
    } catch (_) {
      return const AuthFailure<AuthUser>(
        type: AuthErrorType.documentCreationFailed,
        message: 'Could not create your profile document.',
      );
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    try {
      final snapshot = await _users.doc(firebaseUser.uid).get();
      if (!snapshot.exists) {
        final fallbackName = firebaseUser.displayName?.trim().isNotEmpty == true
            ? firebaseUser.displayName!.trim()
            : firebaseUser.email?.trim().split('@').first ?? 'Student';

        final created = await createUserDocument(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: fallbackName,
          firstName: _splitName(fallbackName).$1,
          lastName: _splitName(fallbackName).$2,
          emailVerified: firebaseUser.emailVerified,
        );

        if (created is AuthSuccess<AuthUser>) {
          return created.data;
        }

        return null;
      }

      return _authUserFromSnapshot(snapshot);
    } on FirebaseException {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> _sendBrevoOtpEmail({
    required String email,
    required String name,
    required String otp,
    required String purpose,
    required DateTime expiresAt,
  }) async {
    await _brevoEmailService.sendOtpEmail(
      email: email,
      name: name,
      otp: otp,
      purpose: purpose,
      expiresAt: expiresAt,
    );
  }

  bool _isAllowedEmail(String email) {
    final allowedDomains = AppEnv.read('ALLOWED_EMAIL_DOMAINS');
    if (allowedDomains.isEmpty) {
      return true;
    }

    final normalized = email.trim().toLowerCase();
    final domains = allowedDomains
        .split(',')
        .map((entry) => entry.trim().toLowerCase())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);

    return domains.any((domain) => normalized.endsWith('@$domain'));
  }

  String _generateOtp() {
    final random = Random.secure();
    final value = random.nextInt(900000) + 100000;
    return value.toString();
  }

  AuthUser? _authUserFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    return AuthUser(
      uid: data['uid'] as String? ?? snapshot.id,
      email: (data['email'] as String?)?.trim() ?? '',
      name: _resolveName(data),
      firstName: _resolveFirstName(data),
      lastName: _resolveLastName(data),
      studentId: (data['studentId'] as String?)?.trim().isNotEmpty == true
          ? (data['studentId'] as String).trim()
          : '',
      role: (data['role'] as String?)?.trim().isNotEmpty == true
          ? (data['role'] as String).trim()
          : 'student',
      emailVerified: data['emailVerified'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      lastLoginAt: _parseDateOrNull(data['lastLoginAt']),
      department: (data['department'] as String?)?.trim(),
      phoneNumber: (data['phoneNumber'] as String?)?.trim(),
      photoUrl: (data['photoUrl'] as String?)?.trim(),
    );
  }

  (String, String) _splitName(
    String name, {
    String? firstName,
    String? lastName,
  }) {
    final resolvedFirst = firstName?.trim() ?? '';
    final resolvedLast = lastName?.trim() ?? '';
    if (resolvedFirst.isNotEmpty || resolvedLast.isNotEmpty) {
      return (resolvedFirst, resolvedLast);
    }

    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return ('', '');
    }
    if (parts.length == 1) {
      return (parts.first, '');
    }
    return (parts.first, parts.sublist(1).join(' '));
  }

  String _resolveName(Map<String, dynamic> data) {
    final firstName = (data['firstName'] as String?)?.trim() ?? '';
    final lastName = (data['lastName'] as String?)?.trim() ?? '';
    final combined = [firstName, lastName]
        .where((part) => part.isNotEmpty)
        .join(' ')
        .trim();
    if (combined.isNotEmpty) {
      return combined;
    }

    final name = (data['name'] as String?)?.trim();
    return (name != null && name.isNotEmpty) ? name : 'Student';
  }

  String _resolveFirstName(Map<String, dynamic> data) {
    final firstName = (data['firstName'] as String?)?.trim();
    if (firstName != null && firstName.isNotEmpty) {
      return firstName;
    }

    return _splitName(_resolveName(data)).$1;
  }

  String _resolveLastName(Map<String, dynamic> data) {
    final lastName = (data['lastName'] as String?)?.trim();
    if (lastName != null && lastName.isNotEmpty) {
      return lastName;
    }

    return _splitName(_resolveName(data)).$2;
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

  AuthErrorType _mapAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return AuthErrorType.invalidEmail;
      case 'weak-password':
        return AuthErrorType.weakPassword;
      case 'email-already-in-use':
        return AuthErrorType.emailAlreadyInUse;
      case 'wrong-password':
      case 'invalid-credential':
        return AuthErrorType.invalidCredential;
      case 'user-not-found':
        return AuthErrorType.userNotFound;
      case 'user-disabled':
        return AuthErrorType.userDisabled;
      case 'too-many-requests':
        return AuthErrorType.tooManyRequests;
      case 'operation-not-allowed':
        return AuthErrorType.operationNotAllowed;
      case 'network-request-failed':
        return AuthErrorType.network;
      default:
        return AuthErrorType.unknown;
    }
  }

  AuthErrorType _mapFirestoreException(FirebaseException exception) {
    switch (exception.code) {
      case 'permission-denied':
        return AuthErrorType.operationNotAllowed;
      case 'not-found':
        return AuthErrorType.otpNotFound;
      case 'unavailable':
        return AuthErrorType.network;
      case 'deadline-exceeded':
        return AuthErrorType.network;
      default:
        return AuthErrorType.unknown;
    }
  }

  AuthErrorType _mapFunctionsException(FirebaseFunctionsException exception) {
    final code = exception.code.toLowerCase();
    if (code.contains('not-found')) {
      return AuthErrorType.userNotFound;
    }
    if (code.contains('permission-denied')) {
      return AuthErrorType.otpInvalid;
    }
    if (code.contains('deadline-exceeded')) {
      return AuthErrorType.otpExpired;
    }
    if (code.contains('resource-exhausted')) {
      return AuthErrorType.otpTooManyAttempts;
    }
    if (code.contains('failed-precondition')) {
      return AuthErrorType.otpAlreadyUsed;
    }
    if (code.contains('invalid-argument')) {
      return AuthErrorType.invalidEmail;
    }
    return AuthErrorType.unknown;
  }

  String _messageForAuthException(FirebaseAuthException exception) {
    switch (_mapAuthException(exception)) {
      case AuthErrorType.invalidEmail:
        return 'Enter a valid university email address.';
      case AuthErrorType.weakPassword:
        return 'Password must be at least 6 characters long.';
      case AuthErrorType.emailAlreadyInUse:
        return 'This email is already registered.';
      case AuthErrorType.invalidCredential:
      case AuthErrorType.wrongPassword:
        return 'Incorrect email or password.';
      case AuthErrorType.userNotFound:
        return 'No account found for this email.';
      case AuthErrorType.userDisabled:
        return 'This account has been disabled.';
      case AuthErrorType.tooManyRequests:
        return 'Too many attempts. Please try again later.';
      case AuthErrorType.operationNotAllowed:
        return 'This sign-in method is disabled.';
      case AuthErrorType.network:
        return 'Network error. Please check your connection.';
      case AuthErrorType.unknown:
      case AuthErrorType.emailNotAllowed:
      case AuthErrorType.otpNotFound:
      case AuthErrorType.otpInvalid:
      case AuthErrorType.otpExpired:
      case AuthErrorType.otpTooManyAttempts:
      case AuthErrorType.otpAlreadyUsed:
      case AuthErrorType.invalidVerificationId:
      case AuthErrorType.documentCreationFailed:
      case AuthErrorType.emailVerificationRequired:
      case AuthErrorType.accountNotVerified:
        return exception.message ?? 'Authentication failed. Please try again.';
    }
  }
}
