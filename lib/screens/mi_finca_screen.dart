import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';

class MiFincaScreen extends StatefulWidget {
  final String token;
  final String nombreUsuario; // viene de HomeScreen / SharedPreferences
  const MiFincaScreen(
      {super.key, required this.token, required this.nombreUsuario});
  @override
  State<MiFincaScreen> createState() => _MiFincaScreenState();
}

class _MiFincaScreenState extends State<MiFincaScreen> {
  Map<String, dynamic>? _finca;
  // Último registro de calidad para mostrar notas_cata como perfil de taza
  Map<String, dynamic>? _ultimaCalidad;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);

    final fRes = await ApiService.obtenerMiFinca(widget.token);
    if (!fRes['success']) {
      setState(() {
        _finca = null;
        _cargando = false;
      });
      return;
    }

    _finca = fRes['data'];

    // GET /calidad/public/{id} devuelve: fecha, puntaje_sensorial,
    // perfil_tueste, notas_cata, proceso — exactamente lo que necesitamos
    final fincaId = _finca!['id'];
    if (fincaId != null) {
      final cRes = await ApiService.obtenerCalidadPublica(fincaId);
      if (cRes['success']) {
        final lista = List<Map<String, dynamic>>.from(cRes['data'] as List);
        if (lista.isNotEmpty) _ultimaCalidad = lista.first;
      }
    }

    setState(() => _cargando = false);
  }

  String _val(String key, [String fallback = '—']) {
    final v = (_finca?[key] ?? '').toString().trim();
    return v.isEmpty ? fallback : v;
  }

  // Lee un campo del último registro de calidad, devuelve '—' si no existe
  String _valCalidad(String key) {
    final v = (_ultimaCalidad?[key] ?? '').toString().trim();
    return v.isNotEmpty ? v : '—';
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando)
      return const Scaffold(
          body:
              Center(child: CircularProgressIndicator(color: AppColors.verde)));

    if (_finca == null)
      return Scaffold(
          appBar: AppBar(title: const Text('Mi Finca')),
          body: EstadoVacio(
              icono: Icons.terrain_rounded,
              titulo: 'No hay finca registrada',
              subtitulo: 'Contacta al administrador para registrar tu finca',
              onReintentar: _cargar));

    final imagenUrl = _finca!['imagen_url'];

    return Scaffold(
      body: CustomScrollView(slivers: [
        // ── AppBar con imagen ─────────────────────────────
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: AppColors.verde,
          leading: const BackButton(),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(_val('nombre_finca'),
                style: const TextStyle(
                    color: AppColors.blanco,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black45)])),
            background: Stack(fit: StackFit.expand, children: [
              imagenUrl != null
                  ? Image.network('$baseUrl/$imagenUrl',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _Placeholder())
                  : _Placeholder(),
              const DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54]))),
            ]),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Productor ─────────────────────────────
                const SeccionTitulo(
                    icono: Icons.person_outline_rounded,
                    titulo: 'Datos del productor'),
                const SizedBox(height: 12),
                AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      // Nombre del productor = nombre de usuario logueado
                      InfoRow(
                          icono: Icons.badge_outlined,
                          colorIcono: AppColors.verdeMedio,
                          colorFondo: const Color(0xFFE8F5E0),
                          label: 'Productor',
                          valor: widget.nombreUsuario.isNotEmpty
                              ? widget.nombreUsuario
                              : _val('nombre_productor'),
                          isLast: true),
                    ])),

                const SizedBox(height: 20),

                // ── Datos de la finca ─────────────────────
                const SeccionTitulo(
                    icono: Icons.terrain_rounded, titulo: 'Datos de la finca'),
                const SizedBox(height: 12),
                AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      InfoRow(
                          icono: Icons.location_on_rounded,
                          colorIcono: const Color(0xFFBF360C),
                          colorFondo: const Color(0xFFFBE9E7),
                          label: 'Municipio',
                          valor: _val('municipio')),
                      InfoRow(
                          icono: Icons.grass_rounded,
                          colorIcono: AppColors.verdeClaro,
                          colorFondo: const Color(0xFFE8F5E0),
                          label: 'Vereda',
                          valor: _val('vereda')),
                      InfoRow(
                          icono: Icons.terrain_outlined,
                          colorIcono: const Color(0xFF1565C0),
                          colorFondo: const Color(0xFFE3F2FD),
                          label: 'Altura',
                          // La API devuelve "altura_finca" con el valor ya formateado
                          valor: _val('altura_finca')),
                      InfoRow(
                          icono: Icons.straighten_rounded,
                          colorIcono: const Color(0xFF6A1B9A),
                          colorFondo: const Color(0xFFF3E5F5),
                          label: 'Extensión',
                          valor: _finca!['hectareas'] != null
                              ? '${_finca!["hectareas"]} ha'
                              : '—',
                          isLast: true),
                    ])),

                const SizedBox(height: 20),

                // ── Café ──────────────────────────────────
                const SeccionTitulo(
                    icono: Icons.coffee_outlined,
                    titulo: 'Información del café'),
                const SizedBox(height: 12),
                AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      InfoRow(
                          icono: Icons.eco_rounded,
                          colorIcono: AppColors.verdeMedio,
                          colorFondo: const Color(0xFFE8F5E0),
                          label: 'Variedad',
                          valor: _val('variedad_cafe') != '—'
                              ? _val('variedad_cafe')
                              : _val('variedad'),
                          multilinea: true),
                      InfoRow(
                          icono: Icons.settings_outlined,
                          colorIcono: AppColors.dorado,
                          colorFondo: const Color(0xFFFFF8EC),
                          label: 'Proceso',
                          valor: _valCalidad('proceso'),
                          multilinea: true),
                      // Perfil de taza = notas_cata del último registro de calidad
                      InfoRow(
                          icono: Icons.star_outline_rounded,
                          colorIcono: AppColors.dorado,
                          colorFondo: const Color(0xFFFFF8EC),
                          label: 'Perfil de taza',
                          valor: _valCalidad('notas_cata'),
                          isLast: true,
                          multilinea: true),
                    ])),

                // Puntaje sensorial si hay datos de calidad
                if (_ultimaCalidad != null &&
                    _ultimaCalidad!['puntaje_sensorial'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                          color: AppColors.dorado.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.dorado.withOpacity(0.25))),
                      child: Row(children: [
                        Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.dorado.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.star_rounded,
                                color: AppColors.dorado, size: 18)),
                        const SizedBox(width: 12),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Puntaje sensorial',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textoSuave)),
                              Text(
                                  '${_ultimaCalidad!["puntaje_sensorial"]} / 100',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dorado)),
                            ]),
                        const Spacer(),
                        if ((_ultimaCalidad!['perfil_tueste'] ?? '').isNotEmpty)
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: AppColors.dorado.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(_ultimaCalidad!['perfil_tueste'],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.dorado))),
                      ])),
                ],

                if (((_finca!['descripcion'] ?? '')).toString().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const SeccionTitulo(
                      icono: Icons.description_outlined, titulo: 'Descripción'),
                  const SizedBox(height: 12),
                  AppCard(
                      child: Text(_val('descripcion'),
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textoSuave,
                              height: 1.6))),
                ],

                const SizedBox(height: 20),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFC8E6C9))),
                    child: const Row(children: [
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.exito, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                          child: Text('Finca registrada y activa en el sistema',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.exito))),
                    ])),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      color: AppColors.verdeMedio,
      child: const Center(
          child:
              Icon(Icons.landscape_rounded, size: 64, color: Colors.white24)));
}
