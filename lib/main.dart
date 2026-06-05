import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF3E2723),
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Leer token y datos guardados
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E342E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F0EB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4E342E),
          foregroundColor: Color(0xFFEFEBE9),
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFBCAAA4)),
          titleTextStyle: TextStyle(
            color: Color(0xFFEFEBE9),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E342E),
            foregroundColor: const Color(0xFFEFEBE9),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Color(0xFF795548)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4E342E), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE8DDD5)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF3E2723),
          contentTextStyle: const TextStyle(color: Color(0xFFEFEBE9)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      // Si hay token guardado → HomeScreen, si no → LoginScreen
      home:
          token.isNotEmpty
              ? HomeScreen(
                nombreUsuario: nombreUsuario,
                token: token,
                email: email,
              )
              : const LoginScreen(),
    );
  }
}
