import 'package:flutter/foundation.dart';
import 'package:mspaa/services/api_service.dart';

class CalendarProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Map<DateTime, List<Map<String, dynamic>>> get events => _events;

  CalendarProvider() {
    fetchActividades();
  }

  Future<void> fetchActividades() async {
    _isLoading = true; // ✅ Establecer el estado de carga antes de la solicitud
    notifyListeners(); // ✅ Notificar a los widgets solo una vez al comenzar

    try {
      final actividades = await _apiService.fetchActividades();
      final Map<DateTime, List<Map<String, dynamic>>> eventos = {};

      for (var actividad in actividades) {
        final DateTime fecha = DateTime.parse(actividad['act_fecha']);
        final DateTime fechaNormalizada = DateTime.utc(fecha.year, fecha.month, fecha.day);

        eventos.putIfAbsent(fechaNormalizada, () => []).add(actividad); // ✅ Forma más limpia de agregar eventos
      }

      _events = eventos;
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("❌ Error al obtener actividades: $e");
        print("🔍 Stacktrace: $stacktrace"); // ✅ Mostrar stacktrace para mejor depuración
      }
    } finally {
      _isLoading = false;
      notifyListeners(); // ✅ Notificar solo al final, una vez
    }
  }
}
