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
  final Map<String, _DevOtpChallenge> _devOtpChallenges = {};

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
      final result = await _requestSignupOtpViaCallable(
        email: email.trim(),
        name: name.trim(),
        firstName: firstName?.trim(),
        lastName: lastName?.trim(),
        studentId: studentId?.trim(),
        department: department?.trim(),
      );

      if (kDebugMode && result is AuthFailure<AuthUser>) {
        return _createDevOtpChallenge<AuthUser>(
          email: email.trim(),
          name: name.trim().isNotEmpty ? name.trim() : 'Student',
          purpose: 'signup',
          debugReason:
              'signup callable returned ${result.type}: ${result.message}',
        );
      }

      if (result is AuthSuccess<AuthUser>) {
        return result;
      }

      if (result is AuthOtpChallenge<AuthUser>) {
        return result;
      }

      if (result is AuthFailure<AuthUser>) {
        return result;
      }

      return const AuthFailure<AuthUser>(
        type: AuthErrorType.unknown,
        message: 'Could not start email verification.',
      );
    } on FirebaseException catch (error) {
      debugPrint('[FIREBASE ERROR] code: \\${error.code}, message: \\${error.message}');
      debugPrint('[FIREBASE DEBUG] ProjectId: \\${FirebaseAuth.instance.app.options.projectId}');
      return AuthFailure<AuthUser>(
        type: _mapFirestoreException(error),
        message: '${error.message ?? 'Could not create your account. Please try again.'}\n[code: ${error.code}]',
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
    final allowDevFallback = kDebugMode;

    if (purpose.trim().toLowerCase() == 'login') {
      try {
        final result = await _requestLoginOtpViaCallable(
          email: email.trim(),
          name: name.trim(),
        );

        if (allowDevFallback && result is AuthFailure<void>) {
          return _createDevOtpChallenge<void>(
            email: email.trim(),
            name: name.trim().isNotEmpty ? name.trim() : 'Student',
            purpose: 'login',
            debugReason:
                'login callable returned ${result.type}: ${result.message}',
          );
        }

        return result;
      } catch (error) {
        if (allowDevFallback) {
          return _createDevOtpChallenge<void>(
            email: email.trim(),
            name: name.trim().isNotEmpty ? name.trim() : 'Student',
            purpose: 'login',
            debugReason: 'login callable fallback: $error',
          );
        }

        return AuthFailure<void>(
          type: AuthErrorType.operationNotAllowed,
          message:
              'Login OTP could not be sent. The usual causes are: '
              '1) requestLoginOtp is not deployed, 2) Brevo server env vars are missing, '
              '3) the email does not exist in Firebase Auth, or 4) the network is blocked. '
              'Check the function logs and server config, then try again.',
        );
      }
    }

    if (kDebugMode && AppEnv.read('OTP_DEV_FALLBACK') == 'true') {
      return _createDevOtpChallenge(
        email: email.trim(),
        name: name.trim().isNotEmpty ? name.trim() : 'Student',
        purpose: purpose.trim().toLowerCase(),
        debugReason: 'debug OTP fallback',
      );
    }

    final verificationId = _otpChallenges.doc().id;
    final otp = _generateOtp();
    if (kDebugMode) {
      debugPrint('[DEV OTP] verificationId=$verificationId email=$email otp=$otp');
    }
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

  Future<AuthResult<void>> _requestLoginOtpViaCallable({
    required String email,
    required String name,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('requestLoginOtp');
    final result = await callable.call({
      'email': email,
      'name': name,
      'purpose': 'login',
      'brevoApiKey': AppEnv.read('BREVO_API_KEY'),
      'brevoSenderEmail': AppEnv.read('BREVO_SENDER_EMAIL'),
      'brevoSenderName': AppEnv.read('BREVO_SENDER_NAME', fallback: 'SAMS Portal'),
      'brevoTemplateId': AppEnv.read('BREVO_TEMPLATE_ID'),
    });

    final raw = result.data;
    if (raw is! Map) {
      return const AuthFailure<void>(
        type: AuthErrorType.unknown,
        message: 'Login service returned an unexpected response.',
      );
    }

    final verificationId = raw['verificationId'] as String? ?? '';
    final returnedEmail = raw['email'] as String? ?? email;
    final returnedName = raw['name'] as String? ?? name;
    final expiresAtRaw = raw['expiresAt'];
    final expiresAt = expiresAtRaw is String
        ? DateTime.tryParse(expiresAtRaw)?.toUtc() ?? DateTime.now().toUtc().add(const Duration(minutes: 10))
        : DateTime.now().toUtc().add(const Duration(minutes: 10));
    final attemptsRemaining = raw['attemptsRemaining'] is int
        ? raw['attemptsRemaining'] as int
        : 5;

    if (verificationId.isEmpty) {
      return const AuthFailure<void>(
        type: AuthErrorType.unknown,
        message: 'Login service returned an empty verification id.',
      );
    }

    return AuthOtpChallenge<void>(
      verificationId: verificationId,
      email: returnedEmail,
      name: returnedName,
      expiresAt: expiresAt,
      attemptsRemaining: attemptsRemaining,
    );
  }

  @override
  Future<AuthResult<AuthUser>> verifyOtp({
    required String verificationId,
    required String otp,
    String? purposeHint,
  }) async {
    final hint = purposeHint?.trim().toLowerCase();
    if (hint == 'signup') {
      return _verifySignupOtpWithCallable(verificationId: verificationId, otp: otp);
    }

    if (kDebugMode) {
      final devChallenge = _devOtpChallenges[verificationId.trim()];
      if (devChallenge != null && !devChallenge.consumed) {
        if (DateTime.now().toUtc().isAfter(devChallenge.expiresAt)) {
          _devOtpChallenges.remove(verificationId.trim());
          return const AuthFailure<AuthUser>(
            type: AuthErrorType.otpExpired,
            message: 'This verification code expired. Please request a new one.',
          );
        }

        if (devChallenge.otp != otp.trim()) {
          devChallenge.attempts += 1;
          if (devChallenge.attempts >= devChallenge.maxAttempts) {
            _devOtpChallenges.remove(verificationId.trim());
            return const AuthFailure<AuthUser>(
              type: AuthErrorType.otpTooManyAttempts,
              message: 'Too many failed attempts. Please request a new verification code.',
            );
          }

          return const AuthFailure<AuthUser>(
            type: AuthErrorType.otpInvalid,
            message: 'Invalid verification code. Please try again.',
          );
        }

        devChallenge.consumed = true;
        _devOtpChallenges.remove(verificationId.trim());
        final resolvedName = devChallenge.name.isNotEmpty
            ? devChallenge.name
            : devChallenge.email.split('@').first;
        final localUser = AuthUser(
          uid: 'dev-${verificationId.trim()}',
          email: devChallenge.email,
          name: resolvedName,
          firstName: _splitName(resolvedName).$1,
          lastName: _splitName(resolvedName).$2,
          studentId: '',
          role: 'student',
          emailVerified: true,
          isActive: true,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
          lastLoginAt: DateTime.now().toUtc(),
        );

        try {
          final credential = await _firebaseAuth.signInAnonymously();
          final firebaseUser = credential.user;
          if (firebaseUser != null) {
            final created = await createUserDocument(
              uid: firebaseUser.uid,
              email: devChallenge.email,
              name: resolvedName,
              firstName: _splitName(resolvedName).$1,
              lastName: _splitName(resolvedName).$2,
              studentId: '',
              emailVerified: true,
            );
            if (created is AuthSuccess<AuthUser>) {
              return AuthSuccess<AuthUser>(created.data);
            }

            final signedInUser = await getCurrentUser();
            if (signedInUser != null) {
              return AuthSuccess<AuthUser>(signedInUser);
            }
          }
        } catch (_) {
          // Fall back to the local auth user if anonymous sign-in is unavailable.
        }

        return AuthSuccess<AuthUser>(localUser);
      }
    }

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

  AuthOtpChallenge<T> _createDevOtpChallenge<T>({
    required String email,
    required String name,
    required String purpose,
    required String debugReason,
  }) {
    final verificationId = 'dev-${DateTime.now().microsecondsSinceEpoch}';
    final otp = _generateOtp();
    final expiresAt = DateTime.now().toUtc().add(const Duration(minutes: 10));

    _devOtpChallenges[verificationId] = _DevOtpChallenge(
      verificationId: verificationId,
      email: email,
      name: name,
      purpose: purpose,
      otp: otp,
      expiresAt: expiresAt,
      attempts: 0,
      maxAttempts: 5,
    );

    debugPrint('[DEV OTP] $debugReason verificationId=$verificationId email=$email otp=$otp');

    return AuthOtpChallenge<T>(
      verificationId: verificationId,
      email: email,
      name: name,
      expiresAt: expiresAt,
      attemptsRemaining: 5,
      debugOtp: otp,
    );
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
      await _firebaseAuth.authStateChanges()
          .firstWhere((user) => user != null)
          .timeout(const Duration(seconds: 5), onTimeout: () => _firebaseAuth.currentUser);

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
      if (kDebugMode) {
        try {
          // Development fallback: validate OTP directly from Firestore and
          // sign in anonymously so local testing works without deployed functions.
          final docRef = _otpChallenges.doc(verificationId.trim());
          final snapshot = await docRef.get();
          if (!snapshot.exists) {
            return const AuthFailure<AuthUser>(
              type: AuthErrorType.invalidVerificationId,
              message: 'OTP session was not found. Please request a new code.',
            );
          }

          final data = snapshot.data() ?? <String, dynamic>{};
          final storedOtp = (data['otp'] as String?)?.trim() ?? '';
          if (storedOtp != otp.trim()) {
            await docRef.update({'attempts': FieldValue.increment(1)});
            return const AuthFailure<AuthUser>(
              type: AuthErrorType.otpInvalid,
              message: 'Invalid verification code. Please try again.',
            );
          }

          await docRef.update({
            'consumed': true,
            'verifiedAt': FieldValue.serverTimestamp(),
          });

          final email = (data['email'] as String?)?.trim() ?? '';
          final name = (data['name'] as String?)?.trim() ?? '';

          // Create an anonymous Firebase user for local testing and persist
          // a corresponding user document so the app can proceed.
          final credential = await _firebaseAuth.signInAnonymously();
          final firebaseUser = credential.user;
          if (firebaseUser == null) {
            return const AuthFailure<AuthUser>(
              type: AuthErrorType.unknown,
              message: 'Could not sign in anonymously for testing.',
            );
          }

          await _firebaseAuth.authStateChanges()
              .firstWhere((user) => user != null)
              .timeout(const Duration(seconds: 5), onTimeout: () => _firebaseAuth.currentUser);

          final created = await createUserDocument(
            uid: firebaseUser.uid,
            email: email,
            name: name.isNotEmpty ? name : (email.split('@').first),
            emailVerified: true,
          );

          if (created is AuthSuccess<AuthUser>) {
            return AuthSuccess<AuthUser>(created.data);
          }

          final currentUser = await getCurrentUser();
          if (currentUser == null) {
            return const AuthFailure<AuthUser>(
              type: AuthErrorType.userNotFound,
              message: 'Your verified account was not found.',
            );
          }
          return AuthSuccess<AuthUser>(currentUser);
        } catch (e) {
          return AuthFailure<AuthUser>(
            type: AuthErrorType.unknown,
            message: 'Dev OTP fallback failed: ${e.toString()}',
          );
        }
      }

      return AuthFailure<AuthUser>(
        type: AuthErrorType.unknown,
        message:
            'OTP login requires the exchangeLoginOtp Cloud Function. '
            'Deploy functions/ (see repository docs) or check your connection. '
            '(${error.toString()})',
      );
    }
  }

  Future<AuthResult<AuthUser>> _verifySignupOtpWithCallable({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('exchangeSignupOtp');
      final result = await callable.call({
        'verificationId': verificationId.trim(),
        'otp': otp.trim(),
      });

      final raw = result.data;
      if (raw is! Map) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.unknown,
          message: 'Signup service returned an unexpected response.',
        );
      }

      final token = raw['customToken'] as String?;
      if (token == null || token.isEmpty) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.unknown,
          message: 'Signup service returned an empty token.',
        );
      }

      await _firebaseAuth.signInWithCustomToken(token);

      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return const AuthFailure<AuthUser>(
          type: AuthErrorType.userNotFound,
          message: 'Your account profile was not found after sign-up.',
        );
      }

      return AuthSuccess<AuthUser>(currentUser);
    } on FirebaseFunctionsException catch (error) {
      return AuthFailure<AuthUser>(
        type: _mapFunctionsException(error),
        message: error.message ?? 'Could not complete OTP sign-up.',
      );
    } catch (error) {
      return AuthFailure<AuthUser>(
        type: AuthErrorType.unknown,
        message:
            'OTP sign-up requires the exchangeSignupOtp Cloud Function. '
            'Deploy functions/ or check your connection. '
            '(${error.toString()})',
      );
    }
  }

  Future<AuthResult<AuthUser>> _requestSignupOtpViaCallable({
    required String email,
    required String name,
    required String? firstName,
    required String? lastName,
    required String? studentId,
    required String? department,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('requestSignupOtp');
    final result = await callable.call({
      'email': email,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'studentId': studentId,
      'department': department,
      'purpose': 'signup',
      'brevoApiKey': AppEnv.read('BREVO_API_KEY'),
      'brevoSenderEmail': AppEnv.read('BREVO_SENDER_EMAIL'),
      'brevoSenderName': AppEnv.read('BREVO_SENDER_NAME', fallback: 'SAMS Portal'),
      'brevoTemplateId': AppEnv.read('BREVO_TEMPLATE_ID'),
    });

    final raw = result.data;
    if (raw is! Map) {
      return const AuthFailure<AuthUser>(
        type: AuthErrorType.unknown,
        message: 'Signup service returned an unexpected response.',
      );
    }

    final verificationId = raw['verificationId'] as String? ?? '';
    final returnedEmail = raw['email'] as String? ?? email;
    final returnedName = raw['name'] as String? ?? name;
    final expiresAtRaw = raw['expiresAt'];
    final expiresAt = expiresAtRaw is String
        ? DateTime.tryParse(expiresAtRaw)?.toUtc() ?? DateTime.now().toUtc().add(const Duration(minutes: 10))
        : DateTime.now().toUtc().add(const Duration(minutes: 10));
    final attemptsRemaining = raw['attemptsRemaining'] is int
        ? raw['attemptsRemaining'] as int
        : 5;

    if (verificationId.isEmpty) {
      return const AuthFailure<AuthUser>(
        type: AuthErrorType.unknown,
        message: 'Signup service returned an empty verification id.',
      );
    }

    return AuthOtpChallenge<AuthUser>(
      verificationId: verificationId,
      email: returnedEmail,
      name: returnedName,
      expiresAt: expiresAt,
      attemptsRemaining: attemptsRemaining,
    );
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
    if (code.contains('already-exists')) {
      return AuthErrorType.emailAlreadyInUse;
    }
    if (code.contains('unavailable')) {
      return AuthErrorType.network;
    }
    return AuthErrorType.unknown;
  }
}

class _DevOtpChallenge {
  _DevOtpChallenge({
    required this.verificationId,
    required this.email,
    required this.name,
    required this.purpose,
    required this.otp,
    required this.expiresAt,
    required this.attempts,
    required this.maxAttempts,
  });

  final String verificationId;
  final String email;
  final String name;
  final String purpose;
  final String otp;
  final DateTime expiresAt;
  int attempts;
  final int maxAttempts;
  bool consumed = false;
}
