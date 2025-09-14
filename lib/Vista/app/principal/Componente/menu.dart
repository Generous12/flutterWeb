import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/crearComponente.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/listarUdapte_Componente.dart';
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
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          children: [
            _MenuButton(
              icon: Iconsax.add_circle,
              text: "Registrar",
              color1: Colors.blueAccent,
              color2: Colors.lightBlue,
              onTap: () {
                navegarConSlideDerecha(context, FlujoCrearComponente());
              },
            ),
            _MenuButton(
              icon: Iconsax.document_text,
              text: "Listar",
              color1: Colors.green,
              color2: Colors.teal,
              onTap: () {
                navegarConSlideDerecha(context, ComponentesList());
              },
            ),
            _MenuButton(
              icon: Iconsax.refresh_circle,
              text: "Actualizar",
              color1: Colors.orange,
              color2: Colors.deepOrange,
              onTap: () {
                debugPrint("👉 Actualizar componente");
              },
            ),
            _MenuButton(
              icon: Iconsax.chart,
              text: "Reportes",
              color1: Colors.purple,
              color2: Colors.deepPurple,
              onTap: () {
                debugPrint("👉 Reportes de componentes");
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
                  const SizedBox(height: 14),
                  Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 16,
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
