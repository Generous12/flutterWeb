import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
  bool isLoading = false;

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

    nombreController.addListener(() {
      final nombre = nombreController.text;
      if (nombre.isNotEmpty) {
        codigoController.text = generarCodigoInventario(nombre);
      } else {
        codigoController.clear();
      }
    });
  }

  bool get huboCambio {
    if (nombreController.text != widget.componente.nombreTipo ||
        codigoController.text != widget.componente.codigoInventario ||
        stockController.text != widget.componente.cantidad.toString()) {
      return true;
    }
    for (var img in _imagenesNuevas) {
      if (img != null) return true;
    }
    return false;
  }

  Future<bool> _onWillPop() async {
    if (huboCambio) {
      final salir = await showCustomDialog(
        context: context,
        title: "Cambios sin guardar",
        message: "Tienes cambios sin guardar. ¿Deseas salir de todas formas?",
        confirmButtonText: "Salir",
        cancelButtonText: "Cancelar",
      );
      return salir ?? false;
    }
    return true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    codigoController.dispose();
    stockController.dispose();
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

  String generarCodigoInventario(String nombre) {
    final cleanName = nombre.replaceAll(' ', '').toUpperCase();
    final prefix = cleanName.length >= 3
        ? cleanName.substring(0, 3)
        : cleanName;

    final now = DateTime.now();
    final datePart =
        "${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    final randomNumber = (100 + Random().nextInt(900)).toString();

    return "$prefix-$datePart-$randomNumber";
  }

  Future<void> _guardarCambios() async {
    final identificador = widget.componente.codigoInventario;
    final service = ComponenteUpdateService();
    bool huboCambio = false;

    int? cantidadActualizada;
    if (stockController.text.isNotEmpty &&
        stockController.text != widget.componente.cantidad.toString()) {
      cantidadActualizada =
          int.tryParse(stockController.text) ?? widget.componente.cantidad;
      huboCambio = true;
    }

    String? nuevoCodigo;
    if (codigoController.text.isNotEmpty &&
        codigoController.text != widget.componente.codigoInventario) {
      nuevoCodigo = codigoController.text;
      huboCambio = true;
    }

    String? nuevoNombreTipo;
    if (nombreController.text.isNotEmpty &&
        nombreController.text != widget.componente.nombreTipo) {
      nuevoNombreTipo = nombreController.text;
      huboCambio = true;
    }

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
        return nuevo;
      }
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
      "✅ Payload a enviar:\n identificador=$identificador\n cantidad=$cantidadActualizada\n nuevoCodigo=$nuevoCodigo\n nuevoNombreTipo=$nuevoNombreTipo\n imagenes=[${imagenesFinal.map((e) => e == null ? 'NO TOCAR' : (e.isEmpty ? 'ELIMINAR' : 'BASE64(${e.length})')).join(', ')}]",
    );

    setState(() => isLoading = true);
    try {
      final success = await service.actualizarComponente(
        identificador: identificador,
        cantidad: cantidadActualizada,
        imagenesNuevas: imagenesFinal,
        nuevoCodigo: nuevoCodigo,
        nuevoNombreTipo: nuevoNombreTipo,
      );

      print("✅ Respuesta del backend: $success");
      setState(() => isLoading = false);

      if (success) {
        await showCustomDialog(
          context: context,
          title: "Éxito",
          message: "Se actualizó correctamente",
          confirmButtonText: "Cerrar",
          onConfirm: () {
            Navigator.of(context).pop(true);
          },
        );
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Actualizar Componente",
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

                    final tieneImagen =
                        imgBytes != null && _imagenesNuevas[index] != "";
                    final marcadoParaEliminar = _imagenesNuevas[index] == "";

                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: marcadoParaEliminar
                              ? null
                              : () => _seleccionarImagen(index),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: marcadoParaEliminar
                                    ? Colors.redAccent
                                    : Colors.black26,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: tieneImagen
                                  ? Image.memory(
                                      imgBytes,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                  : marcadoParaEliminar
                                  ? null
                                  : const Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 50,
                                        color: Colors.black45,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        if (tieneImagen || marcadoParaEliminar)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (marcadoParaEliminar) {
                                    _imagenesNuevas[index] = null;
                                  } else {
                                    _imagenesNuevas[index] = "";
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: marcadoParaEliminar
                                      ? Colors.green
                                      : Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: marcadoParaEliminar
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
                        if (tieneImagen && !marcadoParaEliminar)
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
                        if (marcadoParaEliminar)
                          Positioned.fill(
                            child: Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 6,
                                  shadowColor: Colors.black45,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _imagenesNuevas[index] = null;
                                  });
                                },
                                child: const Text(
                                  "Deshacer",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
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
                  enabled: false, // Inhabilitado para edición manual
                ),

                const SizedBox(height: 12),
                CustomTextField(
                  controller: stockController,
                  label: "Stock",
                  hintText: "Cantidad",
                  isNumeric: true,
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(12),
            child: LoadingOverlayButton(
              text: "Guardar cambios",
              icon: Iconsax.save_2,
              color: Colors.blue,
              onPressedLogic: _guardarCambios,
            ),
          ),
        ),
      ),
    );
  }
}

extension ComponenteUpdateExtension on ComponenteUpdate {
  Uint8List? imagenBytes(int index) {
    if (index < 0 || index >= imagenesBase64.length) return null;

    final String? raw = imagenesBase64[index];
    if (raw == null || raw.isEmpty) return null;

    try {
      String normalized = raw.contains(",") ? raw.split(",").last : raw;
      normalized = normalized.replaceAll('\n', '').trim();
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
