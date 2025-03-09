import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api"; // Para emulador Android
  // static const String baseUrl = "http://127.0.0.1:8000/api"; // Para Web o iOS

  // Obtener las actividades
  Future<List<Map<String, dynamic>>> fetchActividades() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/actividades"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        if (kDebugMode) {
          print("Error: ${response.statusCode} - ${response.body}");
        } // ✅ Depuración
        throw Exception("Error al obtener actividades");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error de conexión: $e");
      } // ✅ Depuración
      return [];
    }
  }



  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"uss_email": email, "uss_clave": password}), // ✅ Campos correctos
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", data["token"]); // ✅ Guardamos el token
      return true; // ✅ Login exitoso
    } else {
      return false; // ❌ Error en login
    }
  }
}
