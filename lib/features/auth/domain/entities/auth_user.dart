import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.studentId,
    required this.role,
    required this.emailVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.department,
    this.phoneNumber,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String name;
  final String firstName;
  final String lastName;
  final String studentId;
  final String role;
  final bool emailVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final String? department;
  final String? phoneNumber;
  final String? photoUrl;

  bool get isStudent => role.toLowerCase() == 'student';

  bool get isAdmin => role.toLowerCase() == 'admin';

  String get fullName {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final combined = [firstName, lastName]
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim())
        .join(' ')
        .trim();
    if (combined.isNotEmpty) {
      return combined;
    }

    return 'SAMS Student';
  }

  AuthUser copyWith({
    String? name,
    String? firstName,
    String? lastName,
    String? studentId,
    String? role,
    bool? emailVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    String? department,
    String? phoneNumber,
    String? photoUrl,
  }) {
    return AuthUser(
      uid: uid,
      email: email,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      studentId: studentId ?? this.studentId,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      department: department ?? this.department,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    name,
    firstName,
    lastName,
    studentId,
    role,
    emailVerified,
    isActive,
    createdAt,
    updatedAt,
    lastLoginAt,
    department,
    phoneNumber,
    photoUrl,
  ];
}
