import 'package:go_router/go_router.dart';
import 'package:mspaa/screens/forms/add_activity_screen.dart';
import 'package:mspaa/screens/calendar_screen.dart';
import 'package:mspaa/screens/config_screen.dart';
import 'package:mspaa/screens/forms/add_cycle_screen.dart';
import 'package:mspaa/screens/forms/add_weather_screen.dart';
import 'package:mspaa/screens/home_screen.dart';
import 'package:mspaa/screens/login_screen.dart';
import 'package:mspaa/screens/reports_screen.dart';
import 'package:mspaa/screens/welcome_screen.dart';
import 'package:mspaa/widgets/main_layout.dart';

class AppRouter {
  static GoRouter getRouter(bool isLoggedIn) {
    return GoRouter(
      initialLocation: isLoggedIn ? '/home' : '/',  // Redirige según autenticación
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage(child: const WelcomeScreen()),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => NoTransitionPage(child: const LoginScreen()),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: const HomeScreen())),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: const CalendarScreen())),
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: const ReportsScreen())),
        ),
        GoRoute(
          path: '/config',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: const ConfigScreen())),
        ),
        GoRoute(
          path: '/add-activity',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: const AddActivityScreen())),
        ),
        GoRoute(
          path: '/add-cycle',
          pageBuilder: (context, state) => NoTransitionPage(child: const AddCycleScreen()),
        ),
        GoRoute(
          path: '/add-weather',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: const AddWeatherScreen())),
        ),
      ],
    );
  }
}
