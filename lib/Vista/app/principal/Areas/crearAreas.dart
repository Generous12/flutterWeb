import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:proyecto_web/Controlador/areasService.dart';
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
  List<Map<String, dynamic>> _areasPadres = [];

  @override
  void initState() {
    super.initState();
    _cargarAreasPadres();
  }

  Future<void> _cargarAreasPadres() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost/api/areas_padres.php"),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _areasPadres = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print("❌ Error cargando áreas: $e");
    }
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
                    _idAreaPadreSeleccionada = area["id_area"];
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
        title: const Text("Crear Área"),
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
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Campo Área padre
              CustomTextField(
                controller: _nombreController,
                hintText: "Agregar el Área",
                label: "Nombre del Área",
                prefixIcon: Iconsax.building,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 20),
              ..._subareaControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;

                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (_) {
                    final eliminado = controller.text;

                    _eliminarSubarea(index, controller);

                    SnackBarUtil.mostrarSnackBarPersonalizado(
                      context: context,
                      mensaje: "Subárea eliminada",
                      icono: Icons.delete,
                      colorFondo: const Color.fromARGB(255, 0, 0, 0),
                      textoAccion: "Deshacer",
                      onAccion: () {
                        print("El usuario deshizo la acción");
                      },
                    );
                  },
                  background: Container(
                    color: Colors.red.shade600,
                    padding: const EdgeInsets.only(left: 16),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: CustomTextField(
                    controller: controller,
                    label: "Subárea ${index + 1}",
                    hintText: "Escribir subárea",
                    prefixIcon: Iconsax.diagram,
                  ),
                );
              }),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Iconsax.tick_circle, color: Colors.white),
                label: const Text(
                  "Guardar Área",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
