import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_web/Controlador/list_Update_Component.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/dropdownbutton.dart';
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
  String? _tipoSeleccionado;

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
    _tipoSeleccionado = widget.componente.tipoNombre.isNotEmpty
        ? widget.componente.tipoNombre
        : null;
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
    String? nuevoTipoNombre;
    if (_tipoSeleccionado != null &&
        _tipoSeleccionado!.isNotEmpty &&
        _tipoSeleccionado != widget.componente.tipoNombre) {
      nuevoTipoNombre = _tipoSeleccionado;
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
        nuevoTipoNombre: nuevoTipoNombre,
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
            toolbarHeight: 48,
            title: Text(
              "Actualizar Componente",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          onTap: tieneImagen
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
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (tieneImagen)
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ZoomableImagePage(
                                                imgBytes: imgBytes,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: const Icon(
                                        Iconsax.eye,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (tieneImagen && !marcadoParaEliminar)
                                      InkWell(
                                        onTap: () => _seleccionarImagen(index),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          child: const Icon(
                                            Iconsax.edit,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 16),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (marcadoParaEliminar) {
                                            _imagenesNuevas[index] = null;
                                          } else {
                                            _imagenesNuevas[index] = "";
                                          }
                                        });
                                      },
                                      child: marcadoParaEliminar
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Text(
                                                    "Deshacer",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              child: const Icon(
                                                Iconsax.trash,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 13),
                CustomTextField(
                  controller: nombreController,
                  label: "Nombre",
                  hintText: "Nombre del componente",
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: codigoController,
                  label: "Código Inventario",
                  hintText: "Código inventario",
                  enabled: false,
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: CustomTextField(
                        controller: stockController,
                        hintText: "Ingrese la cantidad",
                        label: "Cantidad",
                        isNumeric: true,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: CustomDropdownSelector(
                        labelText: "Tipo",
                        hintText: "Selecciona...",
                        value: _tipoSeleccionado,
                        items: const ["Componentes", "Periféricos"],
                        onChanged: (value) {
                          setState(() {
                            _tipoSeleccionado = value;
                          });
                          debugPrint("Seleccionado: $_tipoSeleccionado");
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(12),
            child: LoadingOverlayButton(
              text: "Guardar cambios",
              icon: Iconsax.save_2,
              color: const Color.fromARGB(255, 0, 0, 0),
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

class ZoomableImagePage extends StatefulWidget {
  final Uint8List imgBytes;
  const ZoomableImagePage({super.key, required this.imgBytes});

  @override
  State<ZoomableImagePage> createState() => _ZoomableImagePageState();
}

class _ZoomableImagePageState extends State<ZoomableImagePage> {
  bool showCloseButton = true;

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      isFullScreen: true,
      disabled: true,
      onDismissed: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 1.0,
              maxScale: 5.0,
              constrained: true,
              child: Align(
                alignment: Alignment.center,
                child: Image.memory(widget.imgBytes, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                bottom: true,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showCloseButton ? 1.0 : 0.0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
