import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/api_service.dart';

class GraficaFermentacionScreen extends StatefulWidget {
  final String token;

  const GraficaFermentacionScreen({super.key, required this.token});

  @override
  State<GraficaFermentacionScreen> createState() =>
      _GraficaFermentacionScreenState();
}

class _GraficaFermentacionScreenState extends State<GraficaFermentacionScreen> {
  List datos = [];
  bool cargando = true;
  int _tabSeleccionada = 0;

  late TooltipBehavior _tooltip;

  static const _tabs = [
    _TabInfo(
      label: "pH",
      campo: "ph",
      icono: Icons.water_drop_rounded,
      color: Color(0xFF1565C0),
      colorFondo: Color(0xFFE3F2FD),
      unidad: "pH",
    ),
    _TabInfo(
      label: "Brix",
      campo: "brix",
      icono: Icons.speed_rounded,
      color: Color(0xFF2E7D32),
      colorFondo: Color(0xFFE8F5E9),
      unidad: "°Bx",
    ),
    _TabInfo(
      label: "Temp",
      campo: "temperatura",
      icono: Icons.thermostat_rounded,
      color: Color(0xFFBF360C),
      colorFondo: Color(0xFFFBE9E7),
      unidad: "°C",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(
      enable: true,
      header: '',
      canShowMarker: true,
      color: const Color(0xFF3E2723),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
    );
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() => cargando = true);
    final fincaResponse = await ApiService.obtenerMiFinca(widget.token);
    if (!fincaResponse["success"]) {
      setState(() => cargando = false);
      return;
    }
    final fincaId = fincaResponse["data"]["id"];
    final response = await ApiService.obtenerDatosGrafica(
      widget.token,
      fincaId,
    );
    setState(() {
      datos = response["success"] ? List.from(response["data"]) : [];
      cargando = false;
    });
  }

  // "2026-05-22 23:23" → "22 23:23"  (único por registro, evita agrupación)
  String _formatFechaEje(dynamic raw) {
    final s = (raw ?? "").toString();
    if (s.length >= 16) {
      final dia = s.substring(8, 10);
      final hora = s.substring(11, 16);
      return "$dia $hora";
    }
    if (s.length >= 10) return s.substring(5, 10);
    return s;
  }

  // Fecha completa para la tabla: "2026-05-22 23:23"
  String _formatFechaTabla(dynamic raw) {
    final s = (raw ?? "").toString();
    if (s.length >= 16) return s.substring(0, 16);
    if (s.length >= 10) return s.substring(0, 10);
    return s;
  }

  double _minValor(String campo) {
    if (datos.isEmpty) return 0;
    final vals =
        datos.map((d) => double.tryParse(d[campo].toString()) ?? 0).toList();
    final min = vals.reduce((a, b) => a < b ? a : b);
    final max = vals.reduce((a, b) => a > b ? a : b);
    final rango = max - min;
    final padding = rango > 0 ? rango * 0.25 : min * 0.20;
    return (min - padding).floorToDouble().clamp(0.0, double.infinity);
  }

  double _maxValor(String campo) {
    if (datos.isEmpty) return 10;
    final vals =
        datos.map((d) => double.tryParse(d[campo].toString()) ?? 0).toList();
    final max = vals.reduce((a, b) => a > b ? a : b);
    final min = vals.reduce((a, b) => a < b ? a : b);
    final rango = max - min;
    final padding = rango > 0 ? rango * 0.25 : max * 0.20;
    return (max + padding).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_tabSeleccionada];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: const Text("Gráficas"),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: cargarDatos,
            tooltip: "Actualizar",
          ),
        ],
      ),
      body:
          cargando
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4E342E)),
              )
              : datos.isEmpty
              ? const _EmptyState()
              : Column(
                children: [
                  // ── Selector pH / Brix / Temp ──────────────────────
                  Container(
                    color: const Color(0xFF4E342E),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: List.generate(_tabs.length, (i) {
                        final t = _tabs[i];
                        final selected = i == _tabSeleccionada;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tabSeleccionada = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    selected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    t.icono,
                                    size: 16,
                                    color:
                                        selected
                                            ? t.color
                                            : const Color(0xFFBCAAA4),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    t.label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          selected
                                              ? t.color
                                              : const Color(0xFFBCAAA4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Contenido scrollable ───────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // ── Tarjetas de estadísticas ───────────────
                          _ResumenVariable(datos: datos, tab: tab),

                          const SizedBox(height: 16),

                          // ── Gráfica ────────────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE8DDD5),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título de la gráfica
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    bottom: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: tab.colorFondo,
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                        ),
                                        child: Icon(
                                          tab.icono,
                                          color: tab.color,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "${tab.label} en el tiempo",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF3E2723),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Gráfica Syncfusion
                                SizedBox(
                                  height: 260,
                                  child: SfCartesianChart(
                                    tooltipBehavior: _tooltip,
                                    plotAreaBorderWidth: 0,
                                    zoomPanBehavior: ZoomPanBehavior(
                                      enablePinching: true,
                                      enablePanning: true,
                                      zoomMode: ZoomMode.x,
                                    ),
                                    primaryXAxis: CategoryAxis(
                                      labelStyle: const TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF8D6E63),
                                      ),
                                      majorGridLines: const MajorGridLines(
                                        width: 0,
                                      ),
                                      majorTickLines: const MajorTickLines(
                                        size: 0,
                                      ),
                                      axisLine: const AxisLine(width: 0),
                                      labelIntersectAction:
                                          AxisLabelIntersectAction.rotate45,
                                    ),
                                    primaryYAxis: NumericAxis(
                                      minimum: _minValor(tab.campo),
                                      maximum: _maxValor(tab.campo),
                                      labelStyle: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF8D6E63),
                                      ),
                                      majorGridLines: MajorGridLines(
                                        dashArray: const [4, 4],
                                        color: Colors.grey.shade200,
                                      ),
                                      majorTickLines: const MajorTickLines(
                                        size: 0,
                                      ),
                                      axisLine: const AxisLine(width: 0),
                                    ),
                                    series: <CartesianSeries>[
                                      // Área con gradiente (fondo)
                                      SplineAreaSeries<dynamic, String>(
                                        dataSource: datos,
                                        xValueMapper:
                                            (d, _) =>
                                                _formatFechaEje(d["fecha"]),
                                        yValueMapper:
                                            (d, _) => double.tryParse(
                                              d[tab.campo].toString(),
                                            ),
                                        gradient: LinearGradient(
                                          colors: [
                                            tab.color.withValues(alpha: 0.20),
                                            tab.color.withValues(alpha: 0.02),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderColor: Colors.transparent,
                                        borderWidth: 0,
                                        animationDuration: 900,
                                        splineType: SplineType.monotonic,
                                      ),
                                      // Línea + marcadores (encima)
                                      SplineSeries<dynamic, String>(
                                        dataSource: datos,
                                        xValueMapper:
                                            (d, _) =>
                                                _formatFechaEje(d["fecha"]),
                                        yValueMapper:
                                            (d, _) => double.tryParse(
                                              d[tab.campo].toString(),
                                            ),
                                        color: tab.color,
                                        width: 2.5,
                                        splineType: SplineType.monotonic,
                                        markerSettings: MarkerSettings(
                                          isVisible: true,
                                          color: Colors.white,
                                          borderColor: tab.color,
                                          borderWidth: 2,
                                          height: 8,
                                          width: 8,
                                          shape: DataMarkerType.circle,
                                        ),
                                        animationDuration: 900,
                                      ),
                                    ],
                                  ),
                                ),

                                // Hint zoom
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, bottom: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.pinch_rounded,
                                        size: 13,
                                        color: Color(0xFFBCAAA4),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Pellizca para zoom · Arrastra para explorar",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFBCAAA4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Tabla de datos registrados ─────────────
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
                                // Título tabla
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    12,
                                    14,
                                    8,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.table_rows_rounded,
                                        size: 16,
                                        color: Color(0xFF8D6E63),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Datos registrados",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF5D4037),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: tab.colorFondo,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          "${datos.length} registros",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: tab.color,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFEEE8E4),
                                ),

                                // Encabezados columnas
                                Container(
                                  color: const Color(0xFFFAF8F5),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        flex: 3,
                                        child: Text(
                                          "Fecha y hora",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF8D6E63),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "${tab.label} (${tab.unidad})",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF8D6E63),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFEEE8E4),
                                ),

                                // Filas de datos
                                ...List.generate(datos.length, (i) {
                                  final d = datos[i];
                                  final fechaMostrar = _formatFechaTabla(
                                    d["fecha"],
                                  );
                                  final val = d[tab.campo];
                                  final isLast = i == datos.length - 1;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color:
                                          i % 2 == 0
                                              ? Colors.transparent
                                              : const Color(0xFFFAF8F5),
                                      border:
                                          !isLast
                                              ? const Border(
                                                bottom: BorderSide(
                                                  color: Color(0xFFEEE8E4),
                                                ),
                                              )
                                              : null,
                                      borderRadius:
                                          isLast
                                              ? const BorderRadius.vertical(
                                                bottom: Radius.circular(16),
                                              )
                                              : null,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 11,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            fechaMostrar,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF5D4037),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: tab.color.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "$val",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: tab.color,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

// ── Resumen estadístico (Promedio / Mínimo / Máximo) ───────────────────
class _ResumenVariable extends StatelessWidget {
  final List datos;
  final _TabInfo tab;

  const _ResumenVariable({required this.datos, required this.tab});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const SizedBox.shrink();
    final vals =
        datos
            .map((d) => double.tryParse(d[tab.campo].toString()) ?? 0.0)
            .toList();
    final promedio = vals.reduce((a, b) => a + b) / vals.length;
    final minVal = vals.reduce((a, b) => a < b ? a : b);
    final maxVal = vals.reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        _StatCard(
          label: "Promedio",
          valor: promedio.toStringAsFixed(1),
          unidad: tab.unidad,
          color: tab.color,
          colorFondo: tab.colorFondo,
          icono: Icons.analytics_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: "Mínimo",
          valor: minVal.toStringAsFixed(1),
          unidad: tab.unidad,
          color: const Color(0xFF1565C0),
          colorFondo: const Color(0xFFE3F2FD),
          icono: Icons.arrow_downward_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: "Máximo",
          valor: maxVal.toStringAsFixed(1),
          unidad: tab.unidad,
          color: const Color(0xFFBF360C),
          colorFondo: const Color(0xFFFBE9E7),
          icono: Icons.arrow_upward_rounded,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String valor;
  final String unidad;
  final Color color;
  final Color colorFondo;
  final IconData icono;

  const _StatCard({
    required this.label,
    required this.valor,
    required this.unidad,
    required this.color,
    required this.colorFondo,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8DDD5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 16, color: color),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              unidad,
              style: const TextStyle(fontSize: 10, color: Color(0xFFA1887F)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Clases de datos ────────────────────────────────────────────────────
class _TabInfo {
  final String label;
  final String campo;
  final IconData icono;
  final Color color;
  final Color colorFondo;
  final String unidad;

  const _TabInfo({
    required this.label,
    required this.campo,
    required this.icono,
    required this.color,
    required this.colorFondo,
    required this.unidad,
  });
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFEDE0D4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: Color(0xFF8D6E63),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Sin datos para graficar",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Registra datos de fermentación\npara ver las gráficas",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
          ),
        ],
      ),
    );
  }
}
