import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final partes = nombreUsuario.trim().split(" ");
    if (partes.length >= 2) {
      return "${partes[0][0]}${partes[1][0]}".toUpperCase();
    }
    return nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : "U";
  }

  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Cerrar sesión",
              style: TextStyle(
                color: Color(0xFF3E2723),
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              "¿Estás seguro que deseas cerrar sesión?",
              style: TextStyle(color: Color(0xFF5D4037)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Color(0xFF8D6E63)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // ── BORRAR token de SharedPreferences ──────
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  // ───────────────────────────────────────────
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBF360C),
                ),
                child: const Text("Cerrar sesión"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header con avatar ─────────────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFF4E342E),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  // Avatar con iniciales
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _iniciales,
                        style: const TextStyle(
                          color: Color(0xFFEFEBE9),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    nombreUsuario,
                    style: const TextStyle(
                      color: Color(0xFFEFEBE9),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Color(0xFFBCAAA4),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          size: 14,
                          color: Color(0xFFA5D6A7),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Caficultor activo",
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

            // ── Información ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Información de la cuenta",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4037),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8DDD5)),
                    ),
                    child: Column(
                      children: [
                        _PerfilRow(
                          icono: Icons.person_rounded,
                          colorIcono: const Color(0xFF6A1B9A),
                          colorFondo: const Color(0xFFF3E5F5),
                          label: "Nombre",
                          valor: nombreUsuario,
                          isFirst: true,
                        ),
                        _PerfilRow(
                          icono: Icons.mail_rounded,
                          colorIcono: const Color(0xFF1565C0),
                          colorFondo: const Color(0xFFE3F2FD),
                          label: "Correo",
                          valor: email,
                        ),
                        _PerfilRow(
                          icono: Icons.shield_rounded,
                          colorIcono: const Color(0xFF2E7D32),
                          colorFondo: const Color(0xFFE8F5E9),
                          label: "Rol",
                          valor: "Caficultor",
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Sesión",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4037),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Botón cerrar sesión
                  Material(
                    color: Colors.white,
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
                          border: Border.all(color: const Color(0xFFE8DDD5)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFBF360C),
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Cerrar sesión",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFBF360C),
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFBCAAA4),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Versión de la app
                  Center(
                    child: Text(
                      "Finca Cafetera · v1.0.0",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
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

class _PerfilRow extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color colorFondo;
  final String label;
  final String valor;
  final bool isFirst;
  final bool isLast;

  const _PerfilRow({
    required this.icono,
    required this.colorIcono,
    required this.colorFondo,
    required this.label,
    required this.valor,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        border:
            !isLast
                ? const Border(bottom: BorderSide(color: Color(0xFFEEE8E4)))
                : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorFondo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: colorIcono, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3E2723),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
