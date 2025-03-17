import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mspaa/providers/activity_provider.dart';
import 'package:mspaa/providers/calendar_provider.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:mspaa/providers/weather_provider.dart';
import 'package:mspaa/routes/app_router.dart';
import 'package:mspaa/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  // ✅ Obtener autenticación antes de correr la app
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("auth_token");

  // Verifica si el token existe y no está vacío
  final bool isLoggedIn = token != null && token.isNotEmpty;

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()), // Proveedor de ApiService
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn), // Usar MyApp con el isLoggedIn como parámetro
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Monitoreo y Seguimiento de Actividades Agrícolas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 56, 184, 96)),
      ),
      routerConfig: AppRouter.getRouter(isLoggedIn),
    );
  }
}
