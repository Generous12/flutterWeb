import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Provider/usuarioautenticado.dart';
import 'package:proyecto_web/Vista/app/autenticacion/gestionarusuarios.dart';
import 'package:proyecto_web/Vista/app/autenticacion/loginapp.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/listaareas.dart';
import 'package:proyecto_web/Vista/app/principal/Asignacion/asignacion.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/menu.dart';
import 'package:proyecto_web/Vista/app/principal/Historial/gestionarhistorial.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(
      context,
      listen: false,
    );
    final rolUsuario = usuarioProvider.rol ?? "Sin rol";

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWeb = constraints.maxWidth > 800;

        // ============================
        //     MODO ESCRITORIO (WEB)
        // ============================
        if (isWeb) {
          return Container(
            width: 260,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  color: Colors.black,
                  height: 130,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Consumer<UsuarioProvider>(
                        builder: (context, usuarioProvider, _) {
                          final id = usuarioProvider.idUsuario ?? "U";
                          final rol = usuarioProvider.rol ?? "Sin rol";

                          return Row(
                            children: [
                              Initicon(
                                text: id,
                                backgroundColor: Colors.white,
                                style: const TextStyle(color: Colors.black),
                                size: 45,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Menú",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    rol,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    children: [
                      _item(Iconsax.home, "Inicio", () {
                        Navigator.pop(context);
                      }),

                      _itemUsuario(
                        icon: Iconsax.user,
                        text: "Usuarios",
                        enabled: rolUsuario != "Practicante",
                        onTap: () {
                          navegarConSlideDerecha(context, UsuariosScreen());
                        },
                      ),

                      _item(
                        Iconsax.cpu,
                        "Componentes",
                        () => navegarConSlideDerecha(
                          context,
                          MenuComponentesScreen(),
                        ),
                      ),

                      _item(
                        Iconsax.setting_2,
                        "Areas",
                        () =>
                            navegarConSlideDerecha(context, ListaAreasScreen()),
                      ),

                      _item(
                        Iconsax.archive,
                        "Historial de acciones",
                        () =>
                            navegarConSlideDerecha(context, HistorialScreen()),
                      ),

                      _item(
                        Iconsax.archive_1,
                        "Asignaciones",
                        () =>
                            navegarConSlideDerecha(context, AsignacionScreen()),
                      ),

                      const Divider(),

                      Consumer<UsuarioProvider>(
                        builder: (context, usuarioProvider, child) {
                          return ListTile(
                            leading: const Icon(
                              Iconsax.logout,
                              color: Colors.red,
                            ),
                            title: const Text(
                              "Cerrar sesión",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              await usuarioProvider.logout();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Drawer(
          child: SafeArea(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.black),
                    child: Consumer<UsuarioProvider>(
                      builder: (context, usuarioProvider, child) {
                        final id = usuarioProvider.idUsuario ?? "U";
                        final rol = usuarioProvider.rol ?? "Sin rol";

                        return Row(
                          children: [
                            Initicon(
                              text: id,
                              backgroundColor: Colors.white,
                              style: const TextStyle(color: Colors.black),
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Menú",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  rol,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  _item(Iconsax.home, "Inicio", () {
                    Navigator.pop(context);
                  }),

                  _itemUsuario(
                    icon: Iconsax.user,
                    text: "Usuarios",
                    enabled: rolUsuario != "Practicante",
                    onTap: () {
                      navegarConSlideDerecha(context, UsuariosScreen());
                    },
                  ),

                  _item(
                    Iconsax.cpu,
                    "Componentes",
                    () => navegarConSlideDerecha(
                      context,
                      MenuComponentesScreen(),
                    ),
                  ),

                  _item(
                    Iconsax.setting_2,
                    "Areas",
                    () => navegarConSlideDerecha(context, ListaAreasScreen()),
                  ),

                  _item(
                    Iconsax.archive,
                    "Historial de acciones",
                    () => navegarConSlideDerecha(context, HistorialScreen()),
                  ),

                  _item(
                    Iconsax.archive_1,
                    "Asignaciones",
                    () => navegarConSlideDerecha(context, AsignacionScreen()),
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
          ),
        );
      },
    );
  }

  // -------------------------
  //     Helpers
  // -------------------------

  Widget _item(IconData icon, String text, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text, style: const TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }

  Widget _itemUsuario({
    required IconData icon,
    required String text,
    required bool enabled,
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: enabled ? Colors.black : Colors.grey),
      title: Text(
        text,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
