import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FermentacionScreen extends StatefulWidget {
  final String token;

  const FermentacionScreen({super.key, required this.token});

  @override
  State<FermentacionScreen> createState() => _FermentacionScreenState();
}

class _FermentacionScreenState extends State<FermentacionScreen> {
  final phController = TextEditingController();
  final brixController = TextEditingController();
  final temperaturaController = TextEditingController();
  final observacionController = TextEditingController();

  int? fincaId;
  bool guardando = false;

  // ── Rangos normales para café ──────────────────────────────────────
  static const double phMin = 3.5;
  static const double phMax = 5.5;
  static const double brixMin = 14.0;
  static const double brixMax = 24.0;
  static const double tempMin = 18.0;
  static const double tempMax = 30.0;

  @override
  void initState() {
    super.initState();
    cargarMiFinca();
  }

  @override
  void dispose() {
    phController.dispose();
    brixController.dispose();
    temperaturaController.dispose();
    observacionController.dispose();
    super.dispose();
  }

  Future<void> cargarMiFinca() async {
    final response = await ApiService.obtenerMiFinca(widget.token);
    if (response["success"]) {
      setState(() => fincaId = response["data"]["id"]);
    }
  }

  // Retorna null si el valor está bien, o un mensaje de advertencia si no
  String? _validarRango(String campo, double valor) {
    switch (campo) {
      case 'ph':
        if (valor < phMin || valor > phMax) {
          return "El pH normal del café está entre $phMin y $phMax.\nIngresaste: $valor";
        }
      case 'brix':
        if (valor < brixMin || valor > brixMax) {
          return "Los grados Brix normales están entre $brixMin y $brixMax.\nIngresaste: $valor";
        }
      case 'temp':
        if (valor < tempMin || valor > tempMax) {
          return "La temperatura normal está entre $tempMin°C y $tempMax°C.\nIngresaste: $valor°C";
        }
    }
    return null;
  }

  // Muestra diálogo de advertencia y pregunta si desea guardar de todas formas
  Future<bool> _mostrarAdvertencia(String mensaje) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF57F17),
                  size: 24,
                ),
                SizedBox(width: 10),
                Text(
                  "Valor fuera de rango",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mensaje,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D4037),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: const Text(
                    "¿Deseas guardar el registro de todas formas?",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF795548),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Corregir valor",
                  style: TextStyle(color: Color(0xFF8D6E63)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57F17),
                ),
                child: const Text("Guardar igual"),
              ),
            ],
          ),
    );
    return confirmar ?? false;
  }

  // Muestra bottom sheet de confirmación con los valores antes de guardar
  Future<bool> _mostrarConfirmacion(
    double ph,
    double brix,
    double temp,
    String obs,
  ) async {
    final confirmar = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFAF8F5),
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
                      color: const Color(0xFFD7CCC8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF4E342E),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Confirmar registro",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "¿Los valores son correctos?",
                    style: TextStyle(fontSize: 13, color: Color(0xFF8D6E63)),
                  ),
                ),
                const SizedBox(height: 16),
                // Tabla de valores
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8DDD5)),
                  ),
                  child: Column(
                    children: [
                      _ConfirmRow(
                        icono: Icons.water_drop_rounded,
                        color: const Color(0xFF1565C0),
                        colorFondo: const Color(0xFFE3F2FD),
                        label: "pH",
                        valor: "$ph pH",
                        enRango: ph >= phMin && ph <= phMax,
                        isFirst: true,
                      ),
                      _ConfirmRow(
                        icono: Icons.speed_rounded,
                        color: const Color(0xFF2E7D32),
                        colorFondo: const Color(0xFFE8F5E9),
                        label: "Brix",
                        valor: "$brix °Bx",
                        enRango: brix >= brixMin && brix <= brixMax,
                      ),
                      _ConfirmRow(
                        icono: Icons.thermostat_rounded,
                        color: const Color(0xFFBF360C),
                        colorFondo: const Color(0xFFFBE9E7),
                        label: "Temperatura",
                        valor: "$temp °C",
                        enRango: temp >= tempMin && temp <= tempMax,
                      ),
                      if (obs.isNotEmpty)
                        _ConfirmRow(
                          icono: Icons.notes_rounded,
                          color: const Color(0xFF6A1B9A),
                          colorFondo: const Color(0xFFF3E5F5),
                          label: "Observación",
                          valor: obs,
                          enRango: true,
                          isLast: true,
                        )
                      else
                        const SizedBox(height: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(color: Color(0xFFD7CCC8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Editar",
                          style: TextStyle(color: Color(0xFF5D4037)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Confirmar"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
    return confirmar ?? false;
  }

  Future<void> guardarRegistro() async {
    // 1. Validar campos vacíos
    if (phController.text.isEmpty ||
        brixController.text.isEmpty ||
        temperaturaController.text.isEmpty) {
      _snack("Completa pH, Brix y Temperatura");
      return;
    }

    // 2. Validar que sean números
    final ph = double.tryParse(phController.text);
    final brix = double.tryParse(brixController.text);
    final temp = double.tryParse(temperaturaController.text);

    if (ph == null || brix == null || temp == null) {
      _snack("Ingresa valores numéricos válidos");
      return;
    }

    if (fincaId == null) {
      _snack("No se encontró la finca asociada");
      return;
    }

    // 3. Validar rangos — si alguno está fuera preguntar si continúa
    final advertenciaPh = _validarRango('ph', ph);
    if (advertenciaPh != null) {
      final continuar = await _mostrarAdvertencia(advertenciaPh);
      if (!continuar) return;
    }

    final advertenciaBrix = _validarRango('brix', brix);
    if (advertenciaBrix != null) {
      final continuar = await _mostrarAdvertencia(advertenciaBrix);
      if (!continuar) return;
    }

    final advertenciaTemp = _validarRango('temp', temp);
    if (advertenciaTemp != null) {
      final continuar = await _mostrarAdvertencia(advertenciaTemp);
      if (!continuar) return;
    }

    // 4. Mostrar confirmación con resumen de valores
    final obs = observacionController.text.trim();
    final confirmar = await _mostrarConfirmacion(ph, brix, temp, obs);
    if (!confirmar) return;

    // 5. Guardar
    setState(() => guardando = true);

    final response = await ApiService.guardarFermentacion(
      token: widget.token,
      fincaId: fincaId!,
      ph: ph,
      brix: brix,
      temperatura: temp,
      observacion: obs,
    );

    setState(() => guardando = false);

    if (response["success"]) {
      _snack("✓ Registro guardado correctamente");
      phController.clear();
      brixController.clear();
      temperaturaController.clear();
      observacionController.clear();
    } else {
      _snack(response["message"].toString());
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: const Text("Fermentación"),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF4E342E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.science_rounded,
                      color: Color(0xFFEFEBE9),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Registro de Fermentación",
                        style: TextStyle(
                          color: Color(0xFFEFEBE9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Color(0xFFA5D6A7)),
                          SizedBox(width: 5),
                          Text(
                            "Proceso activo",
                            style: TextStyle(
                              color: Color(0xFFC8E6C9),
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

            const SizedBox(height: 20),

            // ── Rangos de referencia ────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: Color(0xFF2E7D32),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Rangos normales para café",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _RangoChip(label: "pH", rango: "3.5 – 5.5"),
                  SizedBox(height: 4),
                  _RangoChip(label: "Brix", rango: "14 – 24 °Bx"),
                  SizedBox(height: 4),
                  _RangoChip(label: "Temp", rango: "18 – 30 °C"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Métricas ────────────────────────────────────
            const Text(
              "Parámetros de medición",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _MetricaInput(
                    controller: phController,
                    label: "pH",
                    unidad: "pH",
                    icono: Icons.water_drop_rounded,
                    colorIcono: const Color(0xFF1565C0),
                    colorFondo: const Color(0xFFE3F2FD),
                    min: phMin,
                    max: phMax,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricaInput(
                    controller: brixController,
                    label: "Brix",
                    unidad: "°Bx",
                    icono: Icons.speed_rounded,
                    colorIcono: const Color(0xFF2E7D32),
                    colorFondo: const Color(0xFFE8F5E9),
                    min: brixMin,
                    max: brixMax,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricaInput(
              controller: temperaturaController,
              label: "Temperatura",
              unidad: "°C",
              icono: Icons.thermostat_rounded,
              colorIcono: const Color(0xFFBF360C),
              colorFondo: const Color(0xFFFBE9E7),
              min: tempMin,
              max: tempMax,
              fullWidth: true,
            ),

            const SizedBox(height: 20),

            // ── Observaciones ───────────────────────────────
            const Text(
              "Observaciones",
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
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8DDD5)),
              ),
              child: TextField(
                controller: observacionController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
                decoration: InputDecoration(
                  hintText: "Escribe tus observaciones aquí...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: guardando ? null : guardarRegistro,
                child:
                    guardando
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFEFEBE9),
                          ),
                        )
                        : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded, size: 20),
                            SizedBox(width: 8),
                            Text("Guardar Registro"),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget de campo métrica con indicador de rango ─────────────────────
class _MetricaInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String unidad;
  final IconData icono;
  final Color colorIcono;
  final Color colorFondo;
  final double min;
  final double max;
  final bool fullWidth;

  const _MetricaInput({
    required this.controller,
    required this.label,
    required this.unidad,
    required this.icono,
    required this.colorIcono,
    required this.colorFondo,
    required this.min,
    required this.max,
    this.fullWidth = false,
  });

  @override
  State<_MetricaInput> createState() => _MetricaInputState();
}

class _MetricaInputState extends State<_MetricaInput> {
  bool _fueraDeRango = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_verificarRango);
  }

  void _verificarRango() {
    final val = double.tryParse(widget.controller.text);
    setState(() {
      _fueraDeRango = val != null && (val < widget.min || val > widget.max);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_verificarRango);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              _fueraDeRango ? const Color(0xFFF57F17) : const Color(0xFFE8DDD5),
          width: _fueraDeRango ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      _fueraDeRango
                          ? const Color(0xFFFFF8E1)
                          : widget.colorFondo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icono,
                  color:
                      _fueraDeRango
                          ? const Color(0xFFF57F17)
                          : widget.colorIcono,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      _fueraDeRango
                          ? const Color(0xFFF57F17)
                          : const Color(0xFF8D6E63),
                ),
              ),
              if (_fueraDeRango) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: Color(0xFFF57F17),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color:
                        _fueraDeRango
                            ? const Color(0xFFF57F17)
                            : const Color(0xFF3E2723),
                  ),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _fueraDeRango
                                ? const Color(0xFFF57F17)
                                : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _fueraDeRango
                                ? const Color(0xFFF57F17)
                                : const Color(0xFF4E342E),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            _fueraDeRango
                                ? const Color(0xFFF57F17)
                                : Colors.grey.shade300,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    filled: false,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  widget.unidad,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA1887F),
                  ),
                ),
              ),
            ],
          ),
          if (_fueraDeRango) ...[
            const SizedBox(height: 6),
            Text(
              "Rango normal: ${widget.min} – ${widget.max}",
              style: const TextStyle(fontSize: 10, color: Color(0xFFF57F17)),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Chip de rango de referencia ────────────────────────────────────────
class _RangoChip extends StatelessWidget {
  final String label;
  final String rango;

  const _RangoChip({required this.label, required this.rango});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_rounded, size: 13, color: Color(0xFF2E7D32)),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        Text(
          rango,
          style: const TextStyle(fontSize: 12, color: Color(0xFF388E3C)),
        ),
      ],
    );
  }
}

// ── Fila del bottom sheet de confirmación ─────────────────────────────
class _ConfirmRow extends StatelessWidget {
  final IconData icono;
  final Color color;
  final Color colorFondo;
  final String label;
  final String valor;
  final bool enRango;
  final bool isFirst;
  final bool isLast;

  const _ConfirmRow({
    required this.icono,
    required this.color,
    required this.colorFondo,
    required this.label,
    required this.valor,
    required this.enRango,
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
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: colorFondo,
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  enRango ? const Color(0xFF3E2723) : const Color(0xFFF57F17),
            ),
          ),
          if (!enRango) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.warning_amber_rounded,
              size: 15,
              color: Color(0xFFF57F17),
            ),
          ],
        ],
      ),
    );
  }
}
