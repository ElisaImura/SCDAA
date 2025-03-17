import 'package:flutter/foundation.dart';
import 'package:mspaa/services/api_service.dart';

class UsersProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  // Función para obtener los datos del usuario
  Future<void> fetchUserData() async {
    try {
      final ApiService apiService = ApiService();
      _userData = await apiService.getUserInfo();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener datos del usuario: $e");
      }
    }
  }
}
