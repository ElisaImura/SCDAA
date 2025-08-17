import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mspaa/providers/activity_provider.dart';
import 'package:mspaa/providers/calendar_provider.dart';
import 'package:mspaa/providers/cultivos_variedades_provider.dart';
import 'package:mspaa/providers/cycle_provider.dart';
import 'package:mspaa/providers/insumos_provider.dart';
import 'package:mspaa/providers/lotes_provider.dart';
import 'package:mspaa/providers/reportes_provider.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:mspaa/providers/weather_provider.dart';
import 'package:mspaa/routes/app_router.dart';
import 'package:mspaa/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  // Lee token y decide estado inicial
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final startLoggedIn = token != null && token.isNotEmpty;

  // Crea el notifier con el estado inicial correcto
  final auth = AuthNotifier(startLoggedIn);

  runApp(
    MultiProvider(
      providers: [
        // Auth en el árbol
        ChangeNotifierProvider<AuthNotifier>.value(value: auth),

        // Resto de providers
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => LotesProvider()),
        ChangeNotifierProvider(create: (_) => InsumosProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => CultivosVariedadesProvider()),
        ChangeNotifierProvider(create: (_) => ReportesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Observa el estado de auth para refrescar el router cuando cambie
    final auth = context.watch<AuthNotifier>();
    final router = AppRouter.getRouter(auth); // <-- pasa el notifier, no un bool

    return MaterialApp.router(
      title: 'Seguimiento y Control de Actividades Agrícolas',
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 56, 184, 96),
        ),
      ),
      routerConfig: router,
    );
  }
}
