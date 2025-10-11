import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Provider/usuarioautenticado.dart';
import 'package:proyecto_web/Controlador/Componentes/list_Update_Component.dart';
import 'package:proyecto_web/Widgets/ZoomImage.dart';
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

  bool isLoading = false;
  String? _tipoSeleccionado;
  String? _estadoseleccionado;

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

    _tipoSeleccionado = widget.componente.tipoNombre.isNotEmpty
        ? widget.componente.tipoNombre
        : null;
    _estadoseleccionado = widget.componente.estado.isNotEmpty
        ? widget.componente.estado
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
        _estadoseleccionado != widget.componente.estado ||
        _tipoSeleccionado != widget.componente.tipoNombre) {
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

  final List<String> _estadosPrincipales = [
    "Disponible",
    "Mantenimiento",
    "En uso",
  ];

  final List<String> _otrosEstados = ["Dañado", "Arreglado"];

  void _mostrarModalEstados(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "Seleccionar estado",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ..._estadosPrincipales.map(
                (estado) => ListTile(
                  title: Text(estado),
                  trailing: _estadoseleccionado == estado
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      _estadoseleccionado = estado;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),

              const Divider(height: 10, thickness: 1),
              ..._otrosEstados.map(
                (estado) => ListTile(
                  title: Text(estado),
                  trailing: _estadoseleccionado == estado
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      _estadoseleccionado = estado;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    codigoController.dispose();
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

    String? nuevoEstado;
    if (_estadoseleccionado != null &&
        _estadoseleccionado!.isNotEmpty &&
        _estadoseleccionado != widget.componente.estado) {
      nuevoEstado = _estadoseleccionado;
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
        } else {}
        return nuevo;
      }

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

    setState(() => isLoading = true);
    try {
      final usuarioProvider = Provider.of<UsuarioProvider>(
        context,
        listen: false,
      );

      final success = await service.actualizarComponente(
        identificador: identificador,
        nuevoestado: nuevoEstado,
        imagenesNuevas: imagenesFinal,
        nuevoCodigo: nuevoCodigo,
        nuevoNombreTipo: nuevoNombreTipo,
        nuevoTipoNombre: nuevoTipoNombre,
        idUsuarioCreador: usuarioProvider.idUsuario ?? "",
        rolCreador: usuarioProvider.rol ?? "",
      );

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
            padding: const EdgeInsets.fromLTRB(7, 10, 7, 10),
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
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () => _mostrarModalEstados(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _estadoseleccionado ?? "Seleccione el estado",
                                style: TextStyle(
                                  color: _estadoseleccionado == null
                                      ? Colors.grey
                                      : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
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

                const SizedBox(height: 10),
                CustomTextField(
                  controller: codigoController,
                  label: "Código Inventario",
                  hintText: "Código inventario",
                  enabled: false,
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
      return null;
    }
  }
}
