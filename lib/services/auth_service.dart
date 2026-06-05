import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data['access_token']);

        return {'success': true, 'usuario': data['usuario']};
      }

      return {'success': false, 'message': data['detail'] ?? 'Error login'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
