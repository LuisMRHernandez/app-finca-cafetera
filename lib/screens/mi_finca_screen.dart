import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MiFincaScreen extends StatefulWidget {
  final String token;

  const MiFincaScreen({super.key, required this.token});

  @override
  State<MiFincaScreen> createState() => _MiFincaScreenState();
}

class _MiFincaScreenState extends State<MiFincaScreen> {
  Map<String, dynamic>? finca;
  bool cargando = true;
  final String baseUrl = "http://192.168.1.5:8000";

  @override
  void initState() {
    super.initState();
    cargarFinca();
  }

  Future<void> cargarFinca() async {
    setState(() => cargando = true);
    final response = await ApiService.obtenerMiFinca(widget.token);
    setState(() {
      finca = response["success"] ? response["data"] : null;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body:
          cargando
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4E342E)),
              )
              : finca == null
              ? _EmptyState(onRetry: cargarFinca)
              : CustomScrollView(
                slivers: [
                  // ── AppBar con imagen de fondo ────────
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    backgroundColor: const Color(0xFF4E342E),
                    leading: const BackButton(),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        finca!["nombre_finca"] ?? "Mi Finca",
                        style: const TextStyle(
                          color: Color(0xFFEFEBE9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(blurRadius: 8, color: Colors.black45),
                          ],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          finca!["imagen_url"] != null
                              ? Image.network(
                                "$baseUrl/${finca!["imagen_url"]}",
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _ImagenPlaceholder(),
                              )
                              : _ImagenPlaceholder(),
                          // Gradiente para legibilidad del título
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black45],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Info principal ───────────
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE8DDD5),
                              ),
                            ),
                            child: Column(
                              children: [
                                _InfoRow(
                                  icono: Icons.location_on_rounded,
                                  colorIcono: const Color(0xFFBF360C),
                                  colorFondo: const Color(0xFFFBE9E7),
                                  label: "Municipio",
                                  valor: finca!["municipio"] ?? "-",
                                  isFirst: true,
                                ),
                                _InfoRow(
                                  icono: Icons.grass_rounded,
                                  colorIcono: const Color(0xFF2E7D32),
                                  colorFondo: const Color(0xFFE8F5E9),
                                  label: "Vereda",
                                  valor: finca!["vereda"] ?? "-",
                                ),
                                if (finca!["hectareas"] != null)
                                  _InfoRow(
                                    icono: Icons.straighten_rounded,
                                    colorIcono: const Color(0xFF1565C0),
                                    colorFondo: const Color(0xFFE3F2FD),
                                    label: "Extensión",
                                    valor: "${finca!["hectareas"]} hectáreas",
                                  ),
                                if (finca!["variedad"] != null)
                                  _InfoRow(
                                    icono: Icons.eco_rounded,
                                    colorIcono: const Color(0xFF6A1B9A),
                                    colorFondo: const Color(0xFFF3E5F5),
                                    label: "Variedad",
                                    valor: finca!["variedad"],
                                    isLast: true,
                                  )
                                else
                                  const SizedBox(height: 4),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Descripción ──────────────
                          if ((finca!["descripcion"] ?? "").isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE8DDD5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.description_rounded,
                                        size: 16,
                                        color: Color(0xFF8D6E63),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Descripción",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF5D4037),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    finca!["descripcion"],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF5D4037),
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          // ── Badge de finca activa ────
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFC8E6C9),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF2E7D32),
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Finca registrada y activa en el sistema de monitoreo",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color colorFondo;
  final String label;
  final String valor;
  final bool isFirst;
  final bool isLast;

  const _InfoRow({
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
          Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagenPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF5D4037),
      child: const Center(
        child: Icon(Icons.landscape_rounded, size: 64, color: Colors.white24),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.terrain_rounded, size: 64, color: Color(0xFF8D6E63)),
          const SizedBox(height: 16),
          const Text(
            "No hay finca registrada",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Contacta al administrador\npara registrar tu finca",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}
