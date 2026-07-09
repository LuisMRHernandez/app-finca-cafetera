import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';

class CalidadScreen extends StatefulWidget {
  final String token;
  const CalidadScreen({super.key, required this.token});
  @override
  State<CalidadScreen> createState() => _CalidadScreenState();
}

class _CalidadScreenState extends State<CalidadScreen> {
  final _puntajeCtrl = TextEditingController();
  final _perfilTuesteCtrl = TextEditingController();
  final _notasCataCtrl = TextEditingController();
  final _procesoCtrl = TextEditingController();
  final _observacionCtrl = TextEditingController();

  int? _fincaId;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarFinca();
  }

  @override
  void dispose() {
    _puntajeCtrl.dispose();
    _perfilTuesteCtrl.dispose();
    _notasCataCtrl.dispose();
    _procesoCtrl.dispose();
    _observacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarFinca() async {
    final res = await ApiService.obtenerMiFinca(widget.token);
    if (res['success']) setState(() => _fincaId = res['data']['id']);
  }

  Future<void> _guardar() async {
    final puntaje = double.tryParse(_puntajeCtrl.text);
    final perfilTueste = _perfilTuesteCtrl.text.trim();
    final notasCata = _notasCataCtrl.text.trim();
    final proceso = _procesoCtrl.text.trim();
    final observacion = _observacionCtrl.text.trim();

    // Al menos un campo debe estar lleno
    if (puntaje == null &&
        perfilTueste.isEmpty &&
        notasCata.isEmpty &&
        proceso.isEmpty &&
        observacion.isEmpty) {
      _snack('Completa al menos un campo antes de guardar');
      return;
    }

    if (puntaje != null && (puntaje < 0 || puntaje > 100)) {
      _snack('El puntaje sensorial debe estar entre 0 y 100');
      return;
    }

    if (_fincaId == null) {
      _snack('No se encontró la finca');
      return;
    }

    final confirmar = await _confirmar(
        puntaje, perfilTueste, notasCata, proceso, observacion);
    if (!confirmar) return;

    setState(() => _guardando = true);
    final res = await ApiService.guardarCalidad(
      token: widget.token,
      fincaId: _fincaId!,
      puntajeSensorial: puntaje,
      perfilTueste: perfilTueste.isEmpty ? null : perfilTueste,
      notasCata: notasCata.isEmpty ? null : notasCata,
      proceso: proceso.isEmpty ? null : proceso,
      observacion: observacion.isEmpty ? null : observacion,
    );
    setState(() => _guardando = false);

    if (res['success']) {
      _snack('✓ Evaluación de calidad guardada');
      _puntajeCtrl.clear();
      _perfilTuesteCtrl.clear();
      _notasCataCtrl.clear();
      _procesoCtrl.clear();
      _observacionCtrl.clear();
    } else {
      _snack(res['message']?.toString() ?? 'Error al guardar');
    }
  }

  Future<bool> _confirmar(double? puntaje, String perfil, String notas,
      String proceso, String obs) async {
    return await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => _ConfirmSheet(
            puntaje: puntaje,
            perfil: perfil,
            notas: notas,
            proceso: proceso,
            obs: obs,
          ),
        ) ??
        false;
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Calidad de Café'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Banner dorado ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.dorado, AppColors.doradoClaro],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.star_rounded,
                      color: Colors.white, size: 26)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Evaluación de Calidad',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('Una vez por cosecha',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12)),
                  ])),
            ]),
          ),

          const SizedBox(height: 14),

          // ── Nota informativa ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.dorado.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.dorado.withOpacity(0.2))),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.dorado),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'Esta evaluación se realiza una vez por cosecha. '
                      'Las notas de cata aparecerán como perfil de taza en tu finca.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textoSuave,
                          height: 1.5))),
            ]),
          ),

          const SizedBox(height: 28),

          // ── Puntaje sensorial ────────────────────────────
          const SeccionTitulo(
              icono: Icons.analytics_outlined,
              titulo: 'Puntaje sensorial',
              color: AppColors.dorado),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
                color: AppColors.blanco,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borde)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EC),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.star_rounded,
                        size: 15, color: AppColors.dorado)),
                const SizedBox(width: 8),
                const Text('Puntos (0 – 100)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textoSuave)),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    child: TextField(
                  controller: _puntajeCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                  ],
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texto),
                  decoration: const InputDecoration(
                      hintText: '0 – 100',
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.borde)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.dorado, width: 1.5)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.borde)),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      filled: false),
                )),
                const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(' pts',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textoSuave))),
              ]),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Proceso ──────────────────────────────────────
          const SeccionTitulo(
              icono: Icons.settings_outlined,
              titulo: 'Proceso de beneficio',
              color: AppColors.dorado),
          const SizedBox(height: 12),

          TextField(
              controller: _procesoCtrl,
              decoration: const InputDecoration(
                  labelText: 'Proceso',
                  hintText: 'Ej: Lavado, Natural, Honey, Anaerobio',
                  prefixIcon: Icon(Icons.settings_outlined,
                      color: AppColors.textoSuave))),

          const SizedBox(height: 24),

          // ── Perfil y notas ───────────────────────────────
          const SeccionTitulo(
              icono: Icons.coffee_outlined,
              titulo: 'Perfil de taza',
              color: AppColors.dorado),
          const SizedBox(height: 12),

          TextField(
              controller: _perfilTuesteCtrl,
              decoration: const InputDecoration(
                  labelText: 'Perfil de tueste',
                  hintText: 'Ej: Medio, Oscuro, Claro',
                  prefixIcon: Icon(Icons.local_fire_department_outlined,
                      color: AppColors.textoSuave))),
          const SizedBox(height: 14),

          TextField(
              controller: _notasCataCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Notas de cata',
                  hintText: 'Ej: Frutal, achocolatado, cítrico, caramelo...',
                  prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.coffee_rounded,
                          color: AppColors.textoSuave)),
                  alignLabelWithHint: true)),

          const SizedBox(height: 24),

          // ── Observación ──────────────────────────────────
          const SeccionTitulo(
              icono: Icons.notes_outlined, titulo: 'Observación general'),
          const SizedBox(height: 12),

          TextField(
              controller: _observacionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Condiciones de cosecha, novedades, comentarios...',
                  prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.edit_note_rounded,
                          color: AppColors.textoSuave)),
                  alignLabelWithHint: true)),

          const SizedBox(height: 36),

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
                  : const Icon(Icons.star_rounded, size: 20),
              label: Text(_guardando ? 'Guardando...' : 'Guardar Evaluación'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dorado,
                  foregroundColor: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ── Bottom sheet de confirmación ──────────────────────────────
class _ConfirmSheet extends StatelessWidget {
  final double? puntaje;
  final String perfil, notas, proceso, obs;

  const _ConfirmSheet({
    this.puntaje,
    required this.perfil,
    required this.notas,
    required this.proceso,
    required this.obs,
  });

  @override
  Widget build(BuildContext context) {
    // Construye solo las filas con datos
    final filas = <_FilaDato>[
      if (puntaje != null)
        _FilaDato(Icons.analytics_rounded, const Color(0xFFFFF8EC),
            AppColors.dorado, 'Puntaje sensorial', '$puntaje / 100'),
      if (proceso.isNotEmpty)
        _FilaDato(Icons.settings_outlined, const Color(0xFFE8F5E0),
            AppColors.verdeMedio, 'Proceso', proceso),
      if (perfil.isNotEmpty)
        _FilaDato(Icons.local_fire_department_outlined, const Color(0xFFFFF8EC),
            AppColors.dorado, 'Perfil de tueste', perfil),
      if (notas.isNotEmpty)
        _FilaDato(Icons.coffee_outlined, const Color(0xFFE8F5E0),
            AppColors.verdeClaro, 'Notas de cata', notas),
      if (obs.isNotEmpty)
        _FilaDato(Icons.notes_rounded, const Color(0xFFF3E5F5),
            const Color(0xFF6A1B9A), 'Observación', obs),
    ];

    return Container(
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
          Icon(Icons.star_rounded, color: AppColors.dorado, size: 22),
          SizedBox(width: 10),
          Text('Confirmar evaluación',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.texto)),
        ]),
        const SizedBox(height: 4),
        const Align(
            alignment: Alignment.centerLeft,
            child: Text('¿Los datos son correctos?',
                style: TextStyle(fontSize: 13, color: AppColors.textoSuave))),
        const SizedBox(height: 16),
        AppCard(
            padding: EdgeInsets.zero,
            child: Column(
                children: List.generate(
                    filas.length,
                    (i) => _Fila(
                          dato: filas[i],
                          isLast: i == filas.length - 1,
                        )))),
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dorado),
                  child: const Text('Confirmar'))),
        ]),
      ]),
    );
  }
}

class _FilaDato {
  final IconData icono;
  final Color fondo, color;
  final String label, valor;
  const _FilaDato(this.icono, this.fondo, this.color, this.label, this.valor);
}

class _Fila extends StatelessWidget {
  final _FilaDato dato;
  final bool isLast;
  const _Fila({required this.dato, required this.isLast});

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
                  color: dato.fondo, borderRadius: BorderRadius.circular(9)),
              child: Icon(dato.icono, size: 15, color: dato.color)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(dato.label,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textoSuave))),
          const SizedBox(width: 8),
          Flexible(
              child: Text(dato.valor,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.texto),
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
}
