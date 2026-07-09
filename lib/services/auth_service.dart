import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiService.login(email, password);
    if (!res['success']) return res;

    final data = res['data'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['access_token'] ?? '');
    await prefs.setString('nombre_usuario', data['usuario'] ?? '');
    await prefs.setString('email', email);

    return {'success': true, 'usuario': data['usuario'] ?? ''};
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
