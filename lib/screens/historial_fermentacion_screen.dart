import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistorialFermentacionScreen extends StatefulWidget {
  final String token;

  const HistorialFermentacionScreen({super.key, required this.token});

  @override
  State<HistorialFermentacionScreen> createState() =>
      _HistorialFermentacionScreenState();
}

class _HistorialFermentacionScreenState
    extends State<HistorialFermentacionScreen> {
  List historial = [];
  List historialFiltrado = [];
  bool cargando = true;
  String busqueda = "";
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> cargarHistorial() async {
    setState(() => cargando = true);
    final response = await ApiService.obtenerHistorialFermentacion(
      widget.token,
    );
    if (response["success"]) {
      final data = List.from(response["data"]);
      // Más reciente primero
      data.sort((a, b) {
        final fa = a["fecha_registro"] ?? a["fecha"] ?? "";
        final fb = b["fecha_registro"] ?? b["fecha"] ?? "";
        return fb.compareTo(fa);
      });
      setState(() {
        historial = data;
        historialFiltrado = data;
        cargando = false;
      });
    } else {
      setState(() => cargando = false);
    }
  }

  void _filtrar(String texto) {
    setState(() {
      busqueda = texto.toLowerCase();
      historialFiltrado =
          historial.where((item) {
            final fecha =
                (item["fecha_registro"] ?? item["fecha"] ?? "").toLowerCase();
            final obs = (item["observacion"] ?? "").toLowerCase();
            return fecha.contains(busqueda) || obs.contains(busqueda);
          }).toList();
    });
  }

  String _formatearFecha(dynamic raw) {
    if (raw == null) return "-";
    final s = raw.toString();
    if (s.length >= 10) {
      final partes = s.substring(0, 10).split("-");
      if (partes.length == 3) return "${partes[2]}/${partes[1]}/${partes[0]}";
    }
    return s;
  }

  Color _colorPh(dynamic val) {
    final v = double.tryParse(val.toString()) ?? 0;
    if (v >= 3.5 && v <= 5.0) return const Color(0xFF2E7D32);
    if (v < 3.5) return const Color(0xFFBF360C);
    return const Color(0xFFF57F17);
  }

  Color _colorBrix(dynamic val) {
    final v = double.tryParse(val.toString()) ?? 0;
    if (v >= 14 && v <= 22) return const Color(0xFF1565C0);
    return const Color(0xFFF57F17);
  }

  Color _colorTemp(dynamic val) {
    final v = double.tryParse(val.toString()) ?? 0;
    if (v >= 18 && v <= 24) return const Color(0xFF2E7D32);
    if (v > 24) return const Color(0xFFBF360C);
    return const Color(0xFF1565C0);
  }

  Widget _chip(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _verDetalle(dynamic item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DetalleSheet(item: item, formatFecha: _formatearFecha),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: const Text("Historial"),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: cargarHistorial,
            tooltip: "Actualizar",
          ),
        ],
      ),
      body:
          cargando
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4E342E)),
              )
              : historial.isEmpty
              ? _EmptyState()
              : Column(
                children: [
                  // ── Resumen rápido ─────────────────────
                  Container(
                    color: const Color(0xFF4E342E),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      children: [
                        _StatChip(
                          valor: "${historial.length}",
                          etiqueta: "Registros",
                          icono: Icons.receipt_long_rounded,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          valor:
                              historial.isNotEmpty
                                  ? _formatearFecha(
                                    historial.first["fecha_registro"] ??
                                        historial.first["fecha"],
                                  )
                                  : "-",
                          etiqueta: "Último",
                          icono: Icons.calendar_today_rounded,
                        ),
                      ],
                    ),
                  ),

                  // ── Buscador ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: TextField(
                      controller: _busquedaController,
                      onChanged: _filtrar,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3E2723),
                      ),
                      decoration: InputDecoration(
                        hintText: "Buscar por fecha u observación...",
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFBCAAA4),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF8D6E63),
                        ),
                        suffixIcon:
                            busqueda.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF8D6E63),
                                  ),
                                  onPressed: () {
                                    _busquedaController.clear();
                                    _filtrar("");
                                  },
                                )
                                : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8DDD5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8DDD5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4E342E),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  // ── Contador filtrado ──────────────────
                  if (busqueda.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${historialFiltrado.length} resultado(s)",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                      ),
                    ),

                  // ── Tabla ──────────────────────────────
                  Expanded(
                    child:
                        historialFiltrado.isEmpty
                            ? const Center(
                              child: Text(
                                "Sin resultados para esa búsqueda",
                                style: TextStyle(color: Color(0xFF8D6E63)),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: historialFiltrado.length,
                              itemBuilder: (context, i) {
                                final item = historialFiltrado[i];
                                return _FilaRegistro(
                                  item: item,
                                  indice: i + 1,
                                  formatFecha: _formatearFecha,
                                  colorPh: _colorPh,
                                  colorBrix: _colorBrix,
                                  colorTemp: _colorTemp,
                                  chip: _chip,
                                  onTap: () => _verDetalle(item),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}

// ── Fila de registro ───────────────────────────────────────────────────
class _FilaRegistro extends StatelessWidget {
  final dynamic item;
  final int indice;
  final String Function(dynamic) formatFecha;
  final Color Function(dynamic) colorPh;
  final Color Function(dynamic) colorBrix;
  final Color Function(dynamic) colorTemp;
  final Widget Function(String, Color) chip;
  final VoidCallback onTap;

  const _FilaRegistro({
    required this.item,
    required this.indice,
    required this.formatFecha,
    required this.colorPh,
    required this.colorBrix,
    required this.colorTemp,
    required this.chip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = formatFecha(item["fecha_registro"] ?? item["fecha"]);
    final ph = item["ph"]?.toString() ?? "-";
    final brix = item["brix"]?.toString() ?? "-";
    final temp = item["temperatura"]?.toString() ?? "-";
    final obs = (item["observacion"] ?? "").toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8DDD5)),
            ),
            child: Column(
              children: [
                // ── Encabezado fila ──────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F0EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "$indice",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Color(0xFF8D6E63),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        fecha,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFFBCAAA4),
                      ),
                    ],
                  ),
                ),

                // ── Métricas ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                  child: Row(
                    children: [
                      _MiniMetrica(
                        icono: Icons.water_drop_rounded,
                        label: "pH",
                        valor: ph,
                        color: colorPh(item["ph"]),
                      ),
                      const SizedBox(width: 8),
                      _MiniMetrica(
                        icono: Icons.speed_rounded,
                        label: "Brix",
                        valor: "$brix °Bx",
                        color: colorBrix(item["brix"]),
                      ),
                      const SizedBox(width: 8),
                      _MiniMetrica(
                        icono: Icons.thermostat_rounded,
                        label: "Temp",
                        valor: "$temp °C",
                        color: colorTemp(item["temperatura"]),
                      ),
                    ],
                  ),
                ),

                // ── Observación ───────────────────────────
                if (obs.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0EB),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notes_rounded,
                          size: 14,
                          color: Color(0xFF8D6E63),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            obs,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5D4037),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniMetrica extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final Color color;

  const _MiniMetrica({
    required this.icono,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              valor,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet de detalle completo ──────────────────────────────────
class _DetalleSheet extends StatelessWidget {
  final dynamic item;
  final String Function(dynamic) formatFecha;

  const _DetalleSheet({required this.item, required this.formatFecha});

  @override
  Widget build(BuildContext context) {
    final fecha = formatFecha(item["fecha_registro"] ?? item["fecha"]);
    final obs = (item["observacion"] ?? "Sin observaciones").toString().trim();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD7CCC8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(
                Icons.science_rounded,
                color: Color(0xFF4E342E),
                size: 22,
              ),
              const SizedBox(width: 10),
              const Text(
                "Detalle del Registro",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            fecha,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
          ),

          const SizedBox(height: 20),

          // Tabla de valores
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8DDD5)),
            ),
            child: Column(
              children: [
                _DetalleRow(
                  icono: Icons.water_drop_rounded,
                  color: const Color(0xFF1565C0),
                  label: "pH",
                  valor: "${item["ph"]} pH",
                  isFirst: true,
                ),
                _DetalleRow(
                  icono: Icons.speed_rounded,
                  color: const Color(0xFF2E7D32),
                  label: "Grados Brix",
                  valor: "${item["brix"]} °Bx",
                ),
                _DetalleRow(
                  icono: Icons.thermostat_rounded,
                  color: const Color(0xFFBF360C),
                  label: "Temperatura",
                  valor: "${item["temperatura"]} °C",
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Observaciones
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8DDD5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 15,
                      color: Color(0xFF8D6E63),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Observaciones",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  obs.isEmpty ? "Sin observaciones" : obs,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        obs.isEmpty
                            ? const Color(0xFFBCAAA4)
                            : const Color(0xFF3E2723),
                    fontStyle:
                        obs.isEmpty ? FontStyle.italic : FontStyle.normal,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetalleRow extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String label;
  final String valor;
  final bool isFirst;
  final bool isLast;

  const _DetalleRow({
    required this.icono,
    required this.color,
    required this.label,
    required this.valor,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border:
            !isLast
                ? const Border(bottom: BorderSide(color: Color(0xFFEEE8E4)))
                : null,
        borderRadius:
            isFirst
                ? const BorderRadius.vertical(top: Radius.circular(14))
                : isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(14))
                : BorderRadius.zero,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icono, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF5D4037)),
          ),
          const Spacer(),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final IconData icono;

  const _StatChip({
    required this.valor,
    required this.etiqueta,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icono, size: 16, color: const Color(0xFFBCAAA4)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    color: Color(0xFFEFEBE9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  etiqueta,
                  style: const TextStyle(
                    color: Color(0xFFBCAAA4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE0D4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 48,
              color: Color(0xFF8D6E63),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Sin registros aún",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Los registros de fermentación\naparecerán aquí",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
          ),
        ],
      ),
    );
  }
}
