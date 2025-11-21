import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Widgets/drawerselector.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  Widget _buildStep(IconData icon, String title, String description) {
    return Card(
      elevation: 0,
      color: Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Icon(icon, color: const Color(0xFF448AFF), size: 36),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(description, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWeb = constraints.maxWidth > 800;
        return SafeArea(
          child: Scaffold(
            appBar: isWeb
                ? null
                : AppBar(
                    title: const Text("Inicio"),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    toolbarHeight: 48,
                  ),
            drawer: isWeb ? null : const CustomDrawer(),
            body: Row(
              children: [
                if (isWeb) const SizedBox(width: 260, child: CustomDrawer()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Flujo de registro de componentes:",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        LayoutBuilder(
                          builder: (context, size) {
                            final bool isLarge = size.maxWidth > 600;

                            return GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: isLarge ? 2 : 1,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 3.7,
                              children: [
                                _buildStep(
                                  Iconsax.box,
                                  "1. Crear Tipo de Componente",
                                  "Registrar un nuevo tipo como 'Mouse', 'Teclado'.",
                                ),
                                _buildStep(
                                  Iconsax.bookmark,
                                  "2. Definir Atributos",
                                  "Agregar atributos como 'color', 'peso', 'marca'.",
                                ),
                                _buildStep(
                                  Iconsax.setting,
                                  "3. Registrar Componente",
                                  "Crear el componente con código único y tipo.",
                                ),
                                _buildStep(
                                  Iconsax.hashtag,
                                  "4. Asignar Valores",
                                  "Rellenar valores para cada atributo.",
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
