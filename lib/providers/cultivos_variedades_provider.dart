// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:mspaa/services/api_service.dart';

class CultivosVariedadesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cultivos = [];
  List<Map<String, dynamic>> get cultivos => _cultivos;

  // Obtener los cultivos desde el backend
  Future<void> fetchCultivos() async {
    try {
      final fetchedCultivos = await ApiService().fetchCultivos();
      _cultivos = fetchedCultivos;
      notifyListeners();
    } catch (e) {
      print("Error al obtener cultivos: $e");
    }
  }

  // Agregar un nuevo tipo de cultivo
  Future<bool> addCultivo(String nombre) async {
    try {
      final isAdded = await ApiService().addCultivo(nombre);
      if (isAdded) {
        await fetchCultivos(); // Refrescar la lista desde el backend
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error en provider al agregar cultivo: $e");
      return false;
    }
  }

  // Editar cultivo
  Future<bool> editCultivo(int cultivoId, Map<String, dynamic> cultivoData) async {
    try {
      final isUpdated = await ApiService().editCultivo(cultivoId, cultivoData);
      if (isUpdated) {
        final index = _cultivos.indexWhere((cul) => cul['tpCul_id'] == cultivoId);
        if (index != -1) {
          _cultivos[index] = {..._cultivos[index], ...cultivoData};
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error al editar cultivo: $e");
      return false;
    }
  }

  // Eliminar cultivo
  Future<bool> deleteCultivo(int cultivoId) async {
    try {
      final isDeleted = await ApiService().deleteCultivo(cultivoId);
      if (isDeleted) {
        _cultivos.removeWhere((cul) => cul['tpCul_id'] == cultivoId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Error al eliminar cultivo: $e");
      return false;
    }
  }

  // Obtener variedades por cultivo
  Future<List<Map<String, dynamic>>> fetchVariedadesPorCultivo(int cultivoId) async {
    try {
      return await ApiService().fetchVariedadesPorCultivo(cultivoId);
    } catch (e) {
      print("Error al obtener variedades por cultivo: $e");
      return [];
    }
  }

  // Agregar una nueva variedad
  Future<bool> addVariedad(int cultivoId, String nombreVariedad) async {
    try {
      final isAdded = await ApiService().addVariedad(nombreVariedad, cultivoId);
      if (isAdded != null) {
        await fetchCultivos(); // Refrescar la lista desde el backend
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error en provider al agregar variedad: $e");
      return false;
    }
  }

  // Editar variedad
  Future<bool> editVariedad(int variedadId, Map<String, dynamic> variedadData) async {
    try {
      final isUpdated = await ApiService().editVariedad(variedadId, variedadData);
      if (isUpdated) {
        await fetchCultivos(); // Refrescar la lista desde el backend
        return true;
      }
      return false;
    } catch (e) {
      print("Error al editar variedad: $e");
      return false;
    }
  }

  // Eliminar variedad
  Future<bool> deleteVariedad(int variedadId) async {
    try {
      final isDeleted = await ApiService().deleteVariedad(variedadId);
      if (isDeleted) {
        await fetchCultivos(); // Refrescar la lista desde el backend
        return true;
      }
      return false;
    } catch (e) {
      print("Error al eliminar variedad: $e");
      return false;
    }
  }
}
