import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sams_student_portal/main.dart';

void main() {
  Future<void> pumpToLogin(WidgetTester tester) async {
    await tester.pumpWidget(const SamsApp());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('Splash shows branding then auto-navigates to Login in ~3s', (WidgetTester tester) async {
    await tester.pumpWidget(const SamsApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Image), findsWidgets);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Sign-in with QR code'), findsOneWidget);
    expect(find.text('Login manually'), findsOneWidget);
  });

  testWidgets('Login can navigate to Sign Up', (WidgetTester tester) async {
    await pumpToLogin(tester);

    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome.'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('Dummy login goes to MainShell Home as initial tab', (WidgetTester tester) async {
    await pumpToLogin(tester);

    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

    expect(find.text('Daily Essentials'), findsOneWidget);
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Bottom navigation switches across all tabs smoothly', (WidgetTester tester) async {
    await pumpToLogin(tester);
    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('Search messages'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(find.text('Scan QR Code'), findsOneWidget);

    await tester.tap(find.text('Help Desk'));
    await tester.pumpAndSettle();
    expect(find.text('Raise a complaint'), findsOneWidget);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
  expect(find.text('Mahmoud Bakir'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Daily Essentials'), findsOneWidget);
  });

  testWidgets('Help Desk can push Raise Concern form and return', (WidgetTester tester) async {
    await pumpToLogin(tester);
    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Help Desk'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Raise a complaint'));
    await tester.pumpAndSettle();

    expect(find.text('Concerned Department'), findsOneWidget);
    expect(find.text('Your Concern'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Raise a complaint'), findsOneWidget);
  });

  testWidgets('Profile internal navigations to Bus and Hostel work without errors', (WidgetTester tester) async {
    await pumpToLogin(tester);
    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -420));
    await tester.pumpAndSettle();

    final busOption = find.text('Switch to SAMS Bus').hitTestable();
    await tester.tap(busOption, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Live Route'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -220));
    await tester.pumpAndSettle();

    final hostelOption = find.text('Switch to SAMS Hostel').hitTestable();
    expect(hostelOption, findsOneWidget);

    await tester.tap(hostelOption);
    await tester.pumpAndSettle();
    expect(find.text('Hostel services & requests'), findsOneWidget);
  });
}
