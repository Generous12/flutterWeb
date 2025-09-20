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

    // 2️⃣ Preparar imágenes nuevas / eliminación: enviar "" para eliminar
    List<String?> imagenesFinal = List.generate(4, (i) {
      final nuevo = _imagenesNuevas[i];

      if (nuevo != null) {
        huboCambio = true;

        if (nuevo.isEmpty) {
          print("📸 Imagen slot $i: ELIMINAR");
        } else {
          print(
            "📸 Imagen slot $i: NUEVA/ACTUALIZADA (base64, len=${nuevo.length})",
          );
        }

        return nuevo; // "" para eliminar, base64 para actualizar/agregar
      }

      // null → mantener la existente
      print("📸 Imagen slot $i: NO TOCAR");
      return null;
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
      "✅ Payload a enviar:\n identificador=$identificador\n cantidad=$cantidadActualizada\n imagenes=[${imagenesFinal.map((e) => e == null ? 'NO TOCAR' : (e.isEmpty ? 'ELIMINAR' : 'BASE64(${e.length})')).join(', ')}]",
    );

    try {
      final success = await service.actualizarComponente(
        identificador: identificador,
        cantidad: cantidadActualizada,
        imagenesNuevas: imagenesFinal,
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
                  final imgBytes =
                      (_imagenesNuevas[index] != null &&
                          _imagenesNuevas[index] != "")
                      ? base64Decode(_imagenesNuevas[index]!)
                      : componente.imagenBytes(index);

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _seleccionarImagen(index),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              (imgBytes != null && _imagenesNuevas[index] != "")
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    imgBytes,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                              : Center(
                                  child: _imagenesNuevas[index] == ""
                                      ? const Icon(
                                          Iconsax.trash,
                                          size: 50,
                                          color: Colors.red,
                                        )
                                      : const Icon(
                                          Iconsax.image,
                                          size: 50,
                                          color: Colors.black45,
                                        ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (_imagenesNuevas[index] == "") {
                                _imagenesNuevas[index] = null; // restaurar
                              } else {
                                _imagenesNuevas[index] =
                                    ""; // marcar para eliminar
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _imagenesNuevas[index] == ""
                                  ? Colors.green
                                  : Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: _imagenesNuevas[index] == ""
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ),
                      if (imgBytes != null && _imagenesNuevas[index] != "")
                        Positioned(
                          top: 4,
                          left: 4,
                          child: InkWell(
                            onTap: () => _seleccionarImagen(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
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

extension ComponenteUpdateExtension on ComponenteUpdate {
  Uint8List? imagenBytes(int index) {
    if (index < 0 || index >= imagenesBase64.length) return null;

    final String? raw = imagenesBase64[index]; // 🔹 Puede ser null
    if (raw == null || raw.isEmpty) return null;

    try {
      // Quitar cabecera tipo "data:image/png;base64,..."
      String normalized = raw.contains(",") ? raw.split(",").last : raw;

      // Limpiar saltos de línea y espacios
      normalized = normalized.replaceAll('\n', '').trim();

      // Rellenar con '=' para múltiplo de 4
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
}
