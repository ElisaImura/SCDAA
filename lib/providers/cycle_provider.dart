// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:mspaa/services/api_service.dart';

class CycleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  final List<Map<String, dynamic>> _ciclos = [];
  List<Map<String, dynamic>> _ciclosActivos = [];
  List<Map<String, dynamic>> _ciclosInactivos = [];
  Map<String, dynamic>? ciclo;

  List<Map<String, dynamic>> get ciclos => _ciclos;
  List<Map<String, dynamic>> get ciclosActivos => _ciclosActivos;
  List<Map<String, dynamic>> get ciclosInactivos => _ciclosInactivos;

  // 🔹 Cargar un ciclo específico
  Future<void> fetchCicloEspecifico(int id) async {
    try {
      ciclo = await _apiService.fetchCicloSpecific(id); // ✅ Llamada correcta con ID
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Error al obtener el ciclo específico: $e");
    }
  }

  // 🔹 Cargar los ciclos activos
  Future<void> fetchCiclosActivos() async {
    try {
      _ciclosActivos = await _apiService.fetchCiclosActivos(); // Llamada al ApiService para obtener los ciclos activos
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Error al obtener ciclos activos: $e");
    }
  }

  // 🔹 Cargar los ciclos inactivos
  Future<void> fetchCiclosInactivos() async {
    try {
      _ciclosInactivos = await _apiService.fetchCiclosInactivos(); // Llamada al ApiService para obtener los ciclos inactivos
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Error al obtener ciclos inactivos: $e");
    }
  }

  /// 🔹 Verificar si el lote tiene un ciclo activo
  Future<bool> checkActiveCycle(int lotId) async {
    return await _apiService.hasActiveCycle(lotId); // Llamamos al método del ApiService
  }

  /// 🔹 Agregar un nuevo ciclo
  Future<bool> addCiclo(Map<String, dynamic> cicloData) async {
    bool success = await _apiService.addCiclo(cicloData);
    notifyListeners();
    return success;
  }

  // Método para editar un ciclo
  Future<bool> editCiclo(int cicloId, Map<String, dynamic> cicloData) async {
    try {
      bool success = await _apiService.editCiclo(cicloId, cicloData); // Llama al método de la API para editar el ciclo
      return success;
    } catch (e) {
      print("Error al editar el ciclo: $e");
      return false;
    }
  }

  // Método para eliminar un ciclo
  Future<bool> deleteCiclo(int cicloId) async {
    try {
      bool success = await _apiService.deleteCiclo(cicloId); // Llama al método de la API para eliminar el ciclo
      return success;
    } catch (e) {
      print("Error al eliminar el ciclo: $e");
      return false;
    }
  }

}