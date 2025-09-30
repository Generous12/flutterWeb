import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Provider/usuarioautenticado.dart';
import 'package:proyecto_web/Vista/app/autenticacion/loginapp.dart';
import 'package:proyecto_web/Vista/app/autenticacion/registrarusuarios.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/crearAreas.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/menu.dart';
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
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Consumer<UsuarioProvider>(
                      builder: (context, usuarioProvider, child) {
                        final id = usuarioProvider.idUsuario ?? "U";
                        return Initicon(
                          text: id,
                          backgroundColor: Colors.white,
                          style: const TextStyle(color: Colors.black),
                          size: 40,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Menú",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
              leading: const Icon(Iconsax.user, color: Colors.black),
              title: const Text(
                "Usuarios",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                navegarConSlideDerecha(context, RegistroUsuarioScreen());
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.cpu, color: Colors.black),
              title: const Text(
                "Componentes",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                navegarConSlideDerecha(context, MenuComponentesScreen());
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.setting_2, color: Colors.black),
              title: const Text("Areas", style: TextStyle(color: Colors.black)),
              onTap: () {
                navegarConSlideDerecha(context, CrearAreaScreen());
              },
            ),
            const Divider(),
            Consumer<UsuarioProvider>(
              builder: (context, usuarioProvider, child) {
                return ListTile(
                  leading: const Icon(Iconsax.logout, color: Colors.red),
                  title: const Text(
                    "Cerrar sesión",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    await usuarioProvider.logout();

                    // Navegar al Login
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
