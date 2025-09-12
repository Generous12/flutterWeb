import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/crearAreas.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/crearComponente.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Menú",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.home, color: Colors.black),
              title: const Text(
                "Inicio",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.cpu, color: Colors.black),
              title: const Text(
                "Componentes",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                navegarConSlideDerecha(context, FlujoCrearComponente());
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.setting_2, color: Colors.black),
              title: const Text("Areas", style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                navegarConSlideDerecha(context, CrearAreaScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
