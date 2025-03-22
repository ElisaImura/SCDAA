// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:mspaa/services/api_service.dart';

class WeatherProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isWeatherAvailable = false;

  bool get isLoading => _isLoading;
  bool get isWeatherAvailable => _isWeatherAvailable;

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
}
