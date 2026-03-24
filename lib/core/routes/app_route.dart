import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mis_project/features/auth/register_page.dart';
import 'package:mis_project/features/polls/polls_page.dart';
import 'package:mis_project/features/profile/profile_page.dart';

import '../../features/map/public_map_page.dart';
import '../../features/pages/splash_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/home/home_page.dart';
import '../../features/reports/my_reports_page.dart';
import '../../features/reports/report_problem_page.dart';
import '../../features/shell/shell_widget.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/';

      if (!isLoggedIn && !isOnAuthPage) return '/login';
      if (isLoggedIn && isOnAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/map',
            builder: (context, state) => const PublicMapPage(),
          ),
          GoRoute(
            path: '/myReports',
            builder: (context, state) => const MyReportsPage(),
          ),
          GoRoute(
            path: '/myProfile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/report',
            builder: (context, state) => const ReportProblemPage(),
          ),
          GoRoute(
            path: '/polls',
            builder: (context, state) => const PollsPage(),
          ),
        ],
      ),
    ],
  );
});
