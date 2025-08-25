// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Importa el servicio de API

class LotesProvider with ChangeNotifier {
  List<dynamic> _lotes = [];
  bool _isLoading = false;

  List<dynamic> get lotes => _lotes;
  bool get isLoading => _isLoading;

  // Método para obtener todos los lotes
  Future<void> fetchLotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _lotes = await ApiService().getLotes(); // Llama al método de la API para obtener los lotes
    } catch (e) {
      _lotes = [];
      print("Error al obtener los lotes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para agregar un nuevo lote
  Future<bool> addLote(String nombre) async {
    try {
      final lotId = await ApiService().addLote(nombre); // Llama a la función del ApiService
      if (lotId != null) {
        return true;  // El lote fue agregado exitosamente
      } else {
        return false; // Si no se pudo agregar el lote
      }
    } catch (e) {
      print("Error al agregar el lote: $e");
      return false;  // En caso de error
    }
  }

  // Método para editar un lote
  Future<bool> editLote(int loteId, Map<String, dynamic> loteData) async {
    try {
      bool success = await ApiService().editLote(loteId, loteData); // Llama al método de la API para editar el lote
      return success;
    } catch (e) {
      print("Error al editar el lote: $e");
      return false;
    }
  }

  // Método para eliminar un lote
  Future<bool> deleteLote(int loteId) async {
    try {
      bool success = await ApiService().deleteLote(loteId); // Llama al método de la API para eliminar el lote
      return success;
    } catch (e) {
      print("Error al eliminar el lote: $e");
      return false;
    }
  }
}
