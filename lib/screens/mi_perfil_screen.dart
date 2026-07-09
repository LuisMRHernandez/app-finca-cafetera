import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';
import 'login_screen.dart';

class MiPerfilScreen extends StatelessWidget {
  final String nombreUsuario;
  final String email;
  const MiPerfilScreen({
    super.key,
    required this.nombreUsuario,
    required this.email,
  });

  String get _iniciales {
    final p = nombreUsuario.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U';
  }

  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.texto,
              ),
            ),
            content: const Text(
              '¿Estás seguro que deseas cerrar sesión?',
              style: TextStyle(color: AppColors.textoSuave),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textoSuave),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.verde, AppColors.verdeMedio],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _iniciales,
                        style: const TextStyle(
                          color: AppColors.blanco,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    nombreUsuario,
                    style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: AppColors.blanco.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.verdeClaro.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.verdeClaro.withOpacity(0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          size: 13,
                          color: Color(0xFFA5D6A7),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Caficultor activo',
                          style: TextStyle(
                            color: Color(0xFFA5D6A7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de la cuenta',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoSuave,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),

                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        InfoRow(
                          icono: Icons.person_rounded,
                          colorIcono: const Color(0xFF6A1B9A),
                          colorFondo: const Color(0xFFF3E5F5),
                          label: 'Nombre',
                          valor: nombreUsuario,
                        ),
                        InfoRow(
                          icono: Icons.mail_rounded,
                          colorIcono: const Color(0xFF1565C0),
                          colorFondo: const Color(0xFFE3F2FD),
                          label: 'Correo',
                          valor: email,
                        ),
                        InfoRow(
                          icono: Icons.shield_rounded,
                          colorIcono: AppColors.verdeClaro,
                          colorFondo: const Color(0xFFE8F5E0),
                          label: 'Rol',
                          valor: 'Caficultor',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Sesión',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textoSuave,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Material(
                    color: AppColors.fondoCard,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _cerrarSesion(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borde),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: AppColors.error,
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.error,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.borde,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                  Center(
                    child: Text(
                      'Finca Cafetera · v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textoSuave.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
