import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_web/Controlador/list_Update_Component.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/textfield.dart';

class ComponenteDetail extends StatefulWidget {
  final ComponenteUpdate componente;

  const ComponenteDetail({Key? key, required this.componente})
    : super(key: key);

  @override
  State<ComponenteDetail> createState() => _ComponenteDetailState();
}

class _ComponenteDetailState extends State<ComponenteDetail> {
  late TextEditingController nombreController;
  late TextEditingController codigoController;
  late TextEditingController stockController;
  late TextEditingController tipoController;

  // Imágenes nuevas (solo reemplazan si usuario selecciona)
  List<String?> _imagenesNuevas = List.filled(4, null);

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(
      text: widget.componente.nombreTipo,
    );
    codigoController = TextEditingController(
      text: widget.componente.codigoInventario,
    );
    stockController = TextEditingController(
      text: widget.componente.cantidad.toString(),
    );
    tipoController = TextEditingController(text: widget.componente.nombreTipo);
  }

  @override
  void dispose() {
    nombreController.dispose();
    codigoController.dispose();
    stockController.dispose();
    tipoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(int index) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Seleccionar origen de la imagen"),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text("Cámara"),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo),
            label: const Text("Galería"),
          ),
        ],
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Editar imagen',
            toolbarColor: const Color(0xFFA30000),
            toolbarWidgetColor: Colors.white,
          ),
          IOSUiSettings(title: 'Editar imagen'),
        ],
      );

      if (croppedFile != null) {
        final bytes = await File(croppedFile.path).readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() {
          _imagenesNuevas[index] = base64Image;
        });
      }
    }
  }

  Future<void> _guardarCambios() async {
    final identificador = widget.componente.codigoInventario;
    final service = ComponenteUpdateService();
    bool huboCambio = false;

    // 1️⃣ Verificar cambio de stock
    int? cantidadActualizada;
    if (stockController.text.isNotEmpty &&
        stockController.text != widget.componente.cantidad.toString()) {
      cantidadActualizada =
          int.tryParse(stockController.text) ?? widget.componente.cantidad;
      huboCambio = true;
    }

    // 2️⃣ Preparar imágenes nuevas: solo enviar las que cambiaron
    List<String?> imagenesFinal = List.generate(4, (i) {
      if (_imagenesNuevas[i] != null && _imagenesNuevas[i]!.isNotEmpty) {
        huboCambio = true;
        print(
          "📸 Imagen nueva en slot $i: ${_imagenesNuevas[i]!.substring(0, 50)}...",
        );
        return _imagenesNuevas[i]!; // enviar solo imagen nueva
      }
      return null; // no tocar la existente
    });

    if (!huboCambio) {
      showCustomDialog(
        context: context,
        title: "Espera",
        message: "No hubo ningún cambio para registrar",
        confirmButtonText: "Cerrar",
      );
      return;
    }

    print(
      "Hubo cambio: $huboCambio, Payload a enviar: identificador=$identificador, cantidad=$cantidadActualizada, imagenes=[${imagenesFinal.map((e) => e != null ? e.substring(0, 30) : 'null').join(', ')}]",
    );

    try {
      final success = await service.actualizarComponente(
        identificador: identificador,
        cantidad: cantidadActualizada,
        imagenes: imagenesFinal,
      );

      print("✅ Respuesta del backend: $success");

      if (success) {
        showCustomDialog(
          context: context,
          title: "Éxito",
          message: "Se actualizó correctamente",
          confirmButtonText: "Cerrar",
        );
        Navigator.pop(context);
      } else {
        showCustomDialog(
          context: context,
          title: "Error",
          message: "Hubo un error al actualizar",
          confirmButtonText: "Cerrar",
        );
      }
    } catch (e) {
      print("❌ Error en _guardarCambios: $e");
      showCustomDialog(
        context: context,
        title: "Error",
        message: "Excepción al actualizar: $e",
        confirmButtonText: "Cerrar",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final componente = widget.componente;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            componente.nombreTipo,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Imágenes del componente:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final imgBytes = _imagenesNuevas[index] != null
                      ? base64Decode(_imagenesNuevas[index]!)
                      : componente.imagenBytes(index);

                  return GestureDetector(
                    onTap: () => _seleccionarImagen(index),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: imgBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(imgBytes, fit: BoxFit.cover),
                            )
                          : const Center(
                              child: Icon(
                                Iconsax.image,
                                size: 50,
                                color: Colors.black45,
                              ),
                            ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              CustomTextField(
                controller: nombreController,
                label: "Nombre",
                hintText: "Nombre del componente",
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: codigoController,
                label: "Código Inventario",
                hintText: "Código inventario",
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: stockController,
                label: "Stock",
                hintText: "Cantidad",
                isNumeric: true,
              ),
              const SizedBox(height: 20),

              LoadingOverlayButton(
                text: "Guardar cambios",
                icon: Iconsax.save_2,
                color: Colors.blue,
                onPressedLogic: _guardarCambios,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extensión para decodificar imágenes con padding seguro
extension ComponenteUpdateExtension on ComponenteUpdate {
  Uint8List? imagenBytes(int index) {
    final imgs = imagenesBase64;
    if (index >= 0 && index < imgs.length && imgs[index].isNotEmpty) {
      try {
        String normalized = imgs[index];
        final mod = normalized.length % 4;
        if (mod > 0) {
          normalized = normalized.padRight(normalized.length + (4 - mod), '=');
        }
        return base64Decode(normalized);
      } catch (e) {
        print('❌ Error decodificando imagen $index: $e');
        return null;
      }
    }
    return null;
  }
}
