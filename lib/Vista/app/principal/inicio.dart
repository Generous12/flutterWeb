import 'package:flutter/material.dart';
import 'package:proyecto_web/Widgets/drawerselector.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicio")),
      drawer: const DrawerMenu(),
      body: const Center(
        child: Text(
          "👋 Bienvenido al sistema de gestión de componentes",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
