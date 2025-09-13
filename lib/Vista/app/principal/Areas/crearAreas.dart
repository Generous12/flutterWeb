import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CrearAreaScreen extends StatefulWidget {
  const CrearAreaScreen({super.key});

  @override
  State<CrearAreaScreen> createState() => _CrearAreaScreenState();
}

class _CrearAreaScreenState extends State<CrearAreaScreen> {
  final TextEditingController _nombreController = TextEditingController();

  // Lista dinámica de subáreas
  List<TextEditingController> _subareaControllers = [];

  // Control para buscar un área padre existente
  final TextEditingController _buscarPadreController = TextEditingController();
  int? _idAreaPadreSeleccionada; // se llena al buscar/seleccionar un padre

  void _guardarArea() {
    String nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre del área es obligatorio")),
      );
      return;
    }

    // Recoger subáreas
    List<String> subareas = _subareaControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    // Simulación del payload a backend
    final data = {
      "nombre_area": nombre,
      "id_area_padre": _idAreaPadreSeleccionada, // null si es principal
      "subareas": subareas,
    };

    print("➡️ Guardando: $data");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Área '$nombre' creada correctamente")),
    );

    // Reset
    _nombreController.clear();
    _buscarPadreController.clear();
    _subareaControllers.clear();
    setState(() => _idAreaPadreSeleccionada = null);
  }

  void _agregarSubarea() {
    setState(() {
      _subareaControllers.add(TextEditingController());
    });
  }

  void _eliminarSubarea(int index, TextEditingController controller) {
    String eliminado = controller.text;
    setState(() {
      _subareaControllers.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Subárea eliminada"),
        action: SnackBarAction(
          label: "Deshacer",
          onPressed: () {
            setState(() {
              _subareaControllers.insert(index, controller);
            });
          },
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
      ),
      floatingActionButton: _subareaControllers.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: _agregarSubarea,
              child: const Icon(Iconsax.add, color: Colors.white),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Nueva Área",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Nombre del área principal
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre del Área",
                prefixIcon: Icon(Iconsax.tag, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),

            // Campo para buscar área padre existente
            TextField(
              controller: _buscarPadreController,
              decoration: const InputDecoration(
                labelText: "Buscar Área Padre (opcional)",
                prefixIcon: Icon(Iconsax.search_normal, color: Colors.blue),
              ),
              onSubmitted: (value) {
                // Aquí deberías llamar a tu backend para buscar
                // Simulación: si escriben "Informática", id=1
                if (value.toLowerCase() == "informática") {
                  setState(() => _idAreaPadreSeleccionada = 1);
                } else {
                  setState(() => _idAreaPadreSeleccionada = null);
                }
              },
            ),
            const SizedBox(height: 20),

            // Botón para habilitar subáreas
            ElevatedButton.icon(
              onPressed: _agregarSubarea,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Iconsax.add_circle, color: Colors.white),
              label: const Text(
                "Crear Subárea",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),

            // Lista de subáreas dinámicas
            ..._subareaControllers.asMap().entries.map((entry) {
              int index = entry.key;
              TextEditingController controller = entry.value;

              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.startToEnd,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _eliminarSubarea(index, controller),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Subárea ${index + 1}",
                      prefixIcon: const Icon(
                        Iconsax.diagram,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Guardar
            ElevatedButton.icon(
              onPressed: _guardarArea,
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
    );
  }
}
