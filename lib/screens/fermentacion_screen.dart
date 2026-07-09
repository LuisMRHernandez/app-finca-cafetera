import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';

class FermentacionScreen extends StatefulWidget {
  final String token;
  const FermentacionScreen({super.key, required this.token});
  @override
  State<FermentacionScreen> createState() => _FermentacionScreenState();
}

class _FermentacionScreenState extends State<FermentacionScreen> {
  final _phCtrl = TextEditingController();
  final _brixCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _observacionCtrl = TextEditingController();

  int? _fincaId;
  bool _guardando = false;

  // Rangos normales para café
  static const double phMin = 3.5, phMax = 5.5;
  static const double brixMin = 14.0, brixMax = 24.0;
  static const double tempMin = 18.0, tempMax = 30.0;

  @override
  void initState() {
    super.initState();
    _cargarFinca();
  }

  @override
  void dispose() {
    _phCtrl.dispose();
    _brixCtrl.dispose();
    _tempCtrl.dispose();
    _observacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarFinca() async {
    final res = await ApiService.obtenerMiFinca(widget.token);
    if (res['success']) setState(() => _fincaId = res['data']['id']);
  }

  String? _validarRango(String campo, double v) {
    switch (campo) {
      case 'ph':
        if (v < phMin || v > phMax)
          return 'pH normal: $phMin – $phMax\nIngresaste: $v';
      case 'brix':
        if (v < brixMin || v > brixMax)
          return 'Brix normal: $brixMin – $brixMax\nIngresaste: $v';
      case 'temp':
        if (v < tempMin || v > tempMax)
          return 'Temperatura normal: ${tempMin}°C – ${tempMax}°C\nIngresaste: ${v}°C';
    }
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

  Future<bool> _confirmar(double ph, double brix, double temp) async {
    return await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => _ConfirmSheet(
              ph: ph,
              brix: brix,
              temp: temp,
              observacion: _observacionCtrl.text.trim()),
        ) ??
        false;
  }

  Future<void> _guardar() async {
    if (_phCtrl.text.isEmpty ||
        _brixCtrl.text.isEmpty ||
        _tempCtrl.text.isEmpty) {
      _snack('Completa pH, Brix y Temperatura');
      return;
    }
    final ph = double.tryParse(_phCtrl.text);
    final brix = double.tryParse(_brixCtrl.text);
    final temp = double.tryParse(_tempCtrl.text);
    if (ph == null || brix == null || temp == null) {
      _snack('Ingresa valores numéricos válidos');
      return;
    }
    if (_fincaId == null) {
      _snack('No se encontró la finca');
      return;
    }

    for (final e in [
      MapEntry('ph', ph),
      MapEntry('brix', brix),
      MapEntry('temp', temp)
    ]) {
      final msg = _validarRango(e.key, e.value);
      if (msg != null && !await _advertencia(msg)) return;
    }

    if (!await _confirmar(ph, brix, temp)) return;

    setState(() => _guardando = true);
    final res = await ApiService.guardarFermentacion(
      token: widget.token,
      fincaId: _fincaId!,
      ph: ph,
      brix: brix,
      temperatura: temp,
      observacion: _observacionCtrl.text.trim(),
    );
    setState(() => _guardando = false);

    if (res['success']) {
      _snack('✓ Registro guardado correctamente');
      _phCtrl.clear();
      _brixCtrl.clear();
      _tempCtrl.clear();
      _observacionCtrl.clear();
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
          title: const Text('Registro de Fermentación'),
          leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Banner ───────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.verde, AppColors.verdeMedio],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.science_rounded,
                      color: AppColors.doradoClaro, size: 26)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Datos de Fermentación',
                        style: TextStyle(
                            color: AppColors.blanco,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text('pH · Brix · Temperatura · Observación',
                        style: TextStyle(
                            color: AppColors.blanco.withOpacity(0.65),
                            fontSize: 12)),
                  ])),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Nota informativa ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.verde.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.verde.withOpacity(0.15))),
            child: const Row(children: [
              Icon(Icons.repeat_rounded, size: 16, color: AppColors.verdeClaro),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'Este registro se puede llenar varias veces durante el proceso de fermentación.',
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
                color: const Color(0xFFE8F5E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC8E6C9))),
            child: Column(children: [
              const Row(children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: AppColors.verdeClaro),
                SizedBox(width: 6),
                Text('Rangos normales para café',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.verdeClaro)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _RangoChip('pH', '$phMin – $phMax'),
                const SizedBox(width: 8),
                _RangoChip('Brix', '$brixMin – $brixMax °Bx'),
                const SizedBox(width: 8),
                _RangoChip('Temp', '$tempMin – $tempMax °C'),
              ]),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Campos de medición ───────────────────────────
          const SeccionTitulo(
              icono: Icons.science_outlined,
              titulo: 'Parámetros de fermentación'),
          const SizedBox(height: 14),

          Row(children: [
            Expanded(
                child: _CampoMetrica(
                    ctrl: _phCtrl,
                    label: 'pH',
                    unidad: 'pH',
                    icono: Icons.water_drop_rounded,
                    colorIcono: const Color(0xFF1565C0),
                    colorFondo: const Color(0xFFE3F2FD),
                    min: phMin,
                    max: phMax)),
            const SizedBox(width: 12),
            Expanded(
                child: _CampoMetrica(
                    ctrl: _brixCtrl,
                    label: 'Brix',
                    unidad: '°Bx',
                    icono: Icons.speed_rounded,
                    colorIcono: AppColors.verdeClaro,
                    colorFondo: const Color(0xFFE8F5E0),
                    min: brixMin,
                    max: brixMax)),
          ]),
          const SizedBox(height: 12),
          _CampoMetrica(
              ctrl: _tempCtrl,
              label: 'Temperatura',
              unidad: '°C',
              icono: Icons.thermostat_rounded,
              colorIcono: const Color(0xFFBF360C),
              colorFondo: const Color(0xFFFBE9E7),
              min: tempMin,
              max: tempMax),

          const SizedBox(height: 24),

          // ── Observación ──────────────────────────────────
          const SeccionTitulo(
              icono: Icons.notes_outlined, titulo: 'Observación'),
          const SizedBox(height: 12),
          TextField(
              controller: _observacionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Novedades del proceso, condiciones del día...',
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
  Widget build(BuildContext context) {
    return Container(
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
          Text(widget.label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      _fuera ? AppColors.advertencia : AppColors.textoSuave)),
          if (_fuera) ...[
            const SizedBox(width: 4),
            const Icon(Icons.warning_amber_rounded,
                size: 13, color: AppColors.advertencia),
          ],
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
              child: TextField(
            controller: widget.ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        color:
                            _fuera ? AppColors.advertencia : AppColors.borde)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: _fuera ? AppColors.advertencia : AppColors.verde,
                        width: 1.5)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            _fuera ? AppColors.advertencia : AppColors.borde)),
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false),
          )),
          const SizedBox(width: 4),
          Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(widget.unidad,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textoSuave))),
        ]),
        if (_fuera) ...[
          const SizedBox(height: 5),
          Text('Rango normal: ${widget.min} – ${widget.max}',
              style:
                  const TextStyle(fontSize: 10, color: AppColors.advertencia)),
        ],
      ]),
    );
  }
}

// ── Chip de rango ─────────────────────────────────────────────
class _RangoChip extends StatelessWidget {
  final String label, rango;
  const _RangoChip(this.label, this.rango);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.verdeMedio.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.verdeMedio)),
            const SizedBox(height: 2),
            Text(rango,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textoSuave)),
          ]),
        ),
      );
}

// ── Bottom sheet de confirmación ──────────────────────────────
class _ConfirmSheet extends StatelessWidget {
  final double ph, brix, temp;
  final String observacion;
  const _ConfirmSheet(
      {required this.ph,
      required this.brix,
      required this.temp,
      required this.observacion});

  bool _ok(String c, double v) {
    if (c == 'ph') return v >= 3.5 && v <= 5.5;
    if (c == 'brix') return v >= 14 && v <= 24;
    if (c == 'temp') return v >= 18 && v <= 30;
    return true;
  }

  @override
  Widget build(BuildContext context) => Container(
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
                  style: TextStyle(fontSize: 13, color: AppColors.textoSuave))),
          const SizedBox(height: 16),
          AppCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _CRow(
                    Icons.water_drop_rounded,
                    const Color(0xFFE3F2FD),
                    const Color(0xFF1565C0),
                    'pH',
                    '$ph pH',
                    _ok('ph', ph),
                    false),
                _CRow(
                    Icons.speed_rounded,
                    const Color(0xFFE8F5E0),
                    AppColors.verdeClaro,
                    'Brix',
                    '$brix °Bx',
                    _ok('brix', brix),
                    false),
                _CRow(
                    Icons.thermostat_rounded,
                    const Color(0xFFFBE9E7),
                    const Color(0xFFBF360C),
                    'Temperatura',
                    '$temp °C',
                    _ok('temp', temp),
                    observacion.isEmpty),
                if (observacion.isNotEmpty)
                  _CRow(
                      Icons.notes_rounded,
                      const Color(0xFFF3E5F5),
                      const Color(0xFF6A1B9A),
                      'Observación',
                      observacion,
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
          Flexible(
              child: Text(valor,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: enRango ? AppColors.texto : AppColors.advertencia),
                  overflow: TextOverflow.ellipsis)),
          if (!enRango) ...[
            const SizedBox(width: 5),
            const Icon(Icons.warning_amber_rounded,
                size: 14, color: AppColors.advertencia),
          ],
        ]),
      );
}
