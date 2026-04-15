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

  testWidgets('Splash shows branding then auto-navigates to Login in ~3s', (
    WidgetTester tester,
  ) async {
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

  testWidgets('Dummy login goes to MainShell Home as initial tab', (
    WidgetTester tester,
  ) async {
    await pumpToLogin(tester);

    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

    expect(find.text('Daily Essentials'), findsOneWidget);
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Bottom navigation switches across all tabs smoothly', (
    WidgetTester tester,
  ) async {
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

    await tester.drag(find.byType(ListView).first, const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(find.text('Raise a complaint'), findsOneWidget);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Mahmoud Bakir'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Daily Essentials'), findsOneWidget);
  });

  testWidgets('Help Desk can push Raise Concern form and return', (
    WidgetTester tester,
  ) async {
    await pumpToLogin(tester);
    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

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
    await pumpToLogin(tester);
    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

    final scheduleCard = find.text('Schedule').first;
    expect(scheduleCard, findsOneWidget);

    await tester.tap(scheduleCard);
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
    await pumpToLogin(tester);
    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

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
    await pumpToLogin(tester);
    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -420));
    await tester.pumpAndSettle();

    final hostelOption = find.text('Switch to SAMS Hostel').hitTestable();
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

      await tester.tap(find.text('Switch'));
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

      await tester.tap(find.text('Switch'));
      await tester.pumpAndSettle();
      expect(find.text('Hostel services & requests'), findsOneWidget);
    },
  );

  testWidgets('Settings dark mode applies app theme immediately', (
    WidgetTester tester,
  ) async {
    await pumpToLogin(tester);
    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

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
    await pumpToLogin(tester);
    await tester.tap(find.text('Sign-in with QR code'));
    await tester.pumpAndSettle();

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
}
