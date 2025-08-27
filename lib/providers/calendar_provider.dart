import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CalendarProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ✅ Actividades y clima como listas por fecha (local)
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  Map<DateTime, List<Map<String, dynamic>>> _weather = {};

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Map<DateTime, List<Map<String, dynamic>>> get events => _events;
  Map<DateTime, List<Map<String, dynamic>>> get weather => _weather;

  CalendarProvider() {
    fetchData();
  }

  DateTime _normalizeLocal(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final actividades = await _apiService.fetchActividades();
      final clima = await _apiService.fetchClima();

      final Map<DateTime, List<Map<String, dynamic>>> eventos = {};
      final Map<DateTime, List<Map<String, dynamic>>> weatherData = {};

      // ACTIVIDADES -> clave local y lista
      for (final a in actividades) {
        final d = DateTime.parse(a['act_fecha']).toLocal();
        final key = _normalizeLocal(d);
        (eventos[key] ??= []).add(a);
      }

      // CLIMA -> clave local y lista
      for (final c in clima) {
        final d = DateTime.parse(c['cl_fecha']).toLocal();
        final key = _normalizeLocal(d);
        (weatherData[key] ??= []).add(c);
      }

      _events = eventos;
      _weather = weatherData;
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ Error CalendarProvider.fetchData: $e');
        print(st);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWeather(int id) async {
    try {
      final ok = await _apiService.deleteWeather(id);
      if (!ok) return false;
      // remueve localmente
      for (final entry in _weather.entries.toList()) {
        final filtered = entry.value.where((w) => w['cl_id'] != id).toList();
        if (filtered.isEmpty) {
          _weather.remove(entry.key);
        } else {
          _weather[entry.key] = filtered;
        }
      }
      await fetchData();
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error deleteWeather: $e');
      return false;
    }
  }
}
