import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/home/home_page.dart';
import '../../features/map/public_map_page.dart';
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
  initialLocation: '/home',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuth = user != null;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isAuth && !isAuthRoute) return '/login';
    if (isAuth && isAuthRoute) return '/home';
    return null;
  },
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Route не е пронајден: ${state.uri}')),
  ),
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterPage(),
    ),
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
          path: '/my-reports',
          pageBuilder: (_, __) => const NoTransitionPage(child: MyReportsPage()),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (_, __) => const NoTransitionPage(child: NotificationsPage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, __) => const NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),
    // Renamed to avoid GoRouter confusing /report/new with /report/:id
    GoRoute(
      path: '/new-report',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ReportFormPage(),
    ),
    GoRoute(
      path: '/report/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => ReportDetailPage(reportId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/polls',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const PollsPage(),
    ),
    GoRoute(
      path: '/polls/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => PollDetailPage(pollId: state.pathParameters['id']!),
    ),
  ],
);

// Helper to refresh on auth changes
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
