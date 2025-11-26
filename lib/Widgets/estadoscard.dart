import 'package:flutter/material.dart';

Widget estadoChip(String? estado) {
  Color color = const Color(0xFF2ECC71);
  String texto = "Disponible";

  switch ((estado ?? "")) {
    case "Mantenimiento":
      color = const Color(0xFFFF6B6B);
      texto = 'Mantenimiento';
      break;

    case "En uso":
      color = const Color.fromARGB(255, 255, 225, 0);
      texto = 'En Uso';
      break;

    case "Dañado":
      color = const Color(0xFFB71C1C);
      texto = 'Dañado';
      break;

    case "Arreglado":
      color = const Color(0xFF42A5F5);
      texto = 'Arreglado';
      break;

    case "pendiente":
      color = const Color(0xFF9C27B0);
      texto = 'Pendiente de revisión';
      break;

    case "pendiente de revisión":
      color = const Color(0xFF9C27B0);
      texto = 'Pendiente de revisión';
      break;

    case "en proceso":
      color = const Color(0xFF42A5F5);
      texto = "En Proceso";
      break;

    case "completado":
      color = const Color(0xFF2ECC71);
      texto = "Completado";
      break;
    case "asignado":
      color = const Color(0xFF2980B9);
      texto = "Asignado";
      break;

    case "activo":
      color = const Color(0xFF27AE60);
      texto = "Activo";
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(90),
    ),
    child: Text(
      texto,

      style: const TextStyle(
        fontSize: 13,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
