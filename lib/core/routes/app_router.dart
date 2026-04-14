import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/ui/sams_ui_tokens.dart';
import '../../features/attendance/presentation/screens/attendance_detail_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/bus/presentation/screens/bus_screen.dart';
import '../../features/hostel/presentation/screens/hostel_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/messages/presentation/screens/messages_screen.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../../features/help_desk/presentation/screens/help_desk_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/privacy_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/session_screen.dart';

class AppRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const signup = 'signup';

  static const home = 'home';
  static const attendanceDetail = 'attendanceDetail';
  static const messages = 'messages';
  static const scan = 'scan';
  static const helpDesk = 'helpDesk';
  static const helpDeskRaise = 'helpDeskRaise';
  static const menu = 'menu';
  static const session = 'session';
  static const changePassword = 'changePassword';
  static const privacy = 'privacy';
  static const bus = 'bus';
  static const hostel = 'hostel';
}

class AppRoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';

  static const home = '/home';
  static const attendanceDetail = '/home/attendance';
  static const messages = '/messages';
  static const scan = '/scan';
  static const helpDesk = '/help-desk';
  static const helpDeskRaise = '/help-desk/raise-concern';
  static const menu = '/menu';
  static const session = '/menu/session';
  static const changePassword = '/menu/change-password';
  static const privacy = '/menu/privacy';
  static const bus = '/menu/bus';
  static const hostel = '/menu/hostel';
}

class AppRouter {
  static GoRouter get router => GoRouter(
    initialLocation: AppRoutePaths.splash,
    routes: [
      GoRoute(
        path: AppRoutePaths.splash,
        name: AppRouteNames.splash,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.signup,
        name: AppRouteNames.signup,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          state: state,
          child: const SignUpScreen(),
        ),
      ),

      // Main app shell (persistent bottom navigation)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                name: AppRouteNames.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'attendance',
                    name: AppRouteNames.attendanceDetail,
                    pageBuilder: (context, state) => _buildSlideTransitionPage(
                      state: state,
                      child: const AttendanceDetailScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.messages,
                name: AppRouteNames.messages,
                builder: (context, state) => const MessagesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.scan,
                name: AppRouteNames.scan,
                builder: (context, state) => const ScanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.helpDesk,
                name: AppRouteNames.helpDesk,
                builder: (context, state) => const HelpDeskScreen(),
                routes: [
                  GoRoute(
                    path: 'raise-concern',
                    name: AppRouteNames.helpDeskRaise,
                    pageBuilder: (context, state) => _buildSlideTransitionPage(
                      state: state,
                      child: const RaiseConcernScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.menu,
                name: AppRouteNames.menu,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'session',
                    name: AppRouteNames.session,
                    pageBuilder: (context, state) => _buildSlideTransitionPage(
                      state: state,
                      child: const SessionScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'change-password',
                    name: AppRouteNames.changePassword,
                    pageBuilder: (context, state) => _buildSlideTransitionPage(
                      state: state,
                      child: const ChangePasswordScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'privacy',
                    name: AppRouteNames.privacy,
                    pageBuilder: (context, state) => _buildSlideTransitionPage(
                      state: state,
                      child: const PrivacyScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'bus',
                    name: AppRouteNames.bus,
                    pageBuilder: (context, state) => _buildSlideTransitionPage(
                      state: state,
                      child: const BusScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'hostel',
                    name: AppRouteNames.hostel,
                    pageBuilder: (context, state) => _buildSlideTransitionPage(
                      state: state,
                      child: const HostelScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage<void> _buildFadeTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: SamsUiTokens.pageAnimation,
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final scale = Tween<double>(begin: 0.985, end: 1).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: scale,
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _buildSlideTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: SamsUiTokens.pageAnimation,
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0.12, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return SlideTransition(
        position: animation.drive(offset),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
