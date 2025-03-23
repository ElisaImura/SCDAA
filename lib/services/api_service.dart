// ignore_for_file: avoid_print

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

    // Obtener la respuesta procesada
    List<Map<String, dynamic>> actividades = _handleResponse(response).cast<Map<String, dynamic>>();

    return actividades;
  }

  /// 🔹 Obtener un ciclo específico
  Future<Map<String, dynamic>> fetchCicloSpecific(int id) async {
    final String? token = await _getToken();
    
    final response = await http.get(
      Uri.parse("$baseUrl/ciclos/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _handleResponse(response) as Map<String, dynamic>;
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
    final String? token = await _getToken();

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
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/variedades/$tpCulId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

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

  /// 🔹 Obtener los ciclos inactivos (con `ci_fechafin`)
  Future<List<Map<String, dynamic>>> fetchCiclosInactivos() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/ciclos"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    List<dynamic> data = _handleResponse(response);
    // Filtramos los ciclos para obtener solo aquellos que tienen ci_fechafin
    List<Map<String, dynamic>> ciclosInactivos = data
        .where((ciclo) => ciclo["ci_fechafin"] != null)
        .toList()
        .cast<Map<String, dynamic>>();
    
    return ciclosInactivos;
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

  // Función para agregar un nuevo insumo (uno por uno) y devolver los insumos con sus IDs generados
  Future<List<Map<String, dynamic>>> addInsumoNuevo(List<Map<String, dynamic>> insumos) async {
    try {
      final String? token = await _getToken();
      List<Map<String, dynamic>> insumosGuardados = [];  // Lista para almacenar los insumos guardados

      // Iterar sobre cada insumo y hacer una solicitud HTTP para cada uno
      for (var insumo in insumos) {

        final response = await http.post(
          Uri.parse("$baseUrl/insumos"),  // Endpoint para crear un nuevo insumo
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(insumo),  // Enviamos solo el insumo
        );

        print(jsonEncode(insumo));  

        // Verificar si el insumo se guardó correctamente
        if (response.statusCode == 201) {
          // Si el insumo se guarda correctamente, obtenemos los datos del insumo guardado
          Map<String, dynamic> insumoGuardado = jsonDecode(response.body);
          insumosGuardados.add(insumoGuardado);  // Agregamos el insumo guardado a la lista
        } else {
          // Si alguna solicitud falla, lanza una excepción
          if (kDebugMode) {
            print("Error al guardar el insumo: ${response.body}");
          }
          return [];  // Retornamos una lista vacía si hubo un error
        }
      }

      // Devolver la lista de insumos guardados con sus ids
      return insumosGuardados;
    } catch (e) {
      if (kDebugMode) print("❌ Error al guardar los insumos nuevos: $e");
      return [];  // En caso de error, retornamos una lista vacía
    }
  }

  // Función para agregar los datos del clima
  Future<bool> addWeatherData(Map<String, dynamic> weatherData) async {
    try {
      final String? token = await _getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/clima"),  // Endpoint para guardar datos del clima
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(weatherData),  // Los datos del clima
      );

      if (response.statusCode == 201) {
        return true; // Datos guardados exitosamente
      } else {
        throw Exception("Error al guardar los datos del clima");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error al guardar datos del clima: $e");
      return false;
    }
  }

  // Función para obtener los datos del clima
  Future<List<Map<String, dynamic>>> fetchClima() async {
    final String? token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/clima"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener los datos del clima');
      }
    } catch (e) {
      throw Exception('Error al obtener los datos del clima: $e');
    }
  }

  // 🔹 Obtener una actividad específica por su ID
  Future<Map<String, dynamic>?> fetchActivityById(int actId) async {
    final String? token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/actividades/$actId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Error al obtener la actividad: ${response.body}");
      }
    } catch (e) {
      print("Error en la conexión a la API: $e");
    }
    return null;
  }

  // Función para actualizar la actividad
  Future<bool> updateActivity(Map<String, dynamic> activityData) async {
    final String? token = await _getToken();  // Asegúrate de tener la función para obtener el token

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/actividades/${activityData['act_id']}"),  // Usa el `act_id` para identificar la actividad
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(activityData),  // Envía los datos de la actividad a actualizar
      );

      if (response.statusCode == 200) {
        // Si el servidor responde con éxito, la actividad se actualiza correctamente
        return true;
      } else {
        // Si algo falla en la actualización
        if (kDebugMode) {
          print("Error al actualizar la actividad: ${response.body}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error en la conexión a la API: $e");
      }
      return false;
    }
  }

  // 🔹 Obtener lista de usuarios
  Future<List<Map<String, dynamic>>> fetchUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("auth_token");

    if (token == null) {
      throw Exception("Token no encontrado. Inicia sesión nuevamente.");
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/usuarios"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> usuarios = json.decode(response.body);
        return usuarios.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Error al obtener usuarios: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error en la conexión: $e");
    }
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("auth_token");

      if (token == null) {
        throw Exception("Token no encontrado. Inicia sesión nuevamente.");
      }

      // Obtenemos el ID del usuario antes de hacer la solicitud
      final int? userId = await getLoggedUserId();  // Asegúrate de usar await aquí

      if (userId == null) {
        throw Exception("ID de usuario no encontrado.");
      }

      // Realizamos la solicitud a la API
      final response = await http.get(
        Uri.parse("$baseUrl/usuarios/$userId"), // Asegúrate de usar el ID real
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retorna los datos del usuario
      } else {
        throw Exception("Error al obtener datos del usuario: ${response.body}");
      }
    } catch (e) {
      print("Error en getUserInfo(): $e");
      return {}; // Retorna un mapa vacío en caso de error
    }
  }

  Future<Map<String, dynamic>> getUserByID(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("auth_token");

      if (token == null) {
        throw Exception("Token no encontrado. Inicia sesión nuevamente.");
      }

      // Realizamos la solicitud a la API
      final response = await http.get(
        Uri.parse("$baseUrl/usuarios/$id"), // Asegúrate de usar el ID real
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retorna los datos del usuario
      } else {
        throw Exception("Error al obtener datos del usuario: ${response.body}");
      }
    } catch (e) {
      print("Error en getUserInfo(): $e");
      return {}; // Retorna un mapa vacío en caso de error
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final String? token = await _getToken();

    if (token == null) {
      throw Exception('Token is missing. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/usuarios'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else if (response.statusCode == 401) {
      // Token expired or invalid
      throw Exception('Session expired. Please log in again.');
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<bool> updateUser(int userId, String name, String email, int role) async {
    final String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/$userId'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "uss_nombre": name,
        "uss_email": email,
        "rol_id": role,
      }),
    );

    if (response.statusCode == 200) {
      return true; // La actualización fue exitosa
    } else {
      return false; // Hubo un error
    }
  }

  // Función para obtener los roles desde la API
  Future<List<Map<String, dynamic>>> getRoles() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/roles'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load roles');
    }
  }

  Future<bool> deleteUser(int userId) async {
    final String? token = await _getToken();

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/$userId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        return true;  // Usuario eliminado con éxito
      } else {
        throw Exception('Error al eliminar el usuario');
      }
    } catch (e) {
      print("Error al eliminar usuario: $e");
      return false;
    }
  }

  /// 🔹 Agregar un nuevo usuario a la API
  Future<bool> addUser(String name, String email, int role, String password) async {
    final String? token = await _getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/usuarios"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "uss_nombre": name,
        "uss_email": email,
        "rol_id": role,
        "uss_clave": password,
      }),
    );

    print(jsonEncode({
      "uss_nombre": name,
      "uss_email": email,
      "rol_id": role,
      "uss_clave": password,
    }),);

    if (response.statusCode == 201) {
      return true; // Usuario creado exitosamente
    } else {
      if (kDebugMode) {
        print("❌ Error al agregar usuario: ${response.body}");
      }
      return false; // Fallo al crear usuario
    }
  }

  // Funcion para obtener todos los climas
  Future<List<Map<String, dynamic>>> getAllWeatherData() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/clima'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Método para eliminar una actividad
  Future<bool> deleteActivity(int activityId) async {
    final String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/actividades/$activityId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;  // Actividad eliminada con éxito
    } else {
      return false;  // Error al eliminar la actividad
    }
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

  // Método para obtener todos los lotes
  Future<List<dynamic>> getLotes() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/lotes'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, decodificamos los datos
      final List<dynamic> lotes = json.decode(response.body);
      return lotes;
    } else {
      throw Exception('Error al obtener los lotes');
    }
  }

  // Método para editar un lote
  Future<bool> editLote(int loteId, Map<String, dynamic> loteData) async {
    final String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/lotes/$loteId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(loteData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al editar el lote');
    }
  }

  // Método para eliminar un lote
  Future<bool> deleteLote(int loteId) async {
    final String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/lotes/$loteId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al eliminar el lote');
    }
  }

  // Obtener insumos desde la API
  Future<List<Map<String, dynamic>>> getInsumos() async {
    final String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/insumos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Error al obtener insumos');
    }
  }

  // Agregar un nuevo insumo
  Future<int?> addInsumo(Map<String, dynamic> insumoData) async {
    final String? token = await _getToken();
    insumoData['ins_desc'] = insumoData['ins_desc'].toString();
    insumoData['ins_unidad_medida'] = insumoData['ins_unidad_medida'].toString();

    final bodyData = jsonEncode(insumoData);

    final response = await http.post(
      Uri.parse('$baseUrl/insumos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: bodyData,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['ins_id']; // Retorna el ID del insumo recién creado
    } else {
      throw Exception('Error al agregar el insumo');
    }
  }

  // Editar un insumo existente
  Future<bool> editInsumo(int insumoId, Map<String, dynamic> insumoData) async {
    final String? token = await _getToken();
    final bodyData = jsonEncode(insumoData);

    final response = await http.put(
      Uri.parse('$baseUrl/insumos/$insumoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: bodyData,
    );

    return response.statusCode == 200; 
  }

  // Eliminar un insumo
  Future<bool> deleteInsumo(int insumoId) async {
    final String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/insumos/$insumoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  // 🔹 Editar un ciclo
  Future<bool> editCiclo(int id, Map<String, dynamic> cicloData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/ciclos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cicloData),
    );

    return response.statusCode == 200;
  }

  // Eliminar un insumo
  Future<bool> deleteCiclo(int cicloId) async {
    final String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/ciclos/$cicloId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}
