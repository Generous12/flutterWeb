import 'package:flutter/material.dart';

class ReporteComponentePage extends StatefulWidget {
  const ReporteComponentePage({super.key});

  @override
  State<ReporteComponentePage> createState() => _ReporteComponentePageState();
}

class _ReporteComponentePageState extends State<ReporteComponentePage> {
  String? selectedComponente;
  String? tipoReporte;
  final TextEditingController descripcionController = TextEditingController();

  // 🔹 Datos de prueba
  final List<String> componentes = [
    "Fuente 500W",
    "Placa Madre ASUS",
    "Monitor LG 22''",
  ];
  final List<String> tipos = ["Incidencia", "Mantenimiento", "Reparacion"];

  void registrarReporte() {
    if (selectedComponente == null ||
        tipoReporte == null ||
        descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "📋 Reporte registrado para $selectedComponente (${tipoReporte!})",
        ),
      ),
    );

    descripcionController.clear();
    setState(() {
      selectedComponente = null;
      tipoReporte = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte de Componente"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Componente"),
              value: selectedComponente,
              items: componentes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedComponente = value),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Tipo de Reporte"),
              value: tipoReporte,
              items: tipos
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => tipoReporte = value),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: "Descripción del problema o reparación",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: registrarReporte,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Registrar Reporte"),
            ),
          ],
        ),
      ),
    );
  }
}
