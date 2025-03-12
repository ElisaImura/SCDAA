import 'package:flutter/foundation.dart';
import 'package:mspaa/services/api_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _ciclos = [];
  List<Map<String, dynamic>> _tiposActividades = [];
  List<Map<String, dynamic>> _tiposCultivos = [];
  List<Map<String, dynamic>> _variedades = [];
  List<Map<String, dynamic>> _lotes = [];
  List<Map<String, dynamic>> _insumos = [];

  bool isLoading = true;
  bool isLoadingVariedades = false;

  List<Map<String, dynamic>> get ciclos => _ciclos;
  List<Map<String, dynamic>> get tiposActividades => _tiposActividades;
  List<Map<String, dynamic>> get tiposCultivos => _tiposCultivos;
  List<Map<String, dynamic>> get variedades => _variedades;
  List<Map<String, dynamic>> get lotes => _lotes;
  List<Map<String, dynamic>> get insumos => _insumos;

  ActivityProvider() {
    _initData();
  }

  // 🔹 Carga los datos iniciales dividiendo en funciones
  Future<void> _initData() async {
    await _fetchCiclosYActividades();  // Carga ciclos y tipos de actividades
    _fetchCultivosYLotes();            // Carga cultivos y lotes en segundo plano
  }

  /// 🔹 Cargar ciclos y tipos de actividades
  Future<void> _fetchCiclosYActividades() async {
    try {
      _ciclos = await _apiService.fetchCiclos();
      _tiposActividades = await _apiService.fetchTiposActividades();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Error en _fetchCiclosYActividades(): $e");
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Cargar tipos de cultivos y lotes en segundo plano
  Future<void> _fetchCultivosYLotes() async {
    try {
      _tiposCultivos = await _apiService.fetchTiposCultivos();
      await fetchLotes(); // Asegurarse de que los lotes estén cargados
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Error en _fetchCultivosYLotes(): $e");
    }
  }

  /// 🔹 Obtener los lotes desde el ApiService
  Future<void> fetchLotes() async {
    try {
      _lotes = await _apiService.fetchLotes(); // Llamada al ApiService para obtener los lotes
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Error al obtener los lotes: $e");
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
      isLoadingVariedades = true;
      notifyListeners();

      int cultivoIdInt = int.tryParse(cultivoId) ?? 0;
      if (cultivoIdInt == 0) return;

      _variedades = await _apiService.fetchVariedades(cultivoIdInt);
      isLoadingVariedades = false;
      notifyListeners();
    } catch (e) {
      isLoadingVariedades = false;
      if (kDebugMode) print("❌ Error en getVariedadesByCultivo(): $e");
    }
  }

  /// 🔹 Agregar un nuevo ciclo
  Future<bool> addCiclo(Map<String, dynamic> cicloData) async {
    bool success = await _apiService.addCiclo(cicloData);
    if (success) await _fetchCiclosYActividades(); // ✅ Solo recarga ciclos y actividades
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
    if (success) await _fetchCiclosYActividades(); // ✅ Solo recarga ciclos y actividades
    return success;
  }

  /// 🔹 Obtener Insumos
  Future<void> fetchInsumos(String token) async {
    isLoading = true;
    notifyListeners(); // Notificar que estamos cargando

    try {
      final fetchedInsumos = await _apiService.fetchInsumos(token); // Llamada a ApiService
      _insumos = fetchedInsumos; // Almacenamos los insumos
    } catch (error) {
      _insumos = []; // Si hay error, dejamos la lista vacía
      if (kDebugMode) {
        print("Error al obtener insumos: $error");
      }
    } finally {
      isLoading = false;
      notifyListeners(); // Notificar que terminó la carga
    }
  }

  /// 🔹 Agregar un nuevo lote
  Future<int?> addLote(String nombre) async {
    int? loteId = await _apiService.addLote(nombre);
    if (loteId != null) {
      _lotes.add({"lot_id": loteId, "lot_nombre": nombre}); // Agregamos el nuevo lote a la lista
      notifyListeners(); // Notificamos para que la UI se actualice
    }
    return loteId;
  }

  /// 🔹 Verificar si el lote tiene un ciclo activo
  Future<bool> checkActiveCycle(int lotId) async {
    return await _apiService.hasActiveCycle(lotId); // Llamamos al método del ApiService
  }

}