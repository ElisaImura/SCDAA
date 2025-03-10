import 'package:flutter/foundation.dart';
import 'package:mspaa/services/api_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _ciclos = [];
  List<Map<String, dynamic>> _tiposActividades = [];
  List<Map<String, dynamic>> _tiposCultivos = [];
  List<Map<String, dynamic>> _variedades = []; // ✅ Separamos variedades correctamente
  List<Map<String, dynamic>> _lotes = [];
  bool isLoading = true;

  List<Map<String, dynamic>> get ciclos => _ciclos;
  List<Map<String, dynamic>> get tiposActividades => _tiposActividades;
  List<Map<String, dynamic>> get tiposCultivos => _tiposCultivos;
  List<Map<String, dynamic>> get variedades => _variedades; // ✅ Ahora usamos esta lista
  List<Map<String, dynamic>> get lotes => _lotes;

  ActivityProvider() {
    fetchDropdownData();
  }

  // 🔹 Obtener ciclos activos y tipos de actividades desde la API
  Future<void> fetchDropdownData() async {
    try {
      _ciclos = await _apiService.fetchCiclos();
      _tiposActividades = await _apiService.fetchTiposActividades();
      _tiposCultivos = await _apiService.fetchTiposCultivos();
      _variedades = []; // ✅ Limpiamos variedades al inicio
      _lotes = await _apiService.fetchLotes();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error en fetchDropdownData(): $e");
      }
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Obtener variedades según el tipo de cultivo seleccionado
  Future<void> getVariedadesByCultivo(String cultivoId) async {
    if (cultivoId.isEmpty) {
      _variedades = [];
      notifyListeners();
      return;
    }

    try {
      int cultivoIdInt = int.tryParse(cultivoId) ?? 0;
      
      if (cultivoIdInt == 0) {
        if (kDebugMode) {
          print("❌ Error: ID de cultivo inválido");
        }
        return;
      }

      _variedades = await _apiService.fetchVariedades(cultivoIdInt); // ✅ Ahora sí manda el ID correcto

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error en getVariedadesByCultivo(): $e");
      }
    }
  }

  /// 🔹 Agregar un nuevo ciclo
  Future<bool> addCiclo(Map<String, dynamic> cicloData) async {
    bool success = await _apiService.addCiclo(cicloData);
    if (success) {
      fetchDropdownData();
      notifyListeners();
    }
    return success;
  }

  /// 🔹 Agregar una nueva variedad
  Future<int?> addVariedad(String nombre, String cultivoId) async {
    int? variedadId = await _apiService.addVariedad(nombre, cultivoId);
    if (variedadId != null) {
      _variedades.add({"var_id": variedadId, "tpCul_id": cultivoId, "var_nombre": nombre});
      notifyListeners();
    }
    return variedadId;
  }

  /// 🔹 Obtener el usuario autenticado
  Future<int?> getLoggedUserId() async {
    return await _apiService.getLoggedUserId();
  }

  /// 🔹 Agregar una nueva actividad
  Future<bool> addActivity(Map<String, dynamic> activityData) async {
    bool success = await _apiService.addActivity(activityData);
    if (success) {
      fetchDropdownData(); // ✅ Recargar datos después de agregar actividad
      notifyListeners();
    }
    return success;
  }
}
