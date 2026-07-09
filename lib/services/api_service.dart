import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  // ── LOGIN ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) return {'success': true, 'data': data};
      return {'success': false, 'message': data['detail'] ?? 'Error de login'};
    } catch (e) {
      return {'success': false, 'message': 'Sin conexión al servidor'};
    }
  }

  // ── MI FINCA ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> obtenerMiFinca(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/fincas/mi-finca'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) return {'success': true, 'data': data};
      return {'success': false, 'message': data['detail'] ?? 'Error'};
    } catch (e) {
      return {'success': false, 'message': 'Sin conexión al servidor'};
    }
  }

  // ── SUBIR FOTO FINCA ──────────────────────────────────────
  static Future<Map<String, dynamic>> subirFotoFinca(
      String token, int fincaId, File imagen) async {
    try {
      var req = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/fincas/upload-foto/$fincaId'),
      );
      req.headers['Authorization'] = 'Bearer $token';
      req.files.add(await http.MultipartFile.fromPath('foto', imagen.path));
      final res = await req.send();
      final body = await res.stream.bytesToString();
      if (res.statusCode == 200) {
        return {'success': true, 'message': 'Foto actualizada correctamente'};
      }
      return {'success': false, 'message': body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── GUARDAR FERMENTACIÓN (POST /fermentacion/) ────────────
  // ph, brix, temperatura, observacion — se llena varias veces
  static Future<Map<String, dynamic>> guardarFermentacion({
    required String token,
    required int fincaId,
    required double ph,
    required double brix,
    required double temperatura,
    String? observacion,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/fermentacion/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'finca_id': fincaId,
          'ph': ph,
          'brix': brix,
          'temperatura': temperatura,
          if (observacion != null && observacion.isNotEmpty)
            'observacion': observacion,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true};
      }
      return {'success': false, 'message': res.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── GUARDAR CALIDAD (POST /calidad/) ──────────────────────
  // puntaje_sensorial, perfil_tueste, notas_cata, observacion
  // Se llena una vez por cosecha
  static Future<Map<String, dynamic>> guardarCalidad({
    required String token,
    required int fincaId,
    double? puntajeSensorial,
    String? perfilTueste,
    String? notasCata,
    String? proceso,
    String? observacion,
  }) async {
    try {
      final body = {
        'finca_id': fincaId,
        if (puntajeSensorial != null) 'puntaje_sensorial': puntajeSensorial,
        if (perfilTueste != null && perfilTueste.isNotEmpty)
          'perfil_tueste': perfilTueste,
        if (notasCata != null && notasCata.isNotEmpty) 'notas_cata': notasCata,
        if (proceso != null && proceso.isNotEmpty) 'proceso': proceso,
        if (observacion != null && observacion.isNotEmpty)
          'observacion': observacion,
      };
      final res = await http.post(
        Uri.parse('$baseUrl/calidad/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true};
      }
      return {'success': false, 'message': res.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── HISTORIAL FERMENTACIÓN (GET /fermentacion/historial) ──
  static Future<Map<String, dynamic>> obtenerHistorial(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/fermentacion/historial'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) return {'success': true, 'data': data};
      return {'success': false, 'message': res.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── DATOS GRÁFICA (GET /fermentacion/grafica/{finca_id}) ────
  // Devuelve: fecha, brix, ph, temperatura
  static Future<Map<String, dynamic>> obtenerDatosGrafica(
      String token, int fincaId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/fermentacion/grafica/$fincaId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) return {'success': true, 'data': data};
      return {'success': false, 'message': res.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── CALIDAD PÚBLICA (GET /calidad/public/{finca_id}) ──────
  // Devuelve: fecha, puntaje_sensorial, perfil_tueste, notas_cata
  // Se usa en mi_finca_screen para mostrar el perfil de taza
  static Future<Map<String, dynamic>> obtenerCalidadPublica(int fincaId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/calidad/public/$fincaId'),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) return {'success': true, 'data': data};
      return {'success': false, 'message': res.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── GUARDAR SECADO (POST /secado/) ────────────────────────
  // humedad, factor_rendimiento, observacion — varias veces
  static Future<Map<String, dynamic>> guardarSecado({
    required String token,
    required int fincaId,
    required double humedad,
    required double factorRendimiento,
    String? observacion,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/secado/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'finca_id': fincaId,
          'humedad': humedad,
          'factor_rendimiento': factorRendimiento,
          if (observacion != null && observacion.isNotEmpty)
            'observacion': observacion,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true};
      }
      return {'success': false, 'message': res.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── HISTORIAL SECADO (GET /secado/historial) ──────────────
  static Future<Map<String, dynamic>> obtenerHistorialSecado(
      String token) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/secado/historial'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) return {'success': true, 'data': data};
      return {'success': false, 'message': res.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── GRÁFICA SECADO (GET /secado/grafica/{finca_id}) ───────
  // Devuelve: fecha, humedad, factor_rendimiento
  static Future<Map<String, dynamic>> obtenerGraficaSecado(
      String token, int fincaId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/secado/grafica/$fincaId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) return {'success': true, 'data': data};
      return {'success': false, 'message': res.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
