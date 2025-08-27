// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CycleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  final List<Map<String, dynamic>> _ciclos = [];
  List<Map<String, dynamic>> _ciclosActivos = [];
  List<Map<String, dynamic>> _ciclosInactivos = [];
  Map<String, dynamic>? ciclo;

  bool _loadingActivos = true; // Flag de carga para ciclos activos
  bool _loadingInactivos = false;

  List<Map<String, dynamic>> get ciclos => _ciclos;
  List<Map<String, dynamic>> get ciclosActivos => _ciclosActivos;
  List<Map<String, dynamic>> get ciclosInactivos => _ciclosInactivos;
  bool get loadingActivos => _loadingActivos;
  bool get loadingInactivos => _loadingInactivos;

  CycleProvider() {
    // Carga inicial al crear el provider
    Future.microtask(() {
      fetchCiclosActivos();
      // fetchCiclosInactivos(); // Si también quieres precargar inactivos
    });
  }

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
    _loadingActivos = true;
    notifyListeners();
    try {
      final res = await _apiService.fetchCiclosActivos();
      _ciclosActivos = res;
    } catch (e) {
      if (kDebugMode) print("❌ Error ciclos activos: $e");
      _ciclosActivos = [];
    } finally {
      _loadingActivos = false;
      notifyListeners();
    }
  }

  // 🔹 Cargar los ciclos inactivos
  Future<void> fetchCiclosInactivos() async {
    _loadingInactivos = true;
    notifyListeners();
    try {
      final res = await _apiService.fetchCiclosInactivos();
      _ciclosInactivos = res;
    } catch (e) {
      if (kDebugMode) print("❌ Error ciclos inactivos: $e");
      _ciclosInactivos = [];
    } finally {
      _loadingInactivos = false;
      notifyListeners();
    }
  }

  /// 🔹 Verificar si el lote tiene un ciclo activo
  Future<bool> checkActiveCycle(int lotId) async {
    return await _apiService.hasActiveCycle(lotId); // Llamamos al método del ApiService
  }

  /// 🔹 Agregar un nuevo ciclo
  Future<bool> addCiclo(Map<String, dynamic> cicloData) async {
    bool success = await _apiService.addCiclo(cicloData);
    if (success) await fetchCiclosActivos(); // Refresca la lista si se agregó
    notifyListeners();
    return success;
  }

  // Método para editar un ciclo
  Future<bool> editCiclo(int cicloId, Map<String, dynamic> cicloData) async {
    try {
      bool success = await _apiService.editCiclo(cicloId, cicloData);
      if (success) await fetchCiclosActivos(); // Refresca si se editó
      return success;
    } catch (e) {
      print("Error al editar el ciclo: $e");
      return false;
    }
  }

  // Método para eliminar un ciclo
  Future<bool> deleteCiclo(int cicloId) async {
    try {
      bool success = await _apiService.deleteCiclo(cicloId);
      if (success) await fetchCiclosActivos(); // Refresca si se eliminó
      return success;
    } catch (e) {
      print("Error al eliminar el ciclo: $e");
      return false;
    }
  }
}