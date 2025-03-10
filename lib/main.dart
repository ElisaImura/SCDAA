import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mspaa/providers/activity_provider.dart';
import 'package:mspaa/providers/calendar_provider.dart';
import 'package:mspaa/routes/app_router.dart'; // ✅ Importar las rutas
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showSharedPreferencesData() async {
  final prefs = await SharedPreferences.getInstance();

  // Obtener el token almacenado
  final String? token = prefs.getString("auth_token");
  print("Token almacenado: $token");

  // Obtener el user_id almacenado
  final int? userId = prefs.getInt("uss_id");
  print("User ID almacenado: $userId");

  // Puedes añadir más claves para ver qué más está guardado
  final String? anotherValue = prefs.getString("another_key");
  print("Another value: $anotherValue");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  // ✅ Obtener autenticación antes de correr la app
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("auth_token");
  
  // Verifica si el token existe y no está vacío
  final bool isLoggedIn = token != null && token.isNotEmpty;

  print("Logged: $token");

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    showSharedPreferencesData();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()), // ✅ Agregar el ActivityProvider
      ],
      child: MaterialApp.router(
        title: 'Monitoreo y Seguimiento de Actividades Agrícolas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 56, 184, 96)),
        ),
        routerConfig: AppRouter.getRouter(isLoggedIn), // ✅ Usar el router separado
      ),
    );
  }
}
