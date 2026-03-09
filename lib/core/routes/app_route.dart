import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mis_project/features/auth/register_page.dart';
import 'package:mis_project/features/polls/polls_page.dart';
import 'package:mis_project/features/profile/profile_page.dart';

import '../../features/map/public_map_page.dart';
import '../../features/pages/splash_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/home/home_page.dart';
import '../../features/reports/my_reports_page.dart';
import '../../features/reports/report_problem_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [

      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        path: '/report',
        builder: (context, state) => const ReportProblemPage(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const PublicMapPage(),
      ),

      GoRoute(
        path: '/myReports',
        builder: (context, state) => const MyReportsPage(),
      ),

      GoRoute(
        path: '/polls',
        builder: (context, state) => const PollsPage(),
      ),
      GoRoute(
        path: '/myProfile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});