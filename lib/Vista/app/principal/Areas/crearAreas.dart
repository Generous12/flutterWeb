// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:proyecto_web/Controlador/Areas/areasService.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/dropdownbutton.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';
import 'package:proyecto_web/Widgets/textfield.dart';
import 'package:proyecto_web/Widgets/toastalertSo.dart';

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
  List<Map<String, dynamic>> _subareasDisponibles = [];
  List<Map<String, dynamic>> _areasDisponiblesReasignar = [];
  String? _nombreAreaPadreSeleccionada;
  String? _nombreSubareaSeleccionada;
  String? _nombreAreaReasignadaSeleccionada;
  final AreaService _areaService = AreaService();
  bool _mostrarReasignar = false;

  @override
  void initState() {
    super.initState();
    if (_idAreaPadreSeleccionada != null) {
      _cargarSubAreas(_idAreaPadreSeleccionada!);
    }
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
      _areasDisponiblesReasignar.clear();
      _nombreAreaReasignadaSeleccionada = null;
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
                    _nombreAreaPadreSeleccionada = area["nombre_area"];
                    _idSubAreaSeleccionada = null;
                    _subareasDisponibles.clear();
                    _nombreController.text = _nombreAreaPadreSeleccionada!;
                  });
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

  Future<void> _cargarSubAreas(int idAreaPadre) async {
    try {
      final resp = await _areaService.listarSubAreasPorPadre(idAreaPadre);

      final subareasDirectas = resp.where((sub) {
        final idPadre = int.tryParse(sub["id_area_padre"]?.toString() ?? "");
        return idPadre == idAreaPadre;
      }).toList();

      setState(() {
        _subareasDisponibles = subareasDirectas.cast<Map<String, dynamic>>();
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

  Future<void> _cargarAreasDisponiblesReasignar() async {
    final todasAreas = (await _areaService.listarAreasPadresGeneral(
      limit: 100,
    )).cast<Map<String, dynamic>>();

    final filtradas = todasAreas.where((a) {
      final totalSub = int.tryParse(a["total_subareas"].toString()) ?? 0;
      final totalSubSub = int.tryParse(a["total_subsubareas"].toString()) ?? 0;
      final idArea = int.tryParse(a["id_area"].toString());
      return totalSub == 0 &&
          totalSubSub == 0 &&
          idArea != _idAreaPadreSeleccionada;
    }).toList();

    setState(() {
      _areasDisponiblesReasignar = filtradas;
    });

    if (filtradas.isEmpty) {
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: "No hay áreas disponibles para reasignar",
        icono: Icons.warning_amber_rounded,
        colorFondo: Colors.black,
      );
    }
  }

  Future<void> _reasignarAreaSeleccionada(String nombreArea) async {
    final area = _areasDisponiblesReasignar.firstWhere(
      (a) => a["nombre_area"] == nombreArea,
    );

    if (_idSubAreaSeleccionada != null || _idAreaPadreSeleccionada != null) {
      final idPadre = _idSubAreaSeleccionada ?? _idAreaPadreSeleccionada;

      final resp = await _areaService.asignarAreaPadre(
        int.parse(area["id_area"].toString()),
        idPadre!,
      );

      if (!mounted) return;

      ToastUtil.showSuccess("Se asignó el área correctamente");
    } else {
      ToastUtil.showWarning("Selecciona primero un área o subárea destino");
    }
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
              label: Text(
                _idSubAreaSeleccionada != null ? " Sub Subárea" : " Subárea",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView(
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _nombreController,
                        hintText: "Ejemplo: Área de Producción",
                        label: "Crea o selecciona una Área",
                        readOnly: false,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _nombreAreaPadreSeleccionada == null
                                ? Iconsax.building_4
                                : Icons.close,
                            color: _nombreAreaPadreSeleccionada == null
                                ? Colors.grey
                                : Colors.redAccent,
                          ),
                          onPressed: () async {
                            if (_nombreAreaPadreSeleccionada != null) {
                              setState(() {
                                _nombreAreaPadreSeleccionada = null;
                                _idAreaPadreSeleccionada = null;
                                _idSubAreaSeleccionada = null;
                                _nombreSubareaSeleccionada = null;
                                _subareasDisponibles.clear();
                                _nombreController.clear();
                                _mostrarReasignar = false;
                                _areasDisponiblesReasignar.clear();
                                _nombreAreaReasignadaSeleccionada = null;
                              });
                            } else {
                              setState(() {
                                _mostrarReasignar = true;
                              });
                              _mostrarAreasPadres();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_subareasDisponibles.isNotEmpty) ...[
                        CustomDropdownSelector(
                          labelText: "Selecciona una Subárea",
                          hintText: "Selecciona una subárea",
                          value: _nombreSubareaSeleccionada,
                          items: _subareasDisponibles
                              .map<String>((s) => s["nombre_area"].toString())
                              .toList(),
                          onChanged: (selectedName) {
                            setState(() {
                              _nombreSubareaSeleccionada = selectedName;
                              final s = _subareasDisponibles.firstWhere(
                                (x) => x["nombre_area"] == selectedName,
                              );
                              _idSubAreaSeleccionada = int.parse(
                                s["id_area"].toString(),
                              );
                            });
                            _cargarSubAreas(_idAreaPadreSeleccionada!);
                          },
                          onClear: () {
                            setState(() {
                              _nombreSubareaSeleccionada = null;
                              _idSubAreaSeleccionada = null;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              if (_mostrarReasignar) ...[
                const SizedBox(height: 9),
                CustomDropdownSelector(
                  labelText: "Reasignar Área existente",
                  hintText: "Selecciona un área disponible",
                  value: _nombreAreaReasignadaSeleccionada,
                  items: _areasDisponiblesReasignar
                      .map<String>((a) => a["nombre_area"].toString())
                      .toList(),
                  onChanged: (selected) async {
                    setState(() {
                      _nombreAreaReasignadaSeleccionada = selected;
                    });
                    await _reasignarAreaSeleccionada(selected);
                  },
                  onClear: () {
                    setState(() {
                      _nombreAreaReasignadaSeleccionada = null;
                    });
                  },
                  onTap: _cargarAreasDisponiblesReasignar,
                ),
              ],
              const SizedBox(height: 15),
              Row(
                children: const [
                  Text(
                    "Crear Subáreas",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                ],
              ),
              _subareaControllers.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: const [
                          Icon(
                            Iconsax.info_circle,
                            color: Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "No hay subáreas creadas.\nPresiona '+ Subárea' arriba para añadir una nueva.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
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
                          hintText: "Nombre de subárea",
                          prefixIcon: Iconsax.diagram,
                          suffixIcon: IconButton(
                            icon: const Icon(Iconsax.trash, color: Colors.red),
                            onPressed: () {
                              final eliminado = controller.text;
                              _eliminarSubarea(index, controller);
                              SnackBarUtil.mostrarSnackBarPersonalizado(
                                context: context,
                                mensaje: "Subárea eliminada",
                                icono: Iconsax.trash,
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
                  }

                  for (final c in _subareaControllers) {
                    final nombreSub = c.text.trim();
                    if (nombreSub.isNotEmpty) {
                      await _areaService.crearSubArea(nombreSub, idPadre);
                    }
                  }

                  _limpiarCampos();
                  showCustomDialog(
                    context: context,
                    title: "Éxito",
                    message: "Área y subáreas guardadas correctamente.",
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
