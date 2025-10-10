import 'package:flutter/material.dart';
import 'package:proyecto_web/Vista/app/principal/Asignacion/Prueba.dart';
import 'package:proyecto_web/Vista/app/principal/Asignacion/Prueba1.dart';

class MenuPrincipalScreen extends StatelessWidget {
  const MenuPrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AsignarCasePage()),
                );
              },
              child: const Text('Asignar Case'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReporteComponentePage(),
                  ),
                );
              },
              child: const Text('Registrar Reporte'),
            ),
          ],
        ),
      ),
    );
  }
}
