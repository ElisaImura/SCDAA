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
        insumosMasUtilizados = datos['insumos_mas_utilizados'] ?? [];
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
  Future<void> fetchLluviasPorFecha(DateTime fechaInicio, DateTime fechaFin) async {
    cargando = true;
    notifyListeners();

    try {
      final datos = await _apiService.fetchLluviasPorFecha(fechaInicio, fechaFin);
      lluviasPorFecha = datos; // Guardamos los datos correctamente
      error = null;
    } catch (e) {
      error = "Error inesperado: $e";
      lluviasPorFecha = [];
    }

    cargando = false;
    notifyListeners();
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
