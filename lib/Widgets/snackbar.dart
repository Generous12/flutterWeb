import 'package:flutter/material.dart';

class SnackBarUtil {
  static void mostrarSnackBarPersonalizado({
    required BuildContext context,
    required String mensaje,
    IconData icono = Icons.info,
    Color? colorFondo, // opcional
    Duration duracion = const Duration(seconds: 2),
    String? textoAccion, // Ejemplo: "Deshacer"
    VoidCallback? onAccion, // Callback si el usuario presiona el botón
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            colorFondo ??
            (isDark
                ? const Color(0xFF2C2C2C)
                : const Color(0xFF444444)), // gris oscuro por defecto
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: duracion,
        content: Row(
          children: [
            Icon(icono, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(mensaje, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        action: (textoAccion != null && onAccion != null)
            ? SnackBarAction(
                label: textoAccion,
                textColor: Colors.blue,
                onPressed: onAccion,
              )
            : null,
      ),
    );
  }
}
