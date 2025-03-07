import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mspaa/screens/calendar_screen.dart';
import 'package:mspaa/screens/config_screen.dart';
import 'package:mspaa/screens/home_screen.dart';
import 'package:mspaa/screens/login_screen.dart';
import 'package:mspaa/screens/reports_screen.dart';
import 'package:mspaa/screens/welcome_screen.dart';
import 'package:mspaa/widgets/main_layout.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter está listo
  await initializeDateFormatting('es', null); // Carga el formato en español
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
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
  ],
);


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Monitoreo y Seguimiento de Actividades Agrícolas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 56, 184, 96)),
      ),
      routerConfig: _router, // ✅ SOLUCIÓN SIMPLIFICADA
    );
  }
}