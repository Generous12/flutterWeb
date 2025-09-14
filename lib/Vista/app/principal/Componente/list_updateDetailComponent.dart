import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Controlador/list_Update_Component.dart';

class ComponenteDetail extends StatelessWidget {
  final ComponenteUpdate componente;

  const ComponenteDetail({Key? key, required this.componente})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(componente.nombreTipo),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal o carrusel
            if (componente.imagenesBase64.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: componente.imagenesBase64.length,
                  itemBuilder: (context, index) {
                    final imgBytes = componente.imagenBytes(index);
                    return Hero(
                      tag: 'imagen_${componente.id}_$index',
                      child: imgBytes != null
                          ? Image.memory(imgBytes, fit: BoxFit.cover)
                          : const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.black54,
                            ),
                    );
                  },
                ),
              )
            else
              const Icon(Iconsax.folder5, size: 100, color: Colors.black54),
            const SizedBox(height: 16),

            // Información básica
            Text(
              'Código de Inventario: ${componente.codigoInventario}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Stock: ${componente.cantidad}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            Text(
              'Nombre del Tipo: ${componente.nombreTipo}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Botón para cerrar
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.arrow_left_2),
                label: const Text('Volver'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extensión para decodificar Base64
extension ComponenteUpdateExtension on ComponenteUpdate {
  Uint8List? imagenBytes(int index) {
    final imgs = imagenesBase64;
    if (index >= 0 && index < imgs.length && imgs[index].isNotEmpty) {
      try {
        return base64Decode(imgs[index]);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
