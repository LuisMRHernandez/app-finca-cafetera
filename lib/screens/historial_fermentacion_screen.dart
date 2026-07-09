import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';

class HistorialFermentacionScreen extends StatefulWidget {
  final String token;
  const HistorialFermentacionScreen({super.key, required this.token});
  @override
  State<HistorialFermentacionScreen> createState() =>
      _HistorialFermentacionScreenState();
}

class _HistorialFermentacionScreenState
    extends State<HistorialFermentacionScreen> {
  List _todos = [];
  List _filtrado = [];
  bool _cargando = true;
  final _busCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final res = await ApiService.obtenerHistorial(widget.token);
    if (res['success']) {
      final data = List.from(res['data'])
        ..sort((a, b) {
          final fa = (a['fecha'] ?? a['fecha_registro'] ?? '').toString();
          final fb = (b['fecha'] ?? b['fecha_registro'] ?? '').toString();
          return fb.compareTo(fa);
        });
      setState(() {
        _todos = data;
        _filtrado = data;
      });
    }
    setState(() => _cargando = false);
  }

  void _filtrar(String q) {
    final t = q.toLowerCase();
    setState(
      () => _filtrado = _todos.where((item) {
        final fecha = (item['fecha'] ?? item['fecha_registro'] ?? '')
            .toString()
            .toLowerCase();
        final obs = (item['observacion'] ?? '').toString().toLowerCase();
        final notas = (item['notas_cata'] ?? '').toString().toLowerCase();
        return fecha.contains(t) || obs.contains(t) || notas.contains(t);
      }).toList(),
    );
  }

  String _fecha(dynamic raw) {
    final s = (raw ?? '').toString();
    if (s.length >= 16) {
      final p = s.substring(0, 10).split('-');
      return p.length == 3
          ? '${p[2]}/${p[1]}/${p[0]}  ${s.substring(11, 16)}'
          : s;
    }
    if (s.length >= 10) {
      final p = s.substring(0, 10).split('-');
      return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : s;
    }
    return s;
  }

  Color _colorPh(dynamic v) {
    final n = double.tryParse(v.toString()) ?? 0;
    if (n >= 3.5 && n <= 5.0) return AppColors.exito;
    return n < 3.5 ? AppColors.error : AppColors.advertencia;
  }

  Color _colorBrix(dynamic v) {
    final n = double.tryParse(v.toString()) ?? 0;
    return (n >= 14 && n <= 22)
        ? const Color(0xFF1565C0)
        : AppColors.advertencia;
  }

  Color _colorTemp(dynamic v) {
    final n = double.tryParse(v.toString()) ?? 0;
    if (n >= 18 && n <= 24) return AppColors.exito;
    return n > 24 ? AppColors.error : const Color(0xFF1565C0);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando)
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.verde)),
      );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargar,
          ),
        ],
      ),
      body: _todos.isEmpty
          ? const EstadoVacio(
              icono: Icons.history_rounded,
              titulo: 'Sin registros aún',
              subtitulo: 'Los registros de fermentación aparecerán aquí',
            )
          : Column(
              children: [
                // ── Resumen ───────────────────────────────────
                Container(
                  color: AppColors.verde,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      _StatBadge(
                        '${_todos.length}',
                        'Registros',
                        Icons.receipt_long_rounded,
                      ),
                      const SizedBox(width: 10),
                      _StatBadge(
                        _todos.isNotEmpty
                            ? _fecha(
                                _todos.first['fecha'] ??
                                    _todos.first['fecha_registro'],
                              )
                            : '—',
                        'Último',
                        Icons.calendar_today_rounded,
                      ),
                    ],
                  ),
                ),

                // ── Buscador ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: TextField(
                    controller: _busCtrl,
                    onChanged: _filtrar,
                    decoration: InputDecoration(
                      hintText: 'Buscar por fecha, observación o notas...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textoSuave,
                      ),
                      suffixIcon: _busCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textoSuave,
                              ),
                              onPressed: () {
                                _busCtrl.clear();
                                _filtrar('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                if (_busCtrl.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_filtrado.length} resultado(s)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textoSuave,
                        ),
                      ),
                    ),
                  ),

                // ── Lista ─────────────────────────────────────
                Expanded(
                  child: _filtrado.isEmpty
                      ? const Center(
                          child: Text(
                            'Sin resultados',
                            style: TextStyle(color: AppColors.textoSuave),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _filtrado.length,
                          itemBuilder: (_, i) => _Tarjeta(
                            item: _filtrado[i],
                            indice: i + 1,
                            fecha: _fecha,
                            colorPh: _colorPh,
                            colorBrix: _colorBrix,
                            colorTemp: _colorTemp,
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String valor, etiqueta;
  final IconData icono;
  const _StatBadge(this.valor, this.etiqueta, this.icono);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icono, size: 15, color: AppColors.doradoClaro),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valor,
                    style: const TextStyle(
                      color: AppColors.blanco,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    etiqueta,
                    style: TextStyle(
                      color: AppColors.blanco.withOpacity(0.6),
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

class _Tarjeta extends StatelessWidget {
  final dynamic item;
  final int indice;
  final String Function(dynamic) fecha;
  final Color Function(dynamic) colorPh, colorBrix, colorTemp;

  const _Tarjeta({
    required this.item,
    required this.indice,
    required this.fecha,
    required this.colorPh,
    required this.colorBrix,
    required this.colorTemp,
  });

  @override
  Widget build(BuildContext context) {
    final ph = item['ph']?.toString() ?? '—';
    final brix = item['brix']?.toString() ?? '—';
    final temp = item['temperatura']?.toString() ?? '—';
    final obs = (item['observacion'] ?? '').toString().trim();
    final notas = (item['notas_cata'] ?? '').toString().trim();
    final perfil = (item['perfil_tueste'] ?? '').toString().trim();
    final puntaje = item['puntaje_sensorial'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.fondoCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _detalle(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borde),
            ),
            child: Column(
              children: [
                // Encabezado
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.verde.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '$indice',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.verde,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: AppColors.textoSuave,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        fecha(item['fecha'] ?? item['fecha_registro']),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.texto,
                        ),
                      ),
                      const Spacer(),
                      if (puntaje != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.dorado.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 11,
                                color: AppColors.dorado,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$puntaje',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dorado,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.borde,
                      ),
                    ],
                  ),
                ),

                // Métricas
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                  child: Row(
                    children: [
                      _Mini(
                        Icons.water_drop_rounded,
                        'pH',
                        ph,
                        colorPh(item['ph']),
                      ),
                      const SizedBox(width: 8),
                      _Mini(
                        Icons.speed_rounded,
                        'Brix',
                        '$brix °Bx',
                        colorBrix(item['brix']),
                      ),
                      const SizedBox(width: 8),
                      _Mini(
                        Icons.thermostat_rounded,
                        'Temp',
                        '$temp °C',
                        colorTemp(item['temperatura']),
                      ),
                    ],
                  ),
                ),

                // Notas / observación
                if (obs.isNotEmpty || notas.isNotEmpty || perfil.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.crema,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notas.isNotEmpty)
                          _NotaLine(Icons.coffee_outlined, notas),
                        if (perfil.isNotEmpty)
                          _NotaLine(
                            Icons.local_fire_department_outlined,
                            perfil,
                          ),
                        if (obs.isNotEmpty) _NotaLine(Icons.notes_rounded, obs),
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

  void _detalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DetalleSheet(item: item, fecha: fecha),
    );
  }
}

class _Mini extends StatelessWidget {
  final IconData icono;
  final String label, valor;
  final Color color;
  const _Mini(this.icono, this.label, this.valor, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icono, size: 11, color: color),
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

class _NotaLine extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _NotaLine(this.icono, this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 13, color: AppColors.textoSuave),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textoSuave,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}

// ── Bottom sheet detalle ──────────────────────────────────────
class _DetalleSheet extends StatelessWidget {
  final dynamic item;
  final String Function(dynamic) fecha;
  const _DetalleSheet({required this.item, required this.fecha});

  @override
  Widget build(BuildContext context) {
    final obs = (item['observacion'] ?? '').toString();
    final notas = (item['notas_cata'] ?? '').toString();
    final perfil = (item['perfil_tueste'] ?? '').toString();
    final puntaje = item['puntaje_sensorial'];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.crema,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borde,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(
                Icons.science_rounded,
                color: AppColors.verde,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text(
                'Detalle del Registro',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.texto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              fecha(item['fecha'] ?? item['fecha_registro']),
              style: const TextStyle(fontSize: 13, color: AppColors.textoSuave),
            ),
          ),
          const SizedBox(height: 16),

          // Fermentación
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _DRow(
                  Icons.water_drop_rounded,
                  const Color(0xFFE3F2FD),
                  const Color(0xFF1565C0),
                  'pH',
                  '${item["ph"]} pH',
                  false,
                ),
                _DRow(
                  Icons.speed_rounded,
                  const Color(0xFFE8F5E0),
                  AppColors.verdeClaro,
                  'Grados Brix',
                  '${item["brix"]} °Bx',
                  false,
                ),
                _DRow(
                  Icons.thermostat_rounded,
                  const Color(0xFFFBE9E7),
                  const Color(0xFFBF360C),
                  'Temperatura',
                  '${item["temperatura"]} °C',
                  puntaje == null &&
                      perfil.isEmpty &&
                      notas.isEmpty &&
                      obs.isEmpty,
                ),
                if (puntaje != null)
                  _DRow(
                    Icons.star_rounded,
                    const Color(0xFFFFF8EC),
                    AppColors.dorado,
                    'Puntaje sensorial',
                    '$puntaje / 100',
                    perfil.isEmpty && notas.isEmpty && obs.isEmpty,
                  ),
                if (perfil.isNotEmpty)
                  _DRow(
                    Icons.local_fire_department_outlined,
                    const Color(0xFFFFF8EC),
                    AppColors.dorado,
                    'Perfil de tueste',
                    perfil,
                    notas.isEmpty && obs.isEmpty,
                  ),
                if (notas.isNotEmpty)
                  _DRow(
                    Icons.coffee_outlined,
                    const Color(0xFFE8F5E0),
                    AppColors.verdeClaro,
                    'Notas de cata',
                    notas,
                    obs.isEmpty,
                  ),
                if (obs.isNotEmpty)
                  _DRow(
                    Icons.notes_rounded,
                    const Color(0xFFF3E5F5),
                    const Color(0xFF6A1B9A),
                    'Observación',
                    obs,
                    true,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DRow extends StatelessWidget {
  final IconData icono;
  final Color fondo, color;
  final String label, valor;
  final bool isLast;
  const _DRow(
    this.icono,
    this.fondo,
    this.color,
    this.label,
    this.valor,
    this.isLast,
  );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: !isLast
              ? const Border(bottom: BorderSide(color: Color(0xFFEEE8E4)))
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icono, size: 15, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(fontSize: 14, color: AppColors.textoSuave),
              ),
            ),
            Flexible(
              child: Text(
                valor,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.texto,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}
