import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';

class GraficaSecadoScreen extends StatefulWidget {
  final String token;
  const GraficaSecadoScreen({super.key, required this.token});
  @override
  State<GraficaSecadoScreen> createState() => _GraficaSecadoScreenState();
}

class _GraficaSecadoScreenState extends State<GraficaSecadoScreen> {
  List _datos = [];
  bool _cargando = true;
  int _tabActiva = 0;
  late TooltipBehavior _tooltip;

  // Los dos campos que grafica secado
  static const _tabs = [
    _Tab('Humedad', 'humedad', Icons.water_drop_rounded, Color(0xFF1565C0),
        Color(0xFFE3F2FD), '%'),
    _Tab('Rendimiento', 'factor_rendimiento', Icons.speed_rounded,
        AppColors.verdeClaro, Color(0xFFE8F5E0), ''),
  ];

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: true,
        color: AppColors.verde,
        textStyle: const TextStyle(color: AppColors.blanco, fontSize: 12));
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final fRes = await ApiService.obtenerMiFinca(widget.token);
    if (!fRes['success']) {
      setState(() => _cargando = false);
      return;
    }
    final fincaId = fRes['data']['id'] as int;

    final res = await ApiService.obtenerGraficaSecado(widget.token, fincaId);
    if (res['success']) {
      final lista = List<Map<String, dynamic>>.from(res['data'] as List);
      lista.sort((a, b) => (a['fecha'] ?? '')
          .toString()
          .compareTo((b['fecha'] ?? '').toString()));
      setState(() {
        _datos = lista;
        _cargando = false;
      });
    } else {
      setState(() {
        _datos = [];
        _cargando = false;
      });
    }
  }

  String _fechaEje(dynamic raw) {
    final s = (raw ?? '').toString().trim();
    if (s.length >= 16) return '${s.substring(8, 10)}\n${s.substring(11, 16)}';
    if (s.length >= 10) return s.substring(5, 10);
    return s;
  }

  String _fechaTabla(dynamic raw) {
    final s = (raw ?? '').toString().trim();
    if (s.length >= 16) {
      return '${s.substring(8, 10)}/${s.substring(5, 7)} ${s.substring(11, 16)}';
    }
    return s;
  }

  double _min(String campo) {
    if (_datos.isEmpty) return 0;
    final vals = _datos
        .map((d) => double.tryParse((d[campo] ?? 0).toString()) ?? 0.0)
        .where((v) => v > 0)
        .toList();
    if (vals.isEmpty) return 0;
    final mn = vals.reduce((a, b) => a < b ? a : b);
    final mx = vals.reduce((a, b) => a > b ? a : b);
    final pad = (mx - mn) > 0 ? (mx - mn) * 0.25 : mn * 0.20;
    return (mn - pad).floorToDouble().clamp(0.0, double.infinity);
  }

  double _max(String campo) {
    if (_datos.isEmpty) return 10;
    final vals = _datos
        .map((d) => double.tryParse((d[campo] ?? 0).toString()) ?? 0.0)
        .toList();
    if (vals.isEmpty) return 10;
    final mx = vals.reduce((a, b) => a > b ? a : b);
    final mn = vals.reduce((a, b) => a < b ? a : b);
    final pad = (mx - mn) > 0 ? (mx - mn) * 0.25 : mx * 0.20;
    return (mx + pad).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando)
      return const Scaffold(
          body:
              Center(child: CircularProgressIndicator(color: AppColors.verde)));

    final tab = _tabs[_tabActiva];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficas de Secado'),
        leading: const BackButton(),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded), onPressed: _cargar),
        ],
      ),
      body: _datos.isEmpty
          ? const EstadoVacio(
              icono: Icons.bar_chart_rounded,
              titulo: 'Sin datos de secado',
              subtitulo: 'Registra datos de secado\npara ver las gráficas')
          : Column(children: [
              // ── Selector tabs ─────────────────────────────
              Container(
                color: AppColors.verde,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final t = _tabs[i];
                    final sel = i == _tabActiva;
                    return Expanded(
                        child: GestureDetector(
                      onTap: () => setState(() => _tabActiva = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 10),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: sel
                                ? AppColors.blanco
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(t.icono,
                                  size: 15,
                                  color: sel ? t.color : AppColors.doradoClaro),
                              const SizedBox(width: 6),
                              Text(t.label,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: sel
                                          ? t.color
                                          : AppColors.doradoClaro)),
                            ]),
                      ),
                    ));
                  }),
                ),
              ),

              // ── Contenido ─────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    // Estadísticas
                    _Estadisticas(datos: _datos, tab: tab),
                    const SizedBox(height: 16),

                    // Gráfica
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                    color: tab.colorFondo,
                                    borderRadius: BorderRadius.circular(9)),
                                child: Icon(tab.icono,
                                    color: tab.color, size: 15)),
                            const SizedBox(width: 10),
                            Text('${tab.label} en el tiempo',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.texto)),
                          ]),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 250,
                            child: SfCartesianChart(
                              tooltipBehavior: _tooltip,
                              plotAreaBorderWidth: 0,
                              zoomPanBehavior: ZoomPanBehavior(
                                  enablePinching: true,
                                  enablePanning: true,
                                  zoomMode: ZoomMode.x),
                              primaryXAxis: CategoryAxis(
                                  labelStyle: const TextStyle(
                                      fontSize: 9, color: AppColors.textoSuave),
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  majorTickLines: const MajorTickLines(size: 0),
                                  axisLine: const AxisLine(width: 0),
                                  labelIntersectAction:
                                      AxisLabelIntersectAction.rotate45),
                              primaryYAxis: NumericAxis(
                                  minimum: _min(tab.campo),
                                  maximum: _max(tab.campo),
                                  labelStyle: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textoSuave),
                                  majorGridLines: MajorGridLines(
                                      dashArray: const [4, 4],
                                      color: AppColors.borde),
                                  majorTickLines: const MajorTickLines(size: 0),
                                  axisLine: const AxisLine(width: 0)),
                              series: <CartesianSeries>[
                                SplineAreaSeries<dynamic, String>(
                                    dataSource: _datos,
                                    xValueMapper: (d, _) =>
                                        _fechaEje(d['fecha']),
                                    yValueMapper: (d, _) => double.tryParse(
                                        (d[tab.campo] ?? 0).toString()),
                                    gradient: LinearGradient(
                                        colors: [
                                          tab.color.withOpacity(0.18),
                                          tab.color.withOpacity(0.02),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter),
                                    borderColor: Colors.transparent,
                                    borderWidth: 0,
                                    animationDuration: 900,
                                    splineType: SplineType.monotonic),
                                SplineSeries<dynamic, String>(
                                    dataSource: _datos,
                                    xValueMapper: (d, _) =>
                                        _fechaEje(d['fecha']),
                                    yValueMapper: (d, _) => double.tryParse(
                                        (d[tab.campo] ?? 0).toString()),
                                    color: tab.color,
                                    width: 2.5,
                                    splineType: SplineType.monotonic,
                                    markerSettings: MarkerSettings(
                                        isVisible: true,
                                        color: AppColors.blanco,
                                        borderColor: tab.color,
                                        borderWidth: 2,
                                        height: 8,
                                        width: 8,
                                        shape: DataMarkerType.circle),
                                    animationDuration: 900),
                              ],
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.pinch_rounded,
                                        size: 12, color: AppColors.textoSuave),
                                    SizedBox(width: 5),
                                    Text(
                                        'Pellizca para zoom · Arrastra para explorar',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textoSuave)),
                                  ])),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tabla de datos
                    AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                              child: Row(children: [
                                const Icon(Icons.table_rows_rounded,
                                    size: 15, color: AppColors.textoSuave),
                                const SizedBox(width: 8),
                                const Text('Datos registrados',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.texto)),
                                const Spacer(),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: tab.colorFondo,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text('${_datos.length} registros',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: tab.color,
                                            fontWeight: FontWeight.w500))),
                              ])),
                          const Divider(height: 1, color: AppColors.borde),
                          Container(
                              color: AppColors.crema,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Row(children: [
                                const Expanded(
                                    flex: 3,
                                    child: Text('Fecha y hora',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textoSuave))),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        tab.unidad.isNotEmpty
                                            ? '${tab.label} (${tab.unidad})'
                                            : tab.label,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textoSuave))),
                              ])),
                          const Divider(height: 1, color: AppColors.borde),
                          ...List.generate(_datos.length, (i) {
                            final d = _datos[i];
                            final val = d[tab.campo];
                            final isLast = i == _datos.length - 1;
                            return Container(
                              decoration: BoxDecoration(
                                  color: i % 2 == 0
                                      ? Colors.transparent
                                      : AppColors.crema,
                                  border: !isLast
                                      ? const Border(
                                          bottom: BorderSide(
                                              color: AppColors.borde))
                                      : null,
                                  borderRadius: isLast
                                      ? const BorderRadius.vertical(
                                          bottom: Radius.circular(16))
                                      : null),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 11),
                              child: Row(children: [
                                Expanded(
                                    flex: 3,
                                    child: Text(_fechaTabla(d['fecha']),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textoSuave))),
                                Expanded(
                                    flex: 2,
                                    child: Center(
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                                color:
                                                    tab.color.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Text(
                                                tab.unidad.isNotEmpty
                                                    ? '$val ${tab.unidad}'
                                                    : '$val',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: tab.color))))),
                              ]),
                            );
                          }),
                        ])),

                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ]),
    );
  }
}

// ── Estadísticas ──────────────────────────────────────────────
class _Estadisticas extends StatelessWidget {
  final List datos;
  final _Tab tab;
  const _Estadisticas({required this.datos, required this.tab});

  @override
  Widget build(BuildContext context) {
    final vals = datos
        .map((d) => double.tryParse((d[tab.campo] ?? 0).toString()) ?? 0.0)
        .toList();
    final prom = vals.reduce((a, b) => a + b) / vals.length;
    final mn = vals.reduce((a, b) => a < b ? a : b);
    final mx = vals.reduce((a, b) => a > b ? a : b);

    return Row(children: [
      _StatCard('Promedio', prom.toStringAsFixed(1), tab.unidad, tab.color,
          tab.colorFondo, Icons.analytics_rounded),
      const SizedBox(width: 10),
      _StatCard(
          'Mínimo',
          mn.toStringAsFixed(1),
          tab.unidad,
          const Color(0xFF1565C0),
          const Color(0xFFE3F2FD),
          Icons.arrow_downward_rounded),
      const SizedBox(width: 10),
      _StatCard(
          'Máximo',
          mx.toStringAsFixed(1),
          tab.unidad,
          const Color(0xFFBF360C),
          const Color(0xFFFBE9E7),
          Icons.arrow_upward_rounded),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, valor, unidad;
  final Color color, colorFondo;
  final IconData icono;
  const _StatCard(this.label, this.valor, this.unidad, this.color,
      this.colorFondo, this.icono);

  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icono, size: 15, color: color),
            const SizedBox(height: 6),
            Text(valor,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            Text(unidad.isNotEmpty ? unidad : ' ',
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textoSuave)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textoSuave)),
          ]),
        ),
      );
}

class _Tab {
  final String label, campo, unidad;
  final IconData icono;
  final Color color, colorFondo;
  const _Tab(this.label, this.campo, this.icono, this.color, this.colorFondo,
      this.unidad);
}
