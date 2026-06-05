import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl = "http://192.168.1.5:8000";

  // ==========================
  // LOGIN
  // ==========================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "message": data["detail"] ?? "Error de login",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión"};
    }
  }

  // ==========================
  // PROBAR CONEXIÓN
  // ==========================
  static Future<bool> probarConexion() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==========================
  // OBTENER MI FINCA
  // ==========================
  static Future<Map<String, dynamic>> obtenerMiFinca(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/fincas/mi-finca"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["detail"] ?? "Error"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión"};
    }
  }

  static Future<Map<String, dynamic>> subirFotoFinca(
    String token,
    int fincaId,
    File imagen,
  ) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/fincas/upload-foto/$fincaId"),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.files.add(await http.MultipartFile.fromPath("foto", imagen.path));

      var response = await request.send();

      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return {"success": true, "message": "Foto subida correctamente"};
      } else {
        return {"success": false, "message": responseData};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> guardarFermentacion({
    required String token,
    required int fincaId,
    required double ph,
    required double brix,
    required double temperatura,
    required String observacion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fermentacion/'),

        headers: {
          "Content-Type": "application/json",

          "Authorization": "Bearer $token",
        },

        body: jsonEncode({
          "finca_id": fincaId,
          "ph": ph,
          "brix": brix,
          "temperatura": temperatura,
          "observacion": observacion,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      }

      return {"success": false, "message": response.body};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> obtenerHistorialFermentacion(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/fermentacion/historial"),

        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      }

      return {"success": false, "message": response.body};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> obtenerDatosGrafica(
    String token,
    int fincaId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/fermentacion/grafica/$fincaId"),

        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      }

      return {"success": false, "message": response.body};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
