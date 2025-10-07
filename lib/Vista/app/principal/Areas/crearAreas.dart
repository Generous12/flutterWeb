import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:proyecto_web/Controlador/areasService.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';
import 'package:proyecto_web/Widgets/textfield.dart';

class CrearAreaScreen extends StatefulWidget {
  const CrearAreaScreen({super.key});

  @override
  State<CrearAreaScreen> createState() => _CrearAreaScreenState();
}

class _CrearAreaScreenState extends State<CrearAreaScreen> {
  final TextEditingController _nombreController = TextEditingController();
  List<TextEditingController> _subareaControllers = [];

  int? _idAreaPadreSeleccionada;
  int? _idSubAreaSeleccionada;
  List<dynamic> _subareasDisponibles = [];

  final AreaService _areaService = AreaService();

  @override
  void initState() {
    super.initState();
  }

  void _limpiarCampos() {
    setState(() {
      _nombreController.clear();
      for (var controller in _subareaControllers) {
        controller.dispose();
      }
      _subareaControllers.clear();
      _idAreaPadreSeleccionada = null;
      _idSubAreaSeleccionada = null;
      _subareasDisponibles.clear();
    });
  }

  void _agregarSubarea() {
    setState(() {
      _subareaControllers.add(TextEditingController());
    });
  }

  void _eliminarSubarea(int index, TextEditingController controller) {
    setState(() {
      _subareaControllers.removeAt(index);
    });
  }

  /// 🔹 Mostrar lista de áreas padres
  void _mostrarAreasPadres() async {
    final areas = await _areaService.listarAreasPadres();

    if (areas.isEmpty) {
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: "No hay áreas padres registradas",
        icono: Icons.warning_amber_rounded,
        colorFondo: Colors.black,
      );
      return;
    }

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => Material(
        child: SafeArea(
          child: ListView.builder(
            itemCount: areas.length,
            itemBuilder: (context, index) {
              final area = areas[index];
              return ListTile(
                leading: const Icon(Iconsax.building),
                title: Text(area["nombre_area"]),
                onTap: () async {
                  setState(() {
                    _idAreaPadreSeleccionada = int.parse(
                      area["id_area"].toString(),
                    );
                    _nombreController.text = area["nombre_area"] ?? "";
                    _idSubAreaSeleccionada = null;
                    _subareasDisponibles.clear();
                  });

                  // 🔹 Cargar subáreas del área padre seleccionada
                  await _cargarSubAreas(_idAreaPadreSeleccionada!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// 🔹 Cargar subáreas de un área padre
  Future<void> _cargarSubAreas(int idAreaPadre) async {
    try {
      final resp = await _areaService.listarSubAreasPorPadre(idAreaPadre);
      setState(() {
        _subareasDisponibles = resp;
      });
    } catch (e) {
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: "Error al cargar subáreas",
        icono: Icons.error,
        colorFondo: Colors.black,
      );
    }
  }

  Future<void> _reasignarAreaExistente() async {
    final todasAreas = await _areaService.listarAreasPadresGeneral(limit: 100);

    if (!mounted) return;

    final areasDisponibles = todasAreas.where((a) {
      final totalSub = int.tryParse(a["total_subareas"].toString()) ?? 0;
      final totalSubSub = int.tryParse(a["total_subsubareas"].toString()) ?? 0;
      return totalSub == 0 && totalSubSub == 0;
    }).toList();

    if (areasDisponibles.isEmpty) {
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: "No hay áreas disponibles para reasignar",
        icono: Icons.warning_amber_rounded,
        colorFondo: Colors.black,
      );
      return;
    }

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => Material(
        child: SafeArea(
          child: ListView.builder(
            itemCount: areasDisponibles.length,
            itemBuilder: (context, index) {
              final area = areasDisponibles[index];
              return ListTile(
                leading: const Icon(Iconsax.diagram),
                title: Text(area["nombre_area"]),
                subtitle: Text("ID: ${area["id_area"]}"),
                onTap: () async {
                  if (_idSubAreaSeleccionada != null ||
                      _idAreaPadreSeleccionada != null) {
                    final idPadre =
                        _idSubAreaSeleccionada ?? _idAreaPadreSeleccionada;

                    final resp = await _areaService.asignarAreaPadre(
                      int.parse(area["id_area"].toString()),
                      idPadre!,
                    );

                    if (!mounted) return;

                    showCustomDialog(
                      context: context,
                      title: resp["success"] ? "Éxito" : "Error",
                      message: resp["message"],
                      confirmButtonText: "Cerrar",
                      onConfirm: () {
                        Navigator.of(context).pop();
                      },
                    );
                  } else {
                    SnackBarUtil.mostrarSnackBarPersonalizado(
                      context: context,
                      mensaje: "Selecciona primero un área o subárea destino",
                      icono: Icons.warning_amber_rounded,
                      colorFondo: Colors.black,
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 48,
          title: const Text("Crear Área", style: TextStyle(fontSize: 19)),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            TextButton.icon(
              onPressed: _agregarSubarea,
              icon: const Icon(Iconsax.add, color: Colors.white),
              label: const Text(
                "Subárea",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: ListView(
            children: [
              const SizedBox(height: 5),

              ListTile(
                leading: const Icon(Iconsax.building),
                title: Text(
                  _idAreaPadreSeleccionada == null
                      ? "Seleccionar Área Padre (opcional)"
                      : "Área Padre ID: $_idAreaPadreSeleccionada",
                ),
                trailing: const Icon(Iconsax.arrow_down_1),
                onTap: _mostrarAreasPadres,
              ),

              if (_subareasDisponibles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "Seleccionar Subárea (opcional)",
                        border: OutlineInputBorder(),
                      ),
                      value: _idSubAreaSeleccionada,
                      items: _subareasDisponibles
                          .map<DropdownMenuItem<int>>(
                            (subarea) => DropdownMenuItem(
                              value: int.parse(subarea["id_area"].toString()),
                              child: Text(subarea["nombre_area"]),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _idSubAreaSeleccionada = value;
                        });
                      },
                    ),
                  ),
                ),
              ListTile(
                leading: const Icon(
                  Iconsax.refresh_circle,
                  color: Colors.black,
                ),
                title: const Text("Reasignar área existente"),
                trailing: const Icon(Iconsax.arrow_down_1),
                onTap: _reasignarAreaExistente,
              ),

              CustomTextField(
                controller: _nombreController,
                hintText: "Agregar el Área",
                label: "Nombre del Área",
                prefixIcon: Iconsax.building,
              ),

              const SizedBox(height: 16),
              Row(
                children: const [
                  Text(
                    "Crear o Asignar Subáreas",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  SizedBox(width: 8),
                ],
              ),

              _subareaControllers.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "No hay ninguna subárea creada.\nEmpieza a crearla presionando\n+ Subárea",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: _subareaControllers.asMap().entries.map((
                        entry,
                      ) {
                        int index = entry.key;
                        TextEditingController controller = entry.value;

                        return CustomTextField(
                          controller: controller,
                          label: "Subárea ${index + 1}",
                          hintText: "Escribir subárea",
                          prefixIcon: Iconsax.diagram,
                          suffixIcon: IconButton(
                            icon: const Icon(Iconsax.trash, color: Colors.red),
                            onPressed: () {
                              final eliminado = controller.text;
                              _eliminarSubarea(index, controller);

                              SnackBarUtil.mostrarSnackBarPersonalizado(
                                context: context,
                                mensaje: "Subárea eliminada",
                                icono: Icons.delete,
                                colorFondo: Colors.black,
                                textoAccion: "Deshacer",
                                onAccion: () {
                                  setState(() {
                                    _subareaControllers.insert(
                                      index,
                                      TextEditingController(text: eliminado),
                                    );
                                  });
                                },
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
            child: LoadingOverlayButtonHabilitar(
              text: "Guardar Área",
              enabled: true,
              onPressedLogic: () async {
                final confirmado = await showCustomDialog(
                  context: context,
                  title: "Confirmar",
                  message: "¿Deseas guardar el área?",
                  confirmButtonText: "Sí",
                  cancelButtonText: "No",
                );

                if (!confirmado) return;

                try {
                  int idPadre;

                  if (_idAreaPadreSeleccionada != null) {
                    idPadre =
                        _idSubAreaSeleccionada ?? _idAreaPadreSeleccionada!;
                    print("🟢 Creando bajo ID padre: $idPadre");
                  } else {
                    final respPadre = await _areaService.crearAreaPadre(
                      _nombreController.text.trim(),
                    );
                    if (respPadre["success"] != true) {
                      showCustomDialog(
                        context: context,
                        title: "Error",
                        message:
                            respPadre["message"] ??
                            "No se pudo crear el área padre",
                        confirmButtonText: "Cerrar",
                      );
                      return;
                    }
                    idPadre = int.parse(respPadre["id_area"].toString());
                    print("✅ Área padre creada con ID: $idPadre");
                  }

                  for (final controller in _subareaControllers) {
                    final nombreSub = controller.text.trim();
                    if (nombreSub.isNotEmpty) {
                      final respSub = await _areaService.crearSubArea(
                        nombreSub,
                        idPadre,
                      );
                      if (respSub["success"] == true) {
                        print("   ↳ Subárea creada: $nombreSub");
                      } else {
                        print(
                          "⚠️ Error al crear subárea: ${respSub["message"]}",
                        );
                      }
                    }
                  }

                  _limpiarCampos();
                  showCustomDialog(
                    context: context,
                    title: "Éxito",
                    message: "Se registró correctamente",
                    confirmButtonText: "Cerrar",
                  );
                } catch (e) {
                  showCustomDialog(
                    context: context,
                    title: "Error",
                    message: "Excepción: $e",
                    confirmButtonText: "Cerrar",
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
