import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class FotoFincaScreen extends StatefulWidget {
  final String token;

  const FotoFincaScreen({super.key, required this.token});

  @override
  State<FotoFincaScreen> createState() => _FotoFincaScreenState();
}

class _FotoFincaScreenState extends State<FotoFincaScreen> {
  File? imagen;
  bool cargando = false;

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagen = File(pickedFile.path);
      });
    }
  }

  Future<void> subirFoto() async {
    if (imagen == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecciona una imagen")));
      return;
    }

    setState(() {
      cargando = true;
    });

    // Obtener finca
    final fincaResponse = await ApiService.obtenerMiFinca(widget.token);

    if (!fincaResponse["success"]) {
      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo obtener la finca")),
      );
      return;
    }

    int fincaId = fincaResponse["data"]["id"];

    // Subir imagen
    final response = await ApiService.subirFotoFinca(
      widget.token,
      fincaId,
      imagen!,
    );

    setState(() {
      cargando = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(response["message"])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Foto de la Finca")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            imagen != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    imagen!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                : Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text("No hay imagen seleccionada"),
                  ),
                ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: seleccionarImagen,
                icon: const Icon(Icons.photo),
                label: const Text("Seleccionar Foto"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: cargando ? null : subirFoto,
                icon: const Icon(Icons.upload),
                label:
                    cargando
                        ? const Text("Subiendo...")
                        : const Text("Subir Foto"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
