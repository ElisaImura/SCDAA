import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mspaa/providers/activity_provider.dart';
import 'package:mspaa/providers/calendar_provider.dart';
import 'package:mspaa/routes/app_router.dart'; // ✅ Importar las rutas
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()), // ✅ Agregar el ActivityProvider
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
          routerConfig: AppRouter.getRouter(isLoggedIn), // ✅ Usar el router separado
        );
      },
    );
  }
}
