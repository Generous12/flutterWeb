import 'package:flutter/material.dart';

class AsignarCasePage extends StatefulWidget {
  const AsignarCasePage({super.key});

  @override
  State<AsignarCasePage> createState() => _AsignarCasePageState();
}

class _AsignarCasePageState extends State<AsignarCasePage> {
  String? selectedCase;
  String? selectedArea;

  // 🔹 Datos de prueba
  final List<String> cases = ["CASE-001", "CASE-002", "CASE-003"];
  final List<String> areas = ["Administración", "Enfermería", "Laboratorio"];

  void asignarCase() {
    if (selectedCase == null || selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un Case y un Área")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "✅ $selectedCase asignado correctamente al área $selectedArea.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asignar Case"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Seleccionar Case"),
              value: selectedCase,
              items: cases
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedCase = value),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Seleccionar Área"),
              value: selectedArea,
              items: areas
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedArea = value),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: asignarCase,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Asignar"),
            ),
          ],
        ),
      ),
    );
  }
}
