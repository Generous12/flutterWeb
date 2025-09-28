import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/crearComponente.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/listaatributos/lista_atributos.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/listacomponente/listageneralcomponente.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class MenuComponentesScreen extends StatelessWidget {
  const MenuComponentesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text("Menú"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          children: [
            FullWidthMenuTile(
              title: "Registrar",
              description: "Crea un nuevo componente en el sistema",
              icon: Iconsax.add_circle,
              onTap: () {
                navegarConSlideDerecha(context, FlujoCrearComponente());
              },
            ),

            FullWidthMenuTile(
              title: "Lista de Componentes",
              description: "Visualiza todos los componentes registrados",
              icon: Iconsax.document_text,
              onTap: () {
                navegarConSlideDerecha(context, ComponentesList());
              },
            ),

            FullWidthMenuTile(
              title: "Atributos y Valores",
              description: "Agrega o consulta atributos de los componentes",
              icon: Iconsax.chart,
              onTap: () {
                navegarConSlideDerecha(context, ComponentesPageAtributo());
              },
            ),
          ],
        ),
      ),
    );
  }
}
