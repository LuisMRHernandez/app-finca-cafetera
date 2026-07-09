import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';

class SecadoScreen extends StatefulWidget {
  final String token;
  const SecadoScreen({super.key, required this.token});
  @override
  State<SecadoScreen> createState() => _SecadoScreenState();
}

class _SecadoScreenState extends State<SecadoScreen> {
  final _humedadCtrl = TextEditingController();
  final _rendCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  int? _fincaId;
  bool _guardando = false;

  // Rangos normales para café
  static const double humMin = 10.0, humMax = 12.5;
  static const double rendMin = 0.0, rendMax = 100.0;

  @override
  void initState() {
    super.initState();
    _cargarFinca();
  }

  @override
  void dispose() {
    _humedadCtrl.dispose();
    _rendCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarFinca() async {
    final res = await ApiService.obtenerMiFinca(widget.token);
    if (res['success']) setState(() => _fincaId = res['data']['id']);
  }

  String? _validarRango(String campo, double v) {
    if (campo == 'hum' && (v < humMin || v > humMax))
      return 'Humedad óptima del café: $humMin – $humMax %\nIngresaste: $v %';
    if (campo == 'rend' && (v < rendMin || v > rendMax))
      return 'Factor de rendimiento: $rendMin – $rendMax\nIngresaste: $v';
    return null;
  }

  Future<bool> _advertencia(String msg) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Row(children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.advertencia, size: 22),
              SizedBox(width: 10),
              Text('Valor fuera de rango',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(msg,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textoSuave, height: 1.5)),
              const SizedBox(height: 12),
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFE082))),
                  child: const Text('¿Deseas guardar de todas formas?',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textoSuave))),
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Corregir')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.advertencia),
                  child: const Text('Guardar igual')),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _confirmar(double hum, double rend) async {
    return await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => Container(
            decoration: const BoxDecoration(
                color: AppColors.crema,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.borde,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Row(children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.verde, size: 22),
                SizedBox(width: 10),
                Text('Confirmar registro',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.texto)),
              ]),
              const SizedBox(height: 4),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('¿Los valores son correctos?',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textoSuave))),
              const SizedBox(height: 16),
              AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    _CRow(
                        Icons.water_drop_rounded,
                        const Color(0xFFE3F2FD),
                        const Color(0xFF1565C0),
                        'Humedad',
                        '$hum %',
                        hum >= humMin && hum <= humMax,
                        false),
                    _CRow(
                        Icons.speed_rounded,
                        const Color(0xFFE8F5E0),
                        AppColors.verdeClaro,
                        'Factor rendimiento',
                        '$rend',
                        rend >= rendMin && rend <= rendMax,
                        _obsCtrl.text.trim().isEmpty),
                    if (_obsCtrl.text.trim().isNotEmpty)
                      _CRow(
                          Icons.notes_rounded,
                          const Color(0xFFF3E5F5),
                          const Color(0xFF6A1B9A),
                          'Observación',
                          _obsCtrl.text.trim(),
                          true,
                          true),
                  ])),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Editar'))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Confirmar'))),
              ]),
            ]),
          ),
        ) ??
        false;
  }

  Future<void> _guardar() async {
    if (_humedadCtrl.text.isEmpty || _rendCtrl.text.isEmpty) {
      _snack('Completa Humedad y Factor de rendimiento');
      return;
    }
    final hum = double.tryParse(_humedadCtrl.text);
    final rend = double.tryParse(_rendCtrl.text);
    if (hum == null || rend == null) {
      _snack('Ingresa valores numéricos válidos');
      return;
    }
    if (_fincaId == null) {
      _snack('No se encontró la finca');
      return;
    }

    final msgHum = _validarRango('hum', hum);
    if (msgHum != null && !await _advertencia(msgHum)) return;
    final msgRend = _validarRango('rend', rend);
    if (msgRend != null && !await _advertencia(msgRend)) return;

    if (!await _confirmar(hum, rend)) return;

    setState(() => _guardando = true);
    final res = await ApiService.guardarSecado(
      token: widget.token,
      fincaId: _fincaId!,
      humedad: hum,
      factorRendimiento: rend,
      observacion: _obsCtrl.text.trim(),
    );
    setState(() => _guardando = false);

    if (res['success']) {
      _snack('✓ Registro de secado guardado');
      _humedadCtrl.clear();
      _rendCtrl.clear();
      _obsCtrl.clear();
    } else {
      _snack(res['message']?.toString() ?? 'Error al guardar');
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Registro de Secado'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Banner ───────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.wb_sunny_rounded,
                      color: Colors.white, size: 26)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Datos de Secado',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text('Humedad · Factor de rendimiento',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12)),
                  ])),
            ]),
          ),

          const SizedBox(height: 14),

          // ── Nota informativa ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF1565C0).withOpacity(0.15))),
            child: const Row(children: [
              Icon(Icons.repeat_rounded, size: 16, color: Color(0xFF1565C0)),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'Este registro se puede llenar varias veces durante el proceso de secado.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textoSuave,
                          height: 1.5))),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Rangos de referencia ─────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBDEFB))),
            child: Column(children: [
              const Row(children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: Color(0xFF1565C0)),
                SizedBox(width: 6),
                Text('Rangos óptimos para café',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1565C0))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _RangoChip(
                    'Humedad', '$humMin – $humMax %', const Color(0xFF1565C0)),
                const SizedBox(width: 8),
                _RangoChip('Rendimiento', '$rendMin – $rendMax',
                    const Color(0xFF1565C0)),
              ]),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Campos ───────────────────────────────────────
          const SeccionTitulo(
              icono: Icons.water_drop_outlined, titulo: 'Parámetros de secado'),
          const SizedBox(height: 14),

          Row(children: [
            Expanded(
                child: _CampoMetrica(
                    ctrl: _humedadCtrl,
                    label: 'Humedad',
                    unidad: '%',
                    icono: Icons.water_drop_rounded,
                    colorIcono: const Color(0xFF1565C0),
                    colorFondo: const Color(0xFFE3F2FD),
                    min: humMin,
                    max: humMax)),
            const SizedBox(width: 12),
            Expanded(
                child: _CampoMetrica(
                    ctrl: _rendCtrl,
                    label: 'Factor rendimiento',
                    unidad: '',
                    icono: Icons.speed_rounded,
                    colorIcono: AppColors.verdeClaro,
                    colorFondo: const Color(0xFFE8F5E0),
                    min: rendMin,
                    max: rendMax)),
          ]),

          const SizedBox(height: 24),

          // ── Observación ──────────────────────────────────
          const SeccionTitulo(
              icono: Icons.notes_outlined, titulo: 'Observación'),
          const SizedBox(height: 12),
          TextField(
              controller: _obsCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Condiciones del día, método de secado...',
                  prefixIcon: Icon(Icons.edit_note_rounded,
                      color: AppColors.textoSuave))),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.blanco))
                  : const Icon(Icons.save_rounded, size: 20),
              label: Text(_guardando ? 'Guardando...' : 'Guardar Registro'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0)),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ── Campo métrica con indicador de rango ──────────────────────
class _CampoMetrica extends StatefulWidget {
  final TextEditingController ctrl;
  final String label, unidad;
  final IconData icono;
  final Color colorIcono, colorFondo;
  final double min, max;
  const _CampoMetrica(
      {required this.ctrl,
      required this.label,
      required this.unidad,
      required this.icono,
      required this.colorIcono,
      required this.colorFondo,
      required this.min,
      required this.max});
  @override
  State<_CampoMetrica> createState() => _CampoMetricaState();
}

class _CampoMetricaState extends State<_CampoMetrica> {
  bool _fuera = false;
  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(_check);
  }

  void _check() {
    final v = double.tryParse(widget.ctrl.text);
    setState(() => _fuera = v != null && (v < widget.min || v > widget.max));
  }

  @override
  void dispose() {
    widget.ctrl.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
            color: AppColors.blanco,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _fuera ? AppColors.advertencia : AppColors.borde,
                width: _fuera ? 1.5 : 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: _fuera ? const Color(0xFFFFF8E1) : widget.colorFondo,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(widget.icono,
                    size: 15,
                    color: _fuera ? AppColors.advertencia : widget.colorIcono)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(widget.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _fuera
                            ? AppColors.advertencia
                            : AppColors.textoSuave))),
            if (_fuera)
              const Icon(Icons.warning_amber_rounded,
                  size: 13, color: AppColors.advertencia),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
                child: TextField(
              controller: widget.ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
              ],
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _fuera ? AppColors.advertencia : AppColors.texto),
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: _fuera
                              ? AppColors.advertencia
                              : AppColors.borde)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: _fuera
                              ? AppColors.advertencia
                              : const Color(0xFF1565C0),
                          width: 1.5)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: _fuera
                              ? AppColors.advertencia
                              : AppColors.borde)),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  filled: false),
            )),
            if (widget.unidad.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(' ${widget.unidad}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textoSuave))),
          ]),
          if (_fuera) ...[
            const SizedBox(height: 5),
            Text('Rango: ${widget.min} – ${widget.max}',
                style: const TextStyle(
                    fontSize: 10, color: AppColors.advertencia)),
          ],
        ]),
      );
}

class _RangoChip extends StatelessWidget {
  final String label, rango;
  final Color color;
  const _RangoChip(this.label, this.rango, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(rango,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textoSuave)),
          ]),
        ),
      );
}

class _CRow extends StatelessWidget {
  final IconData icono;
  final Color fondo, color;
  final String label, valor;
  final bool enRango, isLast;
  const _CRow(this.icono, this.fondo, this.color, this.label, this.valor,
      this.enRango, this.isLast);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            border: !isLast
                ? const Border(bottom: BorderSide(color: Color(0xFFEEE8E4)))
                : null),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: fondo, borderRadius: BorderRadius.circular(9)),
              child: Icon(icono, size: 15, color: color)),
          const SizedBox(width: 12),
          Text(label,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textoSuave)),
          const Spacer(),
          Text(valor,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enRango ? AppColors.texto : AppColors.advertencia)),
          if (!enRango) ...[
            const SizedBox(width: 5),
            const Icon(Icons.warning_amber_rounded,
                size: 14, color: AppColors.advertencia),
          ],
        ]),
      );
}
