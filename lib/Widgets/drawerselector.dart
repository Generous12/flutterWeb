import 'package:flutter/material.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/crearComponente.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Menú",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Inicio"),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              // Aquí navegas a Inicio
            },
          ),
          ListTile(
            leading: const Icon(Icons.computer),
            title: const Text("Componentes"),
            onTap: () {
              navegarConSlideDerecha(context, FlujoCrearComponente());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () {
              Navigator.pop(context);
              // Aquí navegas a Configuración
            },
          ),
        ],
      ),
    );
  }
}
