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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Icon(icon, color: Colors.blueAccent, size: 36),
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Inicio"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          toolbarHeight: 48,
          elevation: 0,
        ),
        drawer: const CustomDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Flujo de registro de componentes:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStep(
                Iconsax.box,
                "1. Crear Tipo de Componente",
                "Se registra un nuevo tipo en la tabla Tipo_Componente, por ejemplo 'Mouse', 'Teclado'.",
              ),
              const SizedBox(height: 8),
              _buildStep(
                Iconsax.bookmark,
                "2. Definir Atributos",
                "Para cada tipo de componente, se agregan atributos en la tabla Atributo, como 'color', 'peso', 'marca'.",
              ),
              const SizedBox(height: 8),
              _buildStep(
                Iconsax.setting,
                "3. Registrar Componente",
                "Se crea un componente en la tabla Componente con código único, cantidad y vínculo al tipo creado.",
              ),
              const SizedBox(height: 8),
              _buildStep(
                Iconsax.hashtag,
                "4. Asignar Valores de Atributos",
                "Se rellenan los valores de cada atributo para el componente en la tabla Valor_Atributo.",
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
