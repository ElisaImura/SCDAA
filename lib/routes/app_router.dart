import 'package:go_router/go_router.dart';
import '../../../screens/forms/add/add_activity_screen.dart';
import '../../../screens/login/forgot_password_screen.dart';
import '../../../screens/login/password_reset_screen.dart';
import '../../../screens/main/calendar_screen.dart';
import '../../../screens/main/config_screen.dart';
import '../../../screens/forms/add/add_cycle_screen.dart';
import '../../../screens/forms/add/add_weather_screen.dart';
import '../../../screens/main/home_screen.dart';
import '../../../screens/login/login_screen.dart';
import '../../../screens/main/reports_screen.dart';
import '../../../screens/views/ciclos_view.dart';
import '../../../screens/views/cultivos_view.dart';
import '../../../screens/views/insumos_view.dart';
import '../../../screens/views/lotes_view.dart';
import '../../../screens/views/permisos_view.dart';
import '../../../screens/views/users_view.dart';
import '../../../screens/login/welcome_screen.dart';
import '../../../services/api_service.dart';
import '../../../widgets/main_layout.dart';
import '../../../screens/forms/edit/edit_user_screen.dart';
import '../../../screens/views/activities_view.dart';

class AppRouter {
  static GoRouter getRouter(AuthNotifier auth) {
    return GoRouter(
      initialLocation: auth.isLoggedIn ? '/home' : '/',
      refreshListenable: auth, // <- clave
      redirect: (context, state) {
        final goingToLogin = state.matchedLocation == '/login' 
          || state.matchedLocation == '/forgot-password'
          || state.matchedLocation == '/reset-password';
        final atWelcome = state.matchedLocation == '/';

        if (!auth.isLoggedIn) {
          // Si no hay login, solo permite welcome y pantallas de login/reset
          return (goingToLogin || atWelcome) ? null : '/login';
        }

        // Si ya está logueado, evita volver a welcome/login
        if (auth.isLoggedIn && (goingToLogin || atWelcome)) {
          return '/home';
        }

        return null; // no redirigir
      },
      routes: [
        GoRoute(path: '/', pageBuilder: (_, __) => NoTransitionPage(child: const WelcomeScreen())),
        GoRoute(path: '/login', pageBuilder: (_, __) => NoTransitionPage(child: const LoginScreen())),
        GoRoute(path: '/forgot-password', pageBuilder: (_, __) => NoTransitionPage(child: const ForgotPasswordScreen())),
        GoRoute(path: '/reset-password', pageBuilder: (_, __) => NoTransitionPage(child: const PasswordResetScreen())),
        GoRoute(path: '/home', pageBuilder: (_, __) => NoTransitionPage(child: MainLayout(child: const HomeScreen()))),
        GoRoute(path: '/calendar', pageBuilder: (_, __) => NoTransitionPage(child: MainLayout(child: const CalendarScreen()))),
        GoRoute(path: '/reports', pageBuilder: (_, __) => NoTransitionPage(child: MainLayout(child: const ReportsScreen()))),
        GoRoute(path: '/config', pageBuilder: (_, __) => NoTransitionPage(child: MainLayout(child: const ConfigScreen()))),
        GoRoute(path: '/add-activity', pageBuilder: (_, __) => NoTransitionPage(child: const AddActivityScreen())),
        GoRoute(
          path: '/add-weather',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final bool isFromFooter = extra != null && extra['isFromFooter'] == true;
            return AddWeatherScreen(isFromFooter: isFromFooter);
          },
        ),
        GoRoute(path: '/add-cycle', pageBuilder: (_, __) => NoTransitionPage(child: const AddCycleScreen())),
        GoRoute(path: '/usuarios', pageBuilder: (_, __) => NoTransitionPage(child: const UsersView())),
        GoRoute(
          path: '/usuarios/edit',
          pageBuilder: (_, state) {
            final user = state.extra as Map<String, dynamic>;
            return NoTransitionPage(child: EditUserView(user: user));
          },
        ),
        GoRoute(path: '/actividades', pageBuilder: (_, __) => NoTransitionPage(child: MainLayout(child: ActivitiesView()))),
        GoRoute(path: '/lotes', pageBuilder: (_, __) => NoTransitionPage(child: MainLayout(child: LotesView()))),
        GoRoute(path: '/insumos', pageBuilder: (_, __) => NoTransitionPage(child: MainLayout(child: InsumosView()))),
        GoRoute(path: '/ciclos', pageBuilder: (_, __) => NoTransitionPage(child: MainLayout(child: CiclosView()))),
        GoRoute(path: '/cultivos', pageBuilder: (_, __) => NoTransitionPage(child: MainLayout(child: CultivosView()))),
        GoRoute(path: '/permisos', pageBuilder: (_, __) => NoTransitionPage(child: MainLayout(child: PermisosView()))),
      ],
    );
  }
}
