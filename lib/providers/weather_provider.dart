// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class WeatherProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isWeatherAvailable = false;
  final Map<DateTime, Map<String, dynamic>> _weather = {};
  final Map<DateTime, List<Map<String, dynamic>>> _weatherPorFecha = {};

  Map<DateTime, List<Map<String, dynamic>>> get weatherPorFecha => _weatherPorFecha;
  bool get isLoading => _isLoading;
  bool get isWeatherAvailable => _isWeatherAvailable;
  Map<DateTime, Map<String, dynamic>> get weather => _weather;

  // Función para agregar datos del clima
  Future<bool> addWeatherData(Map<String, dynamic> weatherData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.addWeatherData(weatherData);

      _isLoading = false;
      notifyListeners();

      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) print("❌ Error al agregar datos del clima: $e");
      return false;
    }
  }

  // Funcion para verificar si ya existe un clima en esa fecha
  Future<void> checkWeatherForDate(String date, int lotId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final weatherData = await _apiService.getAllWeatherData(); // O fetchClima()

      _isWeatherAvailable = weatherData.any((clima) =>
          clima['cl_fecha'] == date && clima['lot_id'] == lotId);
    } catch (e) {
      _isWeatherAvailable = false;
      if (kDebugMode) print("❌ Error al verificar clima: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    print('Clima disponible para fecha $date y lote $lotId: $_isWeatherAvailable');
  }

  // Función para editar datos del clima
  Future<bool> editWeather(int climaId, Map<String, dynamic> weatherData) async {
    try {
      final response = await _apiService.editWeather(climaId, weatherData);
      if (response) {
        await fetchWeatherData(); // o tu método de actualización
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Error al editar clima: $e");
      return false;
    }
}

  // Funcion para eliminar un clima
  Future<bool> deleteWeather(int id) async {
    try {
      final response = await ApiService().deleteWeather(id);
      if (response) {
        // Buscar la clave DateTime que tenga el id correspondiente
        DateTime? fechaAEliminar;

        for (final entry in _weather.entries) {
          if (entry.value['cl_id'] == id) {
            fechaAEliminar = entry.key;
            break;
          }
        }

        if (fechaAEliminar != null) {
          _weather.remove(fechaAEliminar);
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Error al eliminar clima: $e");
      return false;
    }
  }

  Future<void> fetchWeatherData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedData = await _apiService.getAllWeatherData();
      _weatherPorFecha.clear();

      for (var item in fetchedData) {
        final fecha = DateTime.parse(item['cl_fecha']);
        final fechaKey = DateTime.utc(fecha.year, fecha.month, fecha.day);

        if (!_weatherPorFecha.containsKey(fechaKey)) {
          _weatherPorFecha[fechaKey] = [];
        }

        _weatherPorFecha[fechaKey]!.add(item);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("❌ Error al obtener datos del clima: $e");
      _isLoading = false;
      notifyListeners();
    }
  }
}
