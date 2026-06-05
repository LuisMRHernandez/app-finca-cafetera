import 'package:flutter/material.dart';
import 'mi_finca_screen.dart';
import 'foto_finca_screen.dart';
import 'mi_perfil_screen.dart';
import 'fermentacion_screen.dart';
import 'historial_fermentacion_screen.dart';
import 'grafica_fermentacion_screen.dart';

class HomeScreen extends StatelessWidget {
  final String nombreUsuario;
  final String token;
  final String email;

  const HomeScreen({
    super.key,
    required this.nombreUsuario,
    required this.token,
    required this.email,
  });

  static const _cafeMedio = Color(0xFF4E342E);

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(
        titulo: "Mi Finca",
        subtitulo: "Información y detalles",
        icono: Icons.terrain_rounded,
        colorFondo: const Color(0xFFFBE9E7),
        colorIcono: const Color(0xFFBF360C),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MiFincaScreen(token: token)),
            ),
      ),
      _MenuItem(
        titulo: "Fermentación",
        subtitulo: "Registrar nuevo dato",
        icono: Icons.science_rounded,
        colorFondo: const Color(0xFFE8F5E9),
        colorIcono: const Color(0xFF2E7D32),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FermentacionScreen(token: token),
              ),
            ),
      ),
      _MenuItem(
        titulo: "Gráficas",
        subtitulo: "Visualización de tendencias",
        icono: Icons.show_chart_rounded,
        colorFondo: const Color(0xFFE3F2FD),
        colorIcono: const Color(0xFF1565C0),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GraficaFermentacionScreen(token: token),
              ),
            ),
      ),
      _MenuItem(
        titulo: "Historial",
        subtitulo: "Ver registros anteriores",
        icono: Icons.history_rounded,
        colorFondo: const Color(0xFFFFF8E1),
        colorIcono: const Color(0xFFF57F17),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistorialFermentacionScreen(token: token),
              ),
            ),
      ),
      _MenuItem(
        titulo: "Mi Perfil",
        subtitulo: "Datos del usuario",
        icono: Icons.person_rounded,
        colorFondo: const Color(0xFFF3E5F5),
        colorIcono: const Color(0xFF6A1B9A),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => MiPerfilScreen(
                      nombreUsuario: nombreUsuario,
                      email: email,
                    ),
              ),
            ),
      ),
      _MenuItem(
        titulo: "Foto Finca",
        subtitulo: "Actualizar imagen",
        icono: Icons.camera_alt_rounded,
        colorFondo: const Color(0xFFFCE4EC),
        colorIcono: const Color(0xFFAD1457),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FotoFincaScreen(token: token)),
            ),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: _cafeMedio,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: _cafeMedio,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.coffee_rounded,
                            color: Color(0xFFEFEBE9),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hola, $nombreUsuario 👋",
                              style: const TextStyle(
                                color: Color(0xFFEFEBE9),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "Sistema de monitoreo cafetero",
                              style: TextStyle(
                                color: Color(0xFFBCAAA4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final item = items[i];
                return _buildCard(item, i);
              }, childCount: items.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(_MenuItem item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOut,
      builder:
          (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8DDD5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: item.colorFondo,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(item.icono, color: item.colorIcono, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.titulo,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitulo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFBCAAA4),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color colorFondo;
  final Color colorIcono;
  final VoidCallback onTap;

  const _MenuItem({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.colorFondo,
    required this.colorIcono,
    required this.onTap,
  });
}
