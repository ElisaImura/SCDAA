import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mspaa/providers/calendar_provider.dart';
import 'package:mspaa/screens/calendar_screen.dart';
import 'package:mspaa/screens/config_screen.dart';
import 'package:mspaa/screens/home_screen.dart';
import 'package:mspaa/screens/login_screen.dart';
import 'package:mspaa/screens/reports_screen.dart';
import 'package:mspaa/screens/welcome_screen.dart';
import 'package:mspaa/widgets/main_layout.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Asegura que Flutter está listo
  await initializeDateFormatting('es', null); // ✅ Formateo de fecha
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// 🔹 Función para verificar si hay un token guardado antes de iniciar la app
Future<bool> isAuthenticated() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("auth_token") != null; // ✅ Verifica si hay un token
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAuthenticated(), // ✅ Verifica autenticación antes de iniciar
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // 🔄 Muestra un loader si está cargando
        }

        final bool isLoggedIn = snapshot.data ?? false;
        return MaterialApp.router(
          title: 'Monitoreo y Seguimiento de Actividades Agrícolas',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 56, 184, 96)),
          ),
          routerConfig: GoRouter(
            initialLocation: isLoggedIn ? '/home' : '/login', // ✅ Si está logueado va a `/home`
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
          ),
        );
      },
    );
  }
}
