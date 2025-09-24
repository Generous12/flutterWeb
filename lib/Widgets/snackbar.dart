import 'package:flutter/material.dart';

class SnackBarUtil {
  static void mostrarSnackBarPersonalizado({
    required BuildContext context,
    required String mensaje,
    IconData icono = Icons.info,
    Color? colorFondo,
    Duration duracion = const Duration(seconds: 1),
    String? textoAccion,
    VoidCallback? onAccion,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            colorFondo ??
            (isDark
                ? const Color.fromARGB(255, 0, 0, 0)
                : const Color.fromARGB(255, 0, 0, 0)),
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
