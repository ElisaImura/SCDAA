import 'package:flutter/foundation.dart';
import 'package:mspaa/services/api_service.dart';

class WeatherProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
}
