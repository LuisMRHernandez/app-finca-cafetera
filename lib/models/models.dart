// ── models/usuario.dart ───────────────────────────────────────
class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String? celular;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.celular,
  });

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        id: j['id'],
        nombre: j['nombre'] ?? '',
        email: j['email'] ?? '',
        celular: j['celular'],
      );
}

// ── models/finca.dart ─────────────────────────────────────────
class Finca {
  final int id;
  final String nombre;
  final String? ubicacion;
  final String? altura;
  final String? variedadCafe;
  final String? proceso;
  final String? perfil;
  final String? imagenUrl;

  Finca({
    required this.id,
    required this.nombre,
    this.ubicacion,
    this.altura,
    this.variedadCafe,
    this.proceso,
    this.perfil,
    this.imagenUrl,
  });

  factory Finca.fromJson(Map<String, dynamic> j) => Finca(
        id: j['id'],
        nombre: j['nombre_finca'] ?? j['nombre'] ?? '',
        ubicacion: j['municipio'] ?? j['ubicacion'],
        altura: j['altura_finca'] ?? j['altura'],
        variedadCafe: j['variedad_cafe'] ?? j['variedad'],
        proceso: j['proceso'],
        perfil: j['perfil'],
        imagenUrl: j['imagen_url'] ?? j['foto_url'],
      );
}

// ── models/calidad_cafe.dart ──────────────────────────────────
class CalidadCafe {
  final int id;
  final int fincaId;
  final double brix;
  final double ph;
  final double temperatura;
  final double? puntajeSensorial;
  final String? perfilTueste;
  final String? notasCata;
  final String? observacion;
  final DateTime fecha;

  CalidadCafe({
    required this.id,
    required this.fincaId,
    required this.brix,
    required this.ph,
    required this.temperatura,
    this.puntajeSensorial,
    this.perfilTueste,
    this.notasCata,
    this.observacion,
    required this.fecha,
  });

  factory CalidadCafe.fromJson(Map<String, dynamic> j) => CalidadCafe(
        id: j['id'],
        fincaId: j['finca_id'],
        brix: (j['brix'] as num).toDouble(),
        ph: (j['ph'] as num).toDouble(),
        temperatura: (j['temperatura'] as num).toDouble(),
        puntajeSensorial: (j['puntaje_sensorial'] as num?)?.toDouble(),
        perfilTueste: j['perfil_tueste'],
        notasCata: j['notas_cata'],
        observacion: j['observacion'],
        fecha: DateTime.tryParse(j['fecha'] ?? j['fecha_registro'] ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'finca_id': fincaId,
        'brix': brix,
        'ph': ph,
        'temperatura': temperatura,
        if (puntajeSensorial != null) 'puntaje_sensorial': puntajeSensorial,
        if (perfilTueste != null) 'perfil_tueste': perfilTueste,
        if (notasCata != null) 'notas_cata': notasCata,
        if (observacion != null) 'observacion': observacion,
      };
}
