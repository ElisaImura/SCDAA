import 'package:flutter/material.dart';
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
  try {
    List<Map<String, dynamic>> actividades = await _apiService.fetchActividades();

    Map<DateTime, List<Map<String, dynamic>>> eventos = {};

    for (var actividad in actividades) {
      DateTime fecha = DateTime.parse(actividad['act_fecha']);
      DateTime fechaNormalizada = DateTime.utc(fecha.year, fecha.month, fecha.day);

      if (!eventos.containsKey(fechaNormalizada)) {
        eventos[fechaNormalizada] = [];
      }
      eventos[fechaNormalizada]!.add(actividad);
    }

    _events = eventos;
    _isLoading = false;
    notifyListeners(); // 🔹 Notificar a los widgets dependientes

  } catch (e) {
    print("❌ Error al obtener actividades: $e");
    _isLoading = false;
    notifyListeners();
  }
}
}
