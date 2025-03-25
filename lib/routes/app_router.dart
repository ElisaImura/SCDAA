import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mspaa/screens/forms/add_activity_screen.dart';
import 'package:mspaa/screens/main/calendar_screen.dart';
import 'package:mspaa/screens/main/config_screen.dart';
import 'package:mspaa/screens/forms/add_cycle_screen.dart';
import 'package:mspaa/screens/forms/add_weather_screen.dart';
import 'package:mspaa/screens/main/home_screen.dart';
import 'package:mspaa/screens/login_screen.dart';
import 'package:mspaa/screens/main/reports_screen.dart';
import 'package:mspaa/screens/views/ciclos_view.dart';
import 'package:mspaa/screens/views/cultivos_view.dart';
import 'package:mspaa/screens/views/insumos_view.dart';
import 'package:mspaa/screens/views/lotes_view.dart';
import 'package:mspaa/screens/views/permisos_view.dart';
import 'package:mspaa/screens/views/users_view.dart';
import 'package:mspaa/screens/welcome_screen.dart';
import 'package:mspaa/widgets/main_layout.dart';
import 'package:mspaa/screens/forms/edit_user_screen.dart';
import 'package:mspaa/screens/views/activities_view.dart';

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
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: const CalendarScreen())),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: const ReportsScreen())),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/config',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: const ConfigScreen())),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/add-activity',
          pageBuilder: (context, state) => NoTransitionPage(child: const AddActivityScreen()),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/add-cycle',
          pageBuilder: (context, state) => NoTransitionPage(child: const AddCycleScreen()),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/add-weather',
          builder: (BuildContext context, GoRouterState state) {
            // Check if extra data is passed and handle accordingly
            final extra = state.extra as Map<String, dynamic>?;
            final bool isFromFooter = extra != null && extra['isFromFooter'] == true;

            return AddWeatherScreen(isFromFooter: isFromFooter); // Pass the flag to the screen
          },
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/usuarios',
          pageBuilder: (context, state) => NoTransitionPage(child: const UsersView()),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/usuarios/edit',
          pageBuilder: (context, state) {
            final user = state.extra as Map<String, dynamic>;
            return NoTransitionPage(child: EditUserView(user: user));
          },
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/actividades',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: ActivitiesView())),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/lotes',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: LotesView())),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/insumos',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: InsumosView())),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/ciclos',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: CiclosView())),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/cultivos',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: CultivosView())),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
        GoRoute(
          path: '/permisos',
          pageBuilder: (context, state) => NoTransitionPage(child: MainLayout(child: PermisosView())),
          redirect: (context, state) => isLoggedIn ? null : '/login',
        ),
      ],
    );
  }
}
