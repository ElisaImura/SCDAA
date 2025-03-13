import 'package:flutter/foundation.dart';
import 'package:mspaa/services/api_service.dart';

class CalendarProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<DateTime, List<Map<String, dynamic>>> _events = {}; // Actividades
  Map<DateTime, Map<String, dynamic>> _weather = {}; // Clima por fecha

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Map<DateTime, List<Map<String, dynamic>>> get events => _events;
  Map<DateTime, Map<String, dynamic>> get weather => _weather; // Getter para el clima

  CalendarProvider() {
    fetchData();
  }

  // Método para cargar actividades y clima
  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final actividades = await _apiService.fetchActividades();
      final clima = await _apiService.fetchClima(); // Supón que esto obtiene el clima de alguna API

      final Map<DateTime, List<Map<String, dynamic>>> eventos = {};
      final Map<DateTime, Map<String, dynamic>> weatherData = {};

      // Procesar actividades
      for (var actividad in actividades) {
        final DateTime fecha = DateTime.parse(actividad['act_fecha']);
        final DateTime fechaNormalizada = DateTime.utc(fecha.year, fecha.month, fecha.day);

        if (eventos[fechaNormalizada] == null) {
          eventos[fechaNormalizada] = [];
        }

        eventos[fechaNormalizada]!.add(actividad);
      }

      // Procesar clima
      for (var climaItem in clima) {
        final DateTime fecha = DateTime.parse(climaItem['cl_fecha']);
        final DateTime fechaNormalizada = DateTime.utc(fecha.year, fecha.month, fecha.day);

        weatherData[fechaNormalizada] = climaItem;
      }

      _events = eventos;
      _weather = weatherData;
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("❌ Error al obtener datos: $e");
        print("🔍 Stacktrace: $stacktrace");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
