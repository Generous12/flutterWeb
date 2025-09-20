import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/actualizar_atributos.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/crearComponente.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/eliminarComponente.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/listacomponente/listageneralcomponente.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class MenuComponentesScreen extends StatelessWidget {
  const MenuComponentesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text("Menú de Componentes"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          children: [
            _MenuButton(
              icon: Iconsax.add_circle,
              text: "Registrar",
              color1: Colors.blue.shade800,
              color2: Colors.blue.shade400,
              onTap: () {
                navegarConSlideDerecha(context, FlujoCrearComponente());
              },
            ),
            const SizedBox(height: 18),
            _MenuButton(
              icon: Iconsax.document_text,
              text: "Lista de Componentes",
              color1: Colors.black87,
              color2: Colors.black54,
              onTap: () {
                navegarConSlideDerecha(context, ComponentesList());
              },
            ),
            const SizedBox(height: 18),
            _MenuButton(
              icon: Iconsax.refresh_circle,
              text: "Eliminar un Componente",
              color1: Colors.blueGrey.shade800,
              color2: Colors.blueGrey.shade500,
              onTap: () {
                navegarConSlideDerecha(context, ComponentesEliminar());
              },
            ),
            const SizedBox(height: 18),
            _MenuButton(
              icon: Iconsax.chart,
              text: "Atributos y Valores",
              color1: Colors.blue.shade900,
              color2: Colors.blue.shade600,
              onTap: () {
                navegarConSlideDerecha(context, ListaComponentesAtributoPage());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color1;
  final Color color2;

  const _MenuButton({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.color1,
    required this.color2,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Card(
          elevation: 6,
          shadowColor: widget.color1.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [widget.color1, widget.color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(widget.icon, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
