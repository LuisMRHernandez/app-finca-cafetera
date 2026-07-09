import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';

class FotoFincaScreen extends StatefulWidget {
  final String token;
  const FotoFincaScreen({super.key, required this.token});
  @override
  State<FotoFincaScreen> createState() => _FotoFincaScreenState();
}

class _FotoFincaScreenState extends State<FotoFincaScreen> {
  File? _imagen;
  bool _cargando = false;
  final _picker = ImagePicker();

  Future<void> _seleccionar(ImageSource fuente) async {
    final f = await _picker.pickImage(
      source: fuente,
      imageQuality: 80,
      maxWidth: 1400,
    );
    if (f != null) setState(() => _imagen = File(f.path));
  }

  void _elegirFuente() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
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
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Seleccionar imagen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.texto,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _OpcionFuente(
                  icono: Icons.camera_alt_rounded,
                  titulo: 'Tomar foto',
                  subtitulo: 'Abre la cámara del dispositivo',
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionar(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                _OpcionFuente(
                  icono: Icons.photo_library_rounded,
                  titulo: 'Elegir de la galería',
                  subtitulo: 'Selecciona una imagen existente',
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionar(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _subir() async {
    if (_imagen == null) {
      _snack('Selecciona una imagen primero');
      return;
    }
    setState(() => _cargando = true);

    final fRes = await ApiService.obtenerMiFinca(widget.token);
    if (!fRes['success']) {
      setState(() => _cargando = false);
      _snack('No se pudo obtener la finca');
      return;
    }

    final res = await ApiService.subirFotoFinca(
      widget.token,
      fRes['data']['id'],
      _imagen!,
    );
    setState(() => _cargando = false);

    if (res['success']) {
      _snack('✓ ${res["message"]}');
      setState(() => _imagen = null);
    } else {
      _snack(res['message'] ?? 'Error al subir la foto');
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto de la Finca'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Vista previa ──────────────────────────────
            GestureDetector(
              onTap: _elegirFuente,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      _imagen != null
                          ? Colors.transparent
                          : AppColors.verde.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        _imagen != null
                            ? AppColors.borde
                            : AppColors.verde.withOpacity(0.2),
                    width: _imagen != null ? 1 : 1.5,
                    style:
                        _imagen != null ? BorderStyle.solid : BorderStyle.solid,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    _imagen != null
                        ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_imagen!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.verde.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 13,
                                      color: AppColors.blanco,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Cambiar',
                                      style: TextStyle(
                                        color: AppColors.blanco,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.verde.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 40,
                                color: AppColors.verdeClaro,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Toca para seleccionar una foto',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.texto,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Cámara o galería',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textoSuave,
                              ),
                            ),
                          ],
                        ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Consejo ───────────────────────────────────
            AppCard(
              child: const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: AppColors.dorado,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Usa una foto con buena iluminación que muestre el cultivo. '
                      'La imagen será visible en la página web.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textoSuave,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Botones ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _elegirFuente,
                    icon: const Icon(Icons.photo_camera_rounded, size: 18),
                    label: const Text('Seleccionar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cargando ? null : _subir,
                    icon:
                        _cargando
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.blanco,
                              ),
                            )
                            : const Icon(Icons.cloud_upload_rounded, size: 18),
                    label: Text(_cargando ? 'Subiendo...' : 'Subir foto'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OpcionFuente extends StatelessWidget {
  final IconData icono;
  final String titulo, subtitulo;
  final VoidCallback onTap;
  const _OpcionFuente({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.fondoCard,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borde),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.verde.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: AppColors.verde, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.texto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textoSuave,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.borde,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}
