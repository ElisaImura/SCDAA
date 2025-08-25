// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InsumosProvider with ChangeNotifier {
  List<Map<String, dynamic>> _insumos = [];
  List<Map<String, dynamic>> get insumos => _insumos;

  // Obtener los insumos desde el backend
  Future<void> fetchInsumos() async {
    try {
      final fetchedInsumos = await ApiService().getInsumos();
      _insumos = fetchedInsumos;
      notifyListeners();
    } catch (e) {
      print("Error al obtener insumos: $e");
    }
  }

  // Agregar un nuevo insumo
  Future<bool> addInsumo(Map<String, dynamic> insumoData) async {
    try {
      final newInsumoId = await ApiService().addInsumo(insumoData);
      if (newInsumoId != null) {
        _insumos.add(insumoData);
        notifyListeners();
        return true;
      }else{
        return false;
      }
    } catch (e) {
      print("Error en provider al agregar insumo: $e");
      return false;
    }
  }

  // Editar un insumo existente
  Future<bool> editInsumo(int insumoId, Map<String, dynamic> insumoData) async {
    try {
      final isUpdated = await ApiService().editInsumo(insumoId, insumoData);
      if (isUpdated) {
        final index = _insumos.indexWhere((insumo) => insumo['ins_id'] == insumoId);
        if (index != -1) {
          _insumos[index] = {..._insumos[index], ...insumoData};
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error al actualizar insumo: $e");
      return false;
    }
  }

  // Eliminar un insumo
  Future<bool> deleteInsumo(int insumoId) async {
    try {
      final isDeleted = await ApiService().deleteInsumo(insumoId);
      if (isDeleted) {
        _insumos.removeWhere((insumo) => insumo['ins_id'] == insumoId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Error al eliminar insumo: $e");
      return false;
    }
  }
}
