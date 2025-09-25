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
    final service = AreaService();
    final areas = await service.listarAreasPadres();

    if (areas.isEmpty) {
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: "No hay áreas padres registradas",
        icono: Icons.warning_amber_rounded,
        colorFondo: const Color.fromARGB(255, 0, 0, 0),
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
                onTap: () {
                  setState(() {
                    _idAreaPadreSeleccionada = int.parse(
                      area["id_area"].toString(),
                    );
                    _nombreController.text = area["nombre_area"] ?? "";
                  });
                  Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text("Crear Área", style: TextStyle(fontSize: 19)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _agregarSubarea,
            icon: const Icon(Iconsax.add, color: Colors.white),
            label: const Text("Subárea", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: ListView(
            children: [
              const SizedBox(height: 5),

              ListTile(
                leading: const Icon(Iconsax.building),
                title: Text(
                  _idAreaPadreSeleccionada == null
                      ? "Asignar Subáreas al Área Padre (opcional)"
                      : "Área Padre ID: $_idAreaPadreSeleccionada",
                ),
                trailing: const Icon(Iconsax.arrow_down_1),
                onTap: _mostrarAreasPadres,
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
          child: LoadingOverlayButtonHabilitar(
            text: "Guardar Área",
            enabled: true,
            onPressedLogic: () async {
              print("🖱️ Botón presionado, mostrando diálogo de confirmación");

              final confirmado = await showCustomDialog(
                context: context,
                title: "Confirmar",
                message: "¿Deseas guardar el área?",
                confirmButtonText: "Sí",
                cancelButtonText: "No",
              );

              if (!confirmado) {
                print("⏹️ Usuario canceló la acción");
                return;
              }

              try {
                final areaService = AreaService();
                int idAreaPadre;
                if (_idAreaPadreSeleccionada != null) {
                  idAreaPadre = _idAreaPadreSeleccionada!;
                  print(
                    "🟢 Reusando área padre existente con ID: $idAreaPadre",
                  );
                } else {
                  final respPadre = await areaService.crearAreaPadre(
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

                  idAreaPadre = int.parse(respPadre["id_area"].toString());
                  print("✅ Área padre creada con ID: $idAreaPadre");
                }

                // 🔹 Crear subáreas
                for (final controller in _subareaControllers) {
                  final nombreSub = controller.text.trim();
                  if (nombreSub.isNotEmpty) {
                    final respSub = await areaService.crearSubArea(
                      nombreSub,
                      idAreaPadre,
                    );
                    if (respSub["success"] == true) {
                      print("   ↳ Subárea creada: $nombreSub ✅");
                    } else {
                      print(
                        "   ⚠️ Error al crear subárea: ${respSub["message"]}",
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
    );
  }
}
