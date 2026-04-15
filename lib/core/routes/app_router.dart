import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/attendance/presentation/screens/attendance_detail_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/bus/presentation/screens/bus_screen.dart';
import '../../features/hostel/presentation/screens/fee_receipt_detail_screen.dart';
import '../../features/hostel/presentation/screens/hostel_screen.dart';
import '../../features/hostel/presentation/screens/leave_permission_detail_screen.dart';
import '../../features/hostel/presentation/screens/maintenance_request_detail_screen.dart';
import '../../features/hostel/presentation/screens/mess_feedback_detail_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/messages/presentation/screens/messages_screen.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../../features/help_desk/presentation/screens/help_desk_screen.dart';
import '../../features/profile/presentation/screens/about_app_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/profile/presentation/screens/privacy_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/session_screen.dart';
import '../../features/profile/presentation/screens/terms_and_conditions_screen.dart';
import '../../features/home/presentation/screens/calendar_screen.dart';

const Duration _kRouteTransitionDuration = Duration(milliseconds: 300);
const Duration _kRouteReverseTransitionDuration = Duration(milliseconds: 220);

class AppRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const signup = 'signup';

  static const home = 'home';
  static const attendanceDetail = 'attendanceDetail';
  static const calendar = 'calendar';
  static const messages = 'messages';
  static const scan = 'scan';
  static const helpDesk = 'helpDesk';
  static const helpDeskRaise = 'helpDeskRaise';
  static const menu = 'menu';
  static const settings = 'settings';
  static const aboutApp = 'aboutApp';
  static const termsAndConditions = 'termsAndConditions';
  static const privacyPolicy = 'privacyPolicy';
  static const session = 'session';
  static const changePassword = 'changePassword';
  static const privacy = 'privacy';
  static const bus = 'bus';
  static const hostel = 'hostel';
  static const hostelLeavePermission = 'hostelLeavePermission';
  static const hostelFeeReceipt = 'hostelFeeReceipt';
  static const hostelMessFeedback = 'hostelMessFeedback';
  static const hostelMaintenanceRequest = 'hostelMaintenanceRequest';
}

class AppRoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';

  static const home = '/home';
  static const attendanceDetail = '/home/attendance';
  static const calendar = '/home/calendar';
  static const messages = '/messages';
  static const scan = '/scan';
  static const helpDesk = '/help-desk';
  static const helpDeskRaise = '/help-desk/raise-concern';
  static const menu = '/menu';
  static const settings = '/menu/settings';
  static const aboutApp = '/menu/settings/about-app';
  static const termsAndConditions = '/menu/settings/terms-and-conditions';
  static const privacyPolicy = '/menu/settings/privacy-policy';
  static const session = '/menu/session';
  static const changePassword = '/menu/change-password';
  static const privacy = '/menu/privacy';
  static const bus = '/menu/bus';
  static const hostel = '/menu/hostel';
  static const hostelLeavePermission = '/menu/hostel/leave-permission';
  static const hostelFeeReceipt = '/menu/hostel/fee-receipt';
  static const hostelMessFeedback = '/menu/hostel/mess-feedback';
  static const hostelMaintenanceRequest = '/menu/hostel/maintenance-request';
}

class AppRouter {
  static GoRouter createRouter() => GoRouter(
    initialLocation: AppRoutePaths.splash,
    routes: [
      GoRoute(
        path: AppRoutePaths.splash,
        name: AppRouteNames.splash,
        pageBuilder: (context, state) => _buildPrimaryTransitionPage(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        pageBuilder: (context, state) => _buildPrimaryTransitionPage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.signup,
        name: AppRouteNames.signup,
        pageBuilder: (context, state) => _buildPrimaryTransitionPage(
          state: state,
          child: const SignUpScreen(),
        ),
      ),

      // Main app shell (persistent bottom navigation)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                name: AppRouteNames.home,
                pageBuilder: (context, state) => _buildPrimaryTransitionPage(
                  state: state,
                  child: const HomeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'attendance',
                    name: AppRouteNames.attendanceDetail,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const AttendanceDetailScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'calendar',
                    name: AppRouteNames.calendar,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const CalendarScreen(),
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
                pageBuilder: (context, state) => _buildPrimaryTransitionPage(
                  state: state,
                  child: const MessagesScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.scan,
                name: AppRouteNames.scan,
                pageBuilder: (context, state) => _buildPrimaryTransitionPage(
                  state: state,
                  child: const ScanScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.helpDesk,
                name: AppRouteNames.helpDesk,
                pageBuilder: (context, state) => _buildPrimaryTransitionPage(
                  state: state,
                  child: const HelpDeskScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'raise-concern',
                    name: AppRouteNames.helpDeskRaise,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
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
                pageBuilder: (context, state) => _buildPrimaryTransitionPage(
                  state: state,
                  child: const ProfileScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: AppRouteNames.settings,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const SettingsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'settings/about-app',
                    name: AppRouteNames.aboutApp,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const AboutAppScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'settings/terms-and-conditions',
                    name: AppRouteNames.termsAndConditions,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const TermsAndConditionsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'settings/privacy-policy',
                    name: AppRouteNames.privacyPolicy,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const PrivacyPolicyScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'session',
                    name: AppRouteNames.session,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const SessionScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'change-password',
                    name: AppRouteNames.changePassword,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const ChangePasswordScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'privacy',
                    name: AppRouteNames.privacy,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const PrivacyScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'bus',
                    name: AppRouteNames.bus,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const BusScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'hostel',
                    name: AppRouteNames.hostel,
                    pageBuilder: (context, state) => _buildDetailTransitionPage(
                      state: state,
                      child: const HostelScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'leave-permission',
                        name: AppRouteNames.hostelLeavePermission,
                        pageBuilder: (context, state) =>
                            _buildDetailTransitionPage(
                              state: state,
                              child: const LeavePermissionDetailScreen(),
                            ),
                      ),
                      GoRoute(
                        path: 'fee-receipt',
                        name: AppRouteNames.hostelFeeReceipt,
                        pageBuilder: (context, state) =>
                            _buildDetailTransitionPage(
                              state: state,
                              child: const FeeReceiptDetailScreen(),
                            ),
                      ),
                      GoRoute(
                        path: 'mess-feedback',
                        name: AppRouteNames.hostelMessFeedback,
                        pageBuilder: (context, state) =>
                            _buildDetailTransitionPage(
                              state: state,
                              child: const MessFeedbackDetailScreen(),
                            ),
                      ),
                      GoRoute(
                        path: 'maintenance-request',
                        name: AppRouteNames.hostelMaintenanceRequest,
                        pageBuilder: (context, state) =>
                            _buildDetailTransitionPage(
                              state: state,
                              child: const MaintenanceRequestDetailScreen(),
                            ),
                      ),
                    ],
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

CustomTransitionPage<void> _buildPrimaryTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _kRouteTransitionDuration,
    reverseTransitionDuration: _kRouteReverseTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

CustomTransitionPage<void> _buildDetailTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _kRouteTransitionDuration,
    reverseTransitionDuration: _kRouteReverseTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(curved);
      final scale = Tween<double>(begin: 0.975, end: 1).animate(curved);

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(scale: scale, child: child),
        ),
      );
    },
  );
}
