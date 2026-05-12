import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sams_student_portal/core/constants/portal_courses.dart';
import 'package:sams_student_portal/core/runtime/app_runtime.dart';
import 'package:sams_student_portal/features/home/data/models/home_dashboard_model.dart';
import 'package:sams_student_portal/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:sams_student_portal/features/home/domain/repositories/home_repository.dart';
import 'package:sams_student_portal/main.dart';

import 'package:sams_student_portal/features/auth/domain/entities/auth_error.dart';
import 'package:sams_student_portal/features/auth/domain/entities/auth_result.dart';
import 'package:sams_student_portal/features/auth/domain/entities/auth_user.dart';
import 'package:sams_student_portal/features/auth/domain/repositories/auth_repository.dart';
import 'package:sams_student_portal/features/auth/presentation/cubit/auth_cubit.dart';

class _TestAuthRepository implements AuthRepository {
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
    return const AuthFailure<AuthUser>(
      type: AuthErrorType.unknown,
      message: 'Not implemented in widget tests.',
    );
  }

  @override
  Future<AuthUser?> getCurrentUser() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthResult<AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return const AuthFailure<AuthUser>(
      type: AuthErrorType.unknown,
      message: 'Not implemented in widget tests.',
    );
  }

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
    return const AuthFailure<AuthUser>(
      type: AuthErrorType.unknown,
      message: 'Not implemented in widget tests.',
    );
  }

  @override
  Future<AuthResult<void>> sendOtp({
    required String email,
    required String name,
    required String purpose,
  }) async {
    return const AuthFailure<void>(
      type: AuthErrorType.unknown,
      message: 'Not implemented in widget tests.',
    );
  }

  @override
  Future<AuthResult<AuthUser>> verifyOtp({
    required String verificationId,
    required String otp,
    String? purposeHint,
  }) async {
    return const AuthFailure<AuthUser>(
      type: AuthErrorType.unknown,
      message: 'Not implemented in widget tests.',
    );
  }
}

class _AuthedTestAuthRepository implements AuthRepository {
  static final _user = AuthUser(
    uid: 'test-uid',
    email: 'student@sams.edu.eg',
    name: 'Mahmoud Bakir',
    firstName: 'Mahmoud',
    lastName: 'Bakir',
    studentId: 'SAM-1001',
    role: 'student',
    emailVerified: true,
    isActive: true,
    createdAt: DateTime.utc(2024, 1, 1),
    updatedAt: DateTime.utc(2024, 1, 2),
  );

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
    return AuthSuccess<AuthUser>(_user);
  }

  @override
  Future<AuthUser?> getCurrentUser() async => _user;

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthResult<AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return AuthSuccess<AuthUser>(_user);
  }

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
    return AuthSuccess<AuthUser>(_user);
  }

  @override
  Future<AuthResult<void>> sendOtp({
    required String email,
    required String name,
    required String purpose,
  }) async {
    return const AuthFailure<void>(
      type: AuthErrorType.unknown,
      message: 'Not implemented in widget tests.',
    );
  }

  @override
  Future<AuthResult<AuthUser>> verifyOtp({
    required String verificationId,
    required String otp,
    String? purposeHint,
  }) async {
    return AuthSuccess<AuthUser>(_user);
  }
}

/// In-memory home dashboard so widget tests do not require Firestore.
class _WidgetTestHomeRepository implements HomeRepository {
  @override
  Future<HomeDashboardEntity> getDashboard() async {
    final courseAttendance = PortalCourses.curriculum
        .map((name) => {'subject': name, 'percentage': 82})
        .toList(growable: false);
    return HomeDashboardModel(
      studentName: 'Mahmoud Bakir',
      studentId: 'SAM-1001',
      attendancePercent: 78,
      attendanceSubtitle: 'Management Sciences • Live term overview',
      attendedClassesLabel: '4 tracked subjects • 78% overall',
      busRouteLabel: 'SAMS Shuttle 03 • Maadi → Ramses',
      busStatusLabel: 'Status: Arriving at Gate 2 (Maadi Campus)',
      announcements: HomeDashboardModel.fake().announcements,
      courseAttendance: courseAttendance,
    );
  }
}

Future<AuthCubit> _createTestAuthCubit() async {
  final cubit = AuthCubit(repository: _TestAuthRepository());
  await cubit.bootstrap();
  return cubit;
}

Future<AuthCubit> _createAuthedTestAuthCubit() async {
  final cubit = AuthCubit(repository: _AuthedTestAuthRepository());
  await cubit.bootstrap();
  return cubit;
}

void main() {
  setUp(() {
    AppRuntime.homeRepositoryOverride = _WidgetTestHomeRepository();
  });

  tearDown(() {
    AppRuntime.homeRepositoryOverride = null;
  });

  Future<void> pumpToLogin(WidgetTester tester) async {
    final authCubit = await _createTestAuthCubit();
    await tester.pumpWidget(SamsApp(authCubit: authCubit));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  Future<void> pumpToHome(WidgetTester tester) async {
    final authCubit = await _createAuthedTestAuthCubit();
    await tester.pumpWidget(SamsApp(authCubit: authCubit));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets('Splash shows branding then navigates to OTP login', (
    WidgetTester tester,
  ) async {
    final authCubit = await _createTestAuthCubit();
    await tester.pumpWidget(SamsApp(authCubit: authCubit));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Image), findsWidgets);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.text('University email'), findsOneWidget);
  });

  testWidgets('Login can navigate to Sign Up', (WidgetTester tester) async {
    await pumpToLogin(tester);

    await tester.tap(find.text('Create a new account'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Send verification code'), findsOneWidget);
  });

  testWidgets('Authed user lands on MainShell Home', (WidgetTester tester) async {
    await pumpToHome(tester);

    expect(find.text('Daily Essentials'), findsOneWidget);
    expect(find.text('Announcements'), findsWidgets);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Bottom navigation switches across all tabs smoothly', (
    WidgetTester tester,
  ) async {
    await pumpToHome(tester);

    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('Search messages'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(find.text('Mark attendance'), findsOneWidget);

    await tester.tap(find.text('Help Desk'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(find.text('Raise a complaint'), findsOneWidget);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('SAMS Student Portal'), findsWidgets);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Daily Essentials'), findsOneWidget);
  });

  testWidgets('Help Desk can push Raise Concern form and return', (
    WidgetTester tester,
  ) async {
    await pumpToHome(tester);

    await tester.tap(find.text('Help Desk'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -420));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Raise a complaint'));
    await tester.pumpAndSettle();

    expect(find.text('Concerned Department'), findsOneWidget);
    expect(find.text('Your Concern'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -420));
    await tester.pumpAndSettle();

    expect(find.text('Raise a complaint'), findsOneWidget);
  });

  testWidgets('Home Schedule card opens Calendar screen', (
    WidgetTester tester,
  ) async {
    await pumpToHome(tester);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();

    final scheduleFinder = find.text('Schedule').first;
    await tester.dragUntilVisible(
      scheduleFinder,
      find.byType(Scrollable).first,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.tap(scheduleFinder);
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsWidgets);
    expect(
      find.textContaining('Swipe left or right to change month'),
      findsOneWidget,
    );
  });

  testWidgets('Profile Settings route opens Settings screen', (
    WidgetTester tester,
  ) async {
    await pumpToHome(tester);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    final settingsOption = find.text('Settings').hitTestable();
    expect(settingsOption, findsOneWidget);

    await tester.tap(settingsOption);
    await tester.pumpAndSettle();

    expect(find.text('Smart Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
  });

  testWidgets('Hostel detail routes open all detail screens', (
    WidgetTester tester,
  ) async {
    await pumpToHome(tester);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -420));
    await tester.pumpAndSettle();

    final hostelOption = find.text('Hostel').hitTestable();
    await tester.tap(hostelOption, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();

    Future<void> openAndAssertDetail({
      required String menuItem,
      required String screenTitle,
    }) async {
      final menuText = find.text(menuItem).first;
      await tester.ensureVisible(menuText);
      await tester.pumpAndSettle();

      final menuEntry = find.text(menuItem).hitTestable();
      expect(menuEntry, findsOneWidget);

      await tester.tap(menuEntry);
      await tester.pumpAndSettle();

      expect(find.text('Hostel services & requests'), findsNothing);
      expect(find.text(screenTitle), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Hostel services & requests'), findsOneWidget);
    }

    await openAndAssertDetail(
      menuItem: 'Leave Permission',
      screenTitle: 'Leave Permission',
    );
    await openAndAssertDetail(
      menuItem: 'Fee Receipt',
      screenTitle: 'Fee Receipt',
    );
    await openAndAssertDetail(
      menuItem: 'Mess Feedback',
      screenTitle: 'Mess Feedback',
    );
    await openAndAssertDetail(
      menuItem: 'Maintenance Request',
      screenTitle: 'Maintenance Request',
    );
  });

  testWidgets(
    'Profile internal navigations to Bus and Hostel work without errors',
    (WidgetTester tester) async {
      await pumpToHome(tester);

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -420));
      await tester.pumpAndSettle();

      final busOption = find.text('Bus').hitTestable();
      await tester.tap(busOption, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Switch'));
      await tester.pumpAndSettle();
      expect(find.text('Live Route'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -220));
      await tester.pumpAndSettle();

      final hostelOption = find.text('Hostel').hitTestable();
      expect(hostelOption, findsOneWidget);

      await tester.tap(hostelOption);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Switch'));
      await tester.pumpAndSettle();
      expect(find.text('Hostel services & requests'), findsOneWidget);
    },
  );

  testWidgets('Settings dark mode applies app theme immediately', (
    WidgetTester tester,
  ) async {
    await pumpToHome(tester);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    final settingsOption = find.text('Settings').hitTestable();
    await tester.tap(settingsOption);
    await tester.pumpAndSettle();

    final appBefore = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(appBefore.themeMode, ThemeMode.light);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final appAfter = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(appAfter.themeMode, ThemeMode.dark);
  });

  testWidgets('Settings language change applies locale immediately', (
    WidgetTester tester,
  ) async {
    await pumpToHome(tester);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    final settingsOption = find.text('Settings').hitTestable();
    await tester.tap(settingsOption);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arabic').last);
    await tester.pumpAndSettle();

    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });

  testWidgets('Announcements tab is read-only without create action', (
    WidgetTester tester,
  ) async {
    await pumpToHome(tester);

    await tester.tap(find.text('Announcements').last);
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
