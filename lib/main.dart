import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/constants.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.verde,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';
  final nombre = prefs.getString('nombre_usuario') ?? '';
  final email = prefs.getString('email') ?? '';

  runApp(MiApp(token: token, nombreUsuario: nombre, email: email));
}

class MiApp extends StatelessWidget {
  final String token;
  final String nombreUsuario;
  final String email;

  const MiApp({
    super.key,
    required this.token,
    required this.nombreUsuario,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finca Cafetera',
      theme: AppTheme.theme,
      home:
          token.isNotEmpty
              ? HomeScreen(
                token: token,
                nombreUsuario: nombreUsuario,
                email: email,
              )
              : const LoginScreen(),
    );
  }
}
