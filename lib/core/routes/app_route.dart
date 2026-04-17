import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mis_project/features/reports/all_reports_page.dart';

import '../../admin/admin_dashboard_page.dart';
import '../../admin/admin_notifications_page.dart';
import '../../admin/admin_polls_page.dart';
import '../../admin/admin_report_detail_page.dart';
import '../../admin/admin_reports_page.dart';
import '../../admin/admin_shell.dart';
import '../../admin/admin_users_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/home/home_page.dart';
import '../../features/map/public_map_page.dart';
import '../../features/pages/splash_page.dart';
import '../../features/polls/poll_details.dart';
import '../../features/polls/polls_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/reports/my_reports_page.dart';
import '../../features/reports/report_details.dart';
import '../../features/reports/report_from_page.dart';
import '../../features/shell/shell_widget.dart';
import '../notifications/notifications_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/admin',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuth = user != null;
    final isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isAuth && !isAuthRoute) return '/login';
    if (isAuth && isAuthRoute) return '/home';
    return null;
  },
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Route не е пронајден: ${state.uri}'))),
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),

    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ShellPage(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (_, __) => const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/map',
          pageBuilder: (_, __) => const NoTransitionPage(child: MapPage()),
        ),
        GoRoute(
          path: '/all-reports',
          pageBuilder: (_, __) =>
              const NoTransitionPage(child: AllReportsPage()),
        ),
        GoRoute(
          path: '//my-reports',
          pageBuilder: (_, __) =>
              const NoTransitionPage(child: MyReportsPage()),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (_, __) =>
              const NoTransitionPage(child: NotificationsPage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, __) => const NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),

    GoRoute(
      path: '/new-report',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ReportFormPage(),
    ),
    GoRoute(
      path: '/report/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) =>
          ReportDetailPage(reportId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/polls',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const PollsPage(),
    ),
    GoRoute(
      path: '/polls/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) =>
          PollDetailPage(pollId: state.pathParameters['id']!),
    ),

    ShellRoute(
      builder: (_, state, child) {
        final titles = {
          '/admin': 'Admin — Преглед',
          '/admin/reports': 'Admin — Пријави',
          '/admin/notifications': 'Admin — Известувања',
          '/admin/polls': 'Admin — Анкети',
          '/admin/users': 'Admin — Корисници',
        };
        final title = titles[state.matchedLocation] ?? 'Admin';
        return AdminShell(child: child, title: title);
      },
      routes: [
        GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardPage()),
        GoRoute(
          path: '/admin/reports',
          builder: (_, __) => const AdminReportsPage(),
        ),
        GoRoute(
          path: '/admin/notifications',
          builder: (_, __) => const AdminNotificationsPage(),
        ),
        GoRoute(
          path: '/admin/polls',
          builder: (_, __) => const AdminPollsPage(),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (_, __) => const AdminUsersPage(),
        ),
      ],
    ),

    GoRoute(
      path: '/admin/report/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) =>
          AdminReportDetailPage(reportId: state.pathParameters['id']!),
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
