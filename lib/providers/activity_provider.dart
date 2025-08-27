// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _ciclos = [];
  List<Map<String, dynamic>> _tiposActividades = [];
  List<Map<String, dynamic>> _tiposCultivos = [];
  List<Map<String, dynamic>> _variedades = [];
  List<Map<String, dynamic>> _lotes = [];
  List<Map<String, dynamic>> _insumos = [];
  List<Map<String, dynamic>> _actividadesRecientes = [];
  List<Map<String, dynamic>> _tareas = [];
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _actividades = [];

  bool _isLoadingUsuarios = false;
  bool isLoading = true;
  bool isLoadingVariedades = false;
  
  Map<String, dynamic>? actividadActual;
  List<Map<String, dynamic>> get ciclos => _ciclos;
  List<Map<String, dynamic>> get tiposActividades => _tiposActividades;
  List<Map<String, dynamic>> get tiposCultivos => _tiposCultivos;
  List<Map<String, dynamic>> get variedades => _variedades;
  List<Map<String, dynamic>> get lotes => _lotes;
  List<Map<String, dynamic>> get insumos => _insumos;
  List<Map<String, dynamic>> get actividadesRecientes => _actividadesRecientes;
  List<Map<String, dynamic>> get tareas => _tareas;
  List<Map<String, dynamic>> get usuarios => _usuarios;
  List<Map<String, dynamic>> get actividades => _actividades;
  bool get isLoadingUsuarios => _isLoadingUsuarios;

  bool _recientesLoading = true; // arranca en true
  bool _tareasLoading = true;    // arranca en true

  bool get recientesLoading => _recientesLoading;
  bool get tareasLoading => _tareasLoading;

  ActivityProvider() {
    _initData();

    // dispara los fetch en paralelo al crearse el provider
    Future.microtask(() {
      fetchActividadesRecientes();
      fetchTareas();
    });
  }

  // 🔹 Carga los datos iniciales dividiendo en funciones
  Future<void> _initData() async {
    await _fetchCiclosYActividades();  // Carga ciclos y tipos de actividades
    _fetchCultivosYLotes();            // Carga cultivos y lotes en segundo plano
  }

  /// 🔹 Cargar ciclos y tipos de actividades
  Future<void> _fetchCiclosYActividades() async {
    try {
      _ciclos = await _apiService.fetchCiclosActivos();
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

  /// 🔹 Agregar una nueva variedad
  Future<int?> addVariedad(String nombre, int cultivoId) async {
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

  /// 🔹 Cargar las últimas 3 actividades registradas, ordenadas por la fecha de actividad
  Future<void> fetchActividadesRecientes() async {
    _recientesLoading = true;
    notifyListeners();
    try {
      final actividades = await _apiService.fetchActividades();

      // Normalizar a LOCAL y comparar por día (no por hora)
      DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
      final now = DateTime.now().toLocal();
      final today = day(now);

      // Mapear con campos auxiliares seguros
      final parsed = actividades.map((a) {
        final actDateLocal = DateTime.parse(a['act_fecha']).toLocal();
        final actDay = day(actDateLocal);

        DateTime createdAtSafe;
        final rawCreated = a['created_at'];
        if (rawCreated == null || (rawCreated is String && rawCreated.trim().isEmpty)) {
          // si no viene, usa epoch para que quede al final
          createdAtSafe = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          createdAtSafe = DateTime.parse(rawCreated).toLocal();
        }

        return {
          ...a,
          '_actDay': actDay,
          '_createdAt': createdAtSafe,
        };
      }).toList();

      // Solo pasadas o de hoy: !(fechaActividad > hoy)
      parsed.removeWhere((a) => (a['_actDay'] as DateTime).isAfter(today));

      // Orden: fechaActividad desc, y si empatan, createdAt desc
      parsed.sort((a, b) {
        final da = a['_actDay'] as DateTime;
        final db = b['_actDay'] as DateTime;
        final cmp = db.compareTo(da);
        if (cmp != 0) return cmp;
        final ca = a['_createdAt'] as DateTime;
        final cb = b['_createdAt'] as DateTime;
        return cb.compareTo(ca);
      });

      // Toma las 3 más recientes
      _actividadesRecientes = parsed.take(3).map((a) {
        final copy = Map<String, dynamic>.from(a);
        copy.remove('_actDay');
        copy.remove('_createdAt');
        return copy;
      }).toList();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Error al obtener actividades recientes: $e");
    } finally {
      _recientesLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Cargar las próximas tareas (actividades con fecha futura)
  Future<void> fetchTareas() async {
    _tareasLoading = true;
    notifyListeners();
    try {
      final actividades = await _apiService.fetchActividades();
      DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
      final today = day(DateTime.now().toLocal());

      _tareas = actividades.where((a) {
        final d = day(DateTime.parse(a['act_fecha']).toLocal());
        return d.isAfter(today); // estrictamente futuras
      }).toList();

      _tareas.sort((a, b) {
        final da = DateTime.parse(a['act_fecha']).toLocal();
        final db = DateTime.parse(b['act_fecha']).toLocal();
        return da.compareTo(db);
      });

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Error al obtener tareas: $e");
    } finally {
      _tareasLoading = false;
      notifyListeners();
    }
  }

  // Función para agregar un nuevo insumo y obtener los datos
  Future<List<Map<String, dynamic>>> addInsumoNuevo(List<Map<String, dynamic>> insumos) async {
    try {
      List<Map<String, dynamic>> insumosGuardados = await _apiService.addInsumoNuevo(insumos);

      if (insumosGuardados.isNotEmpty) {
        return insumosGuardados;
      } else {
        throw Exception("Error al guardar los insumos nuevos");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error al agregar insumo nuevo en ActivityProvider: $e");
      return [];
    }
  }

  // 🔹 Método para obtener la actividad desde la API
  Future<Map<String, dynamic>?> fetchActivityById(int actId) async {
    try {
      final updatedActivity = await ApiService().fetchActivityById(actId);

      if (updatedActivity != null) {
        actividadActual = updatedActivity;
        notifyListeners(); // ✅ Notifica cambios
        return updatedActivity;
      }
    } catch (e) {
      print("Error al obtener actividad: $e");
    }
    return null;
  }

  // 🔹 Método para actualizar una actividad
  Future<bool> updateActivity(Map<String, dynamic> activityData) async {
    try {
      final success = await ApiService().updateActivity(activityData);

      if (success) {
        // Recargar la actividad actualizada y refrescar listas
        await Future.wait([
          fetchActivityById(activityData["act_id"]),
          fetchActividadesRecientes(),
          fetchTareas(),
        ]);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al actualizar la actividad: $e");
      }
      return false;
    }
  }

  // 🔹 Obtener usuarios desde la API
  Future<void> fetchUsuarios() async {
    _isLoadingUsuarios = true;
    notifyListeners();

    try {
      _usuarios = await _apiService.fetchUsuarios();
    } catch (e) {
      print("Error al obtener usuarios: $e");
    }

    _isLoadingUsuarios = false;
    notifyListeners();
  }

  /// 🔹 Obtener todas las actividades
  Future<void> fetchAllActividades() async {
    try {
      _actividades = await _apiService.fetchActividades();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error: $e");
    }
  }

  // Método para eliminar una actividad
  Future<bool> deleteActivity(int activityId) async {
    try {
      bool success = await _apiService.deleteActivity(activityId);
      
      if (success) {
        // Si la eliminación fue exitosa, se puede notificar que la actividad fue eliminada
        notifyListeners();
      }
      
      return success;
    } catch (error) {
      print("Error al eliminar actividad Provider: $error");
      return false;
    }
  }

}