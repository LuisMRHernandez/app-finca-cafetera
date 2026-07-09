import 'package:flutter/material.dart';

// ── URL base de la API ────────────────────────────────────────
const String baseUrl = 'https://api-finca-web-app.onrender.com';

// ── Paleta de colores ─────────────────────────────────────────
class AppColors {
  static const verde = Color(0xFF1a3a2a);
  static const verdeMedio = Color(0xFF2d5a3f);
  static const verdeClaro = Color(0xFF4a8c62);
  static const dorado = Color(0xFFc9a84c);
  static const doradoClaro = Color(0xFFe8c97a);
  static const crema = Color(0xFFf5f0e8);
  static const blanco = Color(0xFFfdfcfa);
  static const texto = Color(0xFF1a1a18);
  static const textoSuave = Color(0xFF5a5a54);

  // Utilitarios
  static const borde = Color(0xFFE2D9CC);
  static const fondoCard = Color(0xFFfdfcfa);
  static const error = Color(0xFFBF360C);
  static const exito = Color(0xFF2E7D32);
  static const advertencia = Color(0xFFF57F17);
}

// ── Tema global ───────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: AppColors.crema,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.verde,
          brightness: Brightness.light,
          surface: AppColors.crema,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.verde,
          foregroundColor: AppColors.blanco,
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.doradoClaro),
          titleTextStyle: TextStyle(
            color: AppColors.blanco,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.verde,
            foregroundColor: AppColors.blanco,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.verde,
            side: const BorderSide(color: AppColors.verde),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.blanco,
          labelStyle:
              const TextStyle(color: AppColors.textoSuave, fontSize: 14),
          hintStyle: TextStyle(
            color: AppColors.textoSuave.withOpacity(0.5),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borde),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borde),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.verde, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        cardTheme: CardTheme(
          color: AppColors.fondoCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borde),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.verde,
          contentTextStyle: const TextStyle(color: AppColors.blanco),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
