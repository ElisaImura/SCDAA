import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> rendimientoPorLote = [];
  List<dynamic> historialVariedades = [];
  List<dynamic> promedioPorVariedad = [];
  List<dynamic> comparativaPorCiclo = [];
  List<dynamic> insumosMasUtilizados = [];
  List<Map<String, dynamic>> lluviasPorFecha = [];
  List<Map<String, dynamic>> ciclos = [];
  Map<String, dynamic>? cicloSeleccionado;


  bool cargando = false;
  String? error;

  Future<void> cargarReportes() async {
    cargando = true;
    notifyListeners();

    try {
      final datos = await _apiService.obtenerReporteProduccion();
      if (datos != null) {
        rendimientoPorLote = datos['rendimiento_por_lote'] ?? [];
        promedioPorVariedad = datos['promedio_por_variedad'] ?? [];
        comparativaPorCiclo = datos['comparativa_por_ciclo'] ?? [];
        insumosMasUtilizados = (datos['insumos_mas_utilizados'] ?? []).take(3).toList();
        error = null;
      } else {
        error = "Error al obtener datos del reporte.";
      }
    } catch (e) {
      error = "Error inesperado: $e";
    }

    cargando = false;
    notifyListeners();
  }

  // Dias de lluvia en rango de fechas
  Future<void> fetchLluviasPorFecha(DateTime inicio, DateTime fin, {int? loteId}) async {
    try {
      cargando = true;
      notifyListeners();

      final datos = await _apiService.fetchLluviasPorFecha(inicio, fin); // Asegurate que este método obtenga todos los climas en ese rango

      // Si se pasa un loteId, filtramos
      if (loteId != null) {
        lluviasPorFecha = datos.where((d) => d['lot_id'] == loteId).toList();
      } else {
        lluviasPorFecha = datos;
      }

      cargando = false;
      notifyListeners();
    } catch (e) {
      error = "Error al cargar datos de lluvia";
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarCiclos() async {
    try {
      ciclos = await _apiService.fetchAllCiclos();
      notifyListeners();
    } catch (e) {
      error = "No se pudieron cargar los ciclos";
      ciclos = [];
      notifyListeners();
    }
  }

  void seleccionarCiclo(Map<String, dynamic> ciclo) {
    cicloSeleccionado = ciclo;
    notifyListeners();
  }
}
