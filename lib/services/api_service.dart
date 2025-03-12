import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api"; // Para emulador Android
  // static const String baseUrl = "http://127.0.0.1:8000/api"; // Para Web o iOS

  /// 🔹 Obtener el token almacenado
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print("No hay token almacenado o el token está vacío.");
      }
      return null;
    }
    return token;
  }

  /// 🔹 Método genérico para manejar respuestas HTTP
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      if (kDebugMode) {
        print("❌ Error ${response.statusCode}: ${response.body}");
      }
      throw Exception("Error en la solicitud: ${response.statusCode}");
    }
  }

  /// 🔹 Login del usuario
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"uss_email": email, "uss_clave": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", data["token"]);  // Guardar el token

      if (data["user"] != null && data["user"]["uss_id"] != null) {
        await prefs.setInt("uss_id", data["user"]["uss_id"]); // Guardar el ID del usuario
      } else {
        if (kDebugMode) {
          print("Error: El uss_id es null.");
        }
      }
      return true;  // Login exitoso
    } else {
      // Return false if the response status code is not 200
      if (kDebugMode) {
        print("Error: Login failed with status code ${response.statusCode}");
      }
      return false;
    }
  }

  /// 🔹 Logout del usuario
  Future<void> logout() async {
    final String? token = await _getToken();
    
    if (token != null) {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("auth_token");  // Eliminar el token
        await prefs.remove("uss_id");      // Eliminar el ID de usuario también
      } else {
        if (kDebugMode) {
          print("❌ Error al cerrar sesión: ${response.body}");
        }
      }
    }
  }

  /// 🔹 Obtener las actividades con autenticación
  Future<List<Map<String, dynamic>>> fetchActividades() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/actividades"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _handleResponse(response).cast<Map<String, dynamic>>();
  }

  /// 🔹 Obtener los ciclos activos (sin `ci_fechafin`)
  Future<List<Map<String, dynamic>>> fetchCiclos() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/ciclos"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _handleResponse(response)
        .where((ciclo) => ciclo["ci_fechafin"] == null) // ✅ Solo ciclos activos
        .toList()
        .cast<Map<String, dynamic>>();
  }

  /// 🔹 Obtener los lotes
  Future<List<Map<String, dynamic>>> fetchLotes() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/lotes"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _handleResponse(response).cast<Map<String, dynamic>>();
  }

  /// 🔹 Obtener los insumos
  Future<List<Map<String, dynamic>>> fetchInsumos(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/insumos"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Autenticación con el token
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>(); // Convertimos a lista de mapas
    } else {
      throw Exception("Error al cargar insumos");
    }
  }

  /// 🔹 Agregar una nueva actividad a la API
  Future<bool> addActivity(Map<String, dynamic> activityData) async {
    final String? token = await _getToken(); // ✅ Obtener token del usuario autenticado

    final response = await http.post(
      Uri.parse("$baseUrl/actividades"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(activityData),
    );

    if (response.statusCode == 201) {
      return true; // ✅ Actividad creada con éxito
    } else {
      if (kDebugMode) {
        print("❌ Error al agregar actividad: ${response.body}");
      }
      return false; // ❌ Fallo al crear actividad
    }
  }

    /// 🔹 Obtener los tipos de actividades desde la API
  Future<List<Map<String, dynamic>>> fetchTiposActividades() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/tipos/actividades"), // ✅ Endpoint para obtener tipos de actividades
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _handleResponse(response).cast<Map<String, dynamic>>();
  }
  
    /// 🔹 Obtener los tipos de cultivos desde la API
Future<List<Map<String, dynamic>>> fetchTiposCultivos() async {
  final String? token = await _getToken();
  final response = await http.get(
    Uri.parse("$baseUrl/tipos/cultivo"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception("Error al obtener tipos de cultivos");
  }
}

  /// 🔹 Obtener las variedades de un tipo de cultivo
  Future<List<Map<String, dynamic>>> fetchVariedades(int tpCulId) async {
    final response = await http.get(Uri.parse("$baseUrl/variedades/$tpCulId")); // ✅ Ahora envía el ID correcto

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      return data.cast<Map<String, dynamic>>();
    } else {
      if (kDebugMode) {
        print("❌ Error en fetchVariedades(): ${response.body}");
      }
      throw Exception("Error al obtener variedades");
    }
  }

  /// 🔹 Agregar un nuevo ciclo a la API
  Future<bool> addCiclo(Map<String, dynamic> cicloData) async {
    try {
      final String? token = await _getToken();
      if (token == null) {
        return false; // No se puede continuar sin un token
      }

      // Recuperar el uss_id desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt("uss_id");
      if (userId == null) {
        return false; // Si no hay un user ID, no se puede proceder
      }

      // Añadir el uss_id al cicloData antes de enviarlo
      cicloData["uss_id"] = userId; 

      final response = await http.post(
        Uri.parse("$baseUrl/ciclos"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",  // Asegúrate de que el token sea válido
        },
        body: jsonEncode(cicloData),
      );

      if (response.statusCode == 201) {
        return true;  // Ciclo creado exitosamente
      } else {
        if (kDebugMode) {
          print("❌ Error al agregar ciclo: ${response.body}");
        }
        throw Exception("Error en la solicitud: ${response.statusCode}");
      }
    } catch (e) {
      // Captura cualquier excepción (por ejemplo, problemas de red)
      if (kDebugMode) {
        print("❌ Error de conexión: $e");
      }
      return false; // Si ocurre un error, retorna false
    }
  }

  /// 🔹 Agregar una nueva variedad a la API
Future<int?> addVariedad(String nombre, String cultivoId) async {
  final String? token = await _getToken();

  // Crea el objeto JSON
  final bodyData = jsonEncode({
    "tpCul_id": int.parse(cultivoId),
    "tpVar_nombre": nombre,
  });

  final response = await http.post(
    Uri.parse("$baseUrl/tipos/variedad"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: bodyData,
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data["tpVar_id"]; // Retorna el ID de la nueva variedad
  }
  return null;
}


  /// 🔹 Obtener el ID del usuario autenticado
  Future<int?> getLoggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("uss_id");
    return userId;
  }

  /// 🔹 Agregar un nuevo lote a la API
  Future<int?> addLote(String nombre) async {
    final String? token = await _getToken();

    // Crea el objeto JSON
    final bodyData = jsonEncode({
      "lot_nombre": nombre,
    });

    final response = await http.post(
      Uri.parse("$baseUrl/lotes"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: bodyData,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data["lot_id"]; // Retorna el ID del nuevo lote
    }
    return null;
  }

  /// 🔹 Verificar si el lote tiene un ciclo activo (sin `ci_fechafin`)
  Future<bool> hasActiveCycle(int lotId) async {
    final String? token = await _getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/ciclos/lote/$lotId"),  // Filtra por el ID del lote
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // Verificar si hay algún ciclo activo (sin `ci_fechafin`)
      return data.isNotEmpty;  // Si hay ciclos activos, devuelve true
    } else if (response.statusCode == 404) {
      // Si no hay ciclos activos, devuelve false
      return false;
    } else {
      throw Exception("Error al verificar ciclos activos");
    }
  }

  /// 🔹 Obtener los ciclos activos (sin `ci_fechafin`)
  Future<List<Map<String, dynamic>>> fetchCiclosActivos() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/ciclos"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    List<dynamic> data = _handleResponse(response);
    // Filtramos los ciclos para obtener solo aquellos que no tienen ci_fechafin
    List<Map<String, dynamic>> ciclosActivos = data
        .where((ciclo) => ciclo["ci_fechafin"] == null)
        .toList()
        .cast<Map<String, dynamic>>();
    
    return ciclosActivos;
  }

  /// 🔹 Obtener las últimas 3 actividades recientes, ordenadas por fecha
  Future<List<Map<String, dynamic>>> fetchActividadesRecientes() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/actividades"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    List<dynamic> data = _handleResponse(response);

    // Ordenar actividades por fecha (de más reciente a más antigua)
    data.sort((a, b) => DateTime.parse(b['act_fecha']).compareTo(DateTime.parse(a['act_fecha'])));

    // Tomamos las 3 primeras actividades
    return data.take(3).toList().cast<Map<String, dynamic>>();
  }

  /// 🔹 Obtener las próximas tareas (actividades con fecha de inicio futura)
  Future<List<Map<String, dynamic>>> fetchProximasTareas() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/actividades"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    List<dynamic> data = _handleResponse(response);

    // Filtrar actividades con fecha de inicio futura
    DateTime now = DateTime.now();
    return data.where((actividad) {
      DateTime fechaInicio = DateTime.parse(actividad['ci_fechaini']);
      return fechaInicio.isAfter(now);
    }).toList().cast<Map<String, dynamic>>();
  }

}
