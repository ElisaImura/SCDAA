// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:mspaa/services/api_service.dart';

class WeatherProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isWeatherAvailable = false;
  final Map<DateTime, Map<String, dynamic>> _weather = {};

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
  Future<void> checkWeatherForDate(String date) async {
    _isLoading = true;
    notifyListeners();

    try {
      final weatherData = await ApiService().getAllWeatherData();
      _isWeatherAvailable = weatherData.any((clima) => clima['cl_fecha'] == date);  

    } catch (e) {
      _isWeatherAvailable = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    print('Clima disponible: $_isWeatherAvailable');
  }

  // Función para editar datos del clima
  Future<bool> editWeather(int climaId, Map<String, dynamic> weatherData) async {
    print('Datos del clima a editar: $weatherData');
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
      
      _weather.clear(); // Limpiar el mapa actual

      for (var item in fetchedData) {
        final fecha = DateTime.parse(item['cl_fecha']);
        _weather[DateTime.utc(fecha.year, fecha.month, fecha.day)] = item;
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
