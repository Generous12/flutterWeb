import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Asignacion/Carrito/CarritocaseService.dart';
import 'package:proyecto_web/Controlador/Componentes/list_Update_Component.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/listaareas.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/listacomponente/listageneralcomponente.dart';
import 'package:proyecto_web/Widgets/ZoomImage.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class AsignacionScreen extends StatefulWidget {
  const AsignacionScreen({super.key});

  @override
  State<AsignacionScreen> createState() => _AsignacionScreenState();
}

class _AsignacionScreenState extends State<AsignacionScreen> {
  Future<void> _confirmarAsignacion(
    BuildContext context,
    CaseProvider caseProv,
  ) async {
    if (caseProv.componentesSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay componentes para asignar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final area = caseProv.areaSeleccionada;
    if (area == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un área antes de confirmar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    await Future.delayed(const Duration(seconds: 1));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Asignación confirmada exitosamente.'),
        backgroundColor: Colors.green,
      ),
    );
    await caseProv.limpiarCase();
  }

  @override
  Widget build(BuildContext context) {
    final caseProv = Provider.of<CaseProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Asignación de Case'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Iconsax.buildings),
              tooltip: 'Ir a Áreas',
              onPressed: () {
                navegarConSlideDerecha(
                  context,
                  const AreasCarrito(),
                  onVolver: () {
                    setState(() {});
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          shape: const CircleBorder(),
          onPressed: () {
            navegarConSlideDerecha(
              context,
              const ComponentesCarrito(),
              onVolver: () {
                setState(() {});
              },
            );
          },
          child: const Icon(Iconsax.add, color: Colors.white, size: 28),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              if (caseProv.areaSeleccionada != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Área',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        Provider.of<CaseProvider>(
                          context,
                          listen: false,
                        ).quitarAreaSeleccionada();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    caseProv.areaSeleccionada!['nombre_area'] ??
                        'Área sin nombre',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Divider(height: 32),
              ],

              if (caseProv.componentesSeleccionados.any(
                (c) => c.tipoNombre.toLowerCase().contains('periférico'),
              )) ...[
                const Text(
                  'Periféricos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                ...caseProv.componentesSeleccionados
                    .where(
                      (c) => c.tipoNombre.toLowerCase().contains('periférico'),
                    )
                    .map(
                      (componente) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _buildComponenteTile(
                          context,
                          componente,
                          caseProv,
                        ),
                      ),
                    )
                    .toList(),
                const Divider(height: 32),
              ],

              if (caseProv.componentesSeleccionados.any(
                (c) => !c.tipoNombre.toLowerCase().contains('periférico'),
              )) ...[
                const Text(
                  'Componentes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                ...caseProv.componentesSeleccionados
                    .where(
                      (c) => !c.tipoNombre.toLowerCase().contains('periférico'),
                    )
                    .map(
                      (componente) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _buildComponenteTile(
                          context,
                          componente,
                          caseProv,
                        ),
                      ),
                    )
                    .toList(),
              ],
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12),
          child: LoadingOverlayButton(
            text: "Confirmar Asignación",
            icon: Iconsax.tick_circle,
            color: Colors.black,
            onPressedLogic: () async => _confirmarAsignacion(context, caseProv),
          ),
        ),
      ),
    );
  }
}

Widget _buildComponenteTile(
  BuildContext context,
  ComponenteUpdate componente,
  CaseProvider caseProv,
) {
  Uint8List? firstValidImage;
  for (final b64 in componente.imagenesBase64) {
    final bytes = componente.imagenBytes(
      componente.imagenesBase64.indexOf(b64),
    );
    if (bytes != null) {
      firstValidImage = bytes;
      break;
    }
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: GestureDetector(
        onTap: () {
          final imagenesUint8 = componente.imagenesBase64
              .map(
                (b64) => componente.imagenBytes(
                  componente.imagenesBase64.indexOf(b64),
                ),
              )
              .whereType<Uint8List>()
              .toList();

          if (imagenesUint8.isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ZoomableGalleryPage(
                  imagenes: imagenesUint8,
                  initialIndex: 0,
                ),
              ),
            );
          }
        },
        child: Hero(
          tag: 'componente_${componente.id}_img',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: firstValidImage != null
                ? Image.memory(
                    firstValidImage,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade100,
                    child: const Icon(
                      Iconsax.cpu,
                      color: Colors.black45,
                      size: 34,
                    ),
                  ),
          ),
        ),
      ),
      title: Text(
        componente.nombreTipo,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              componente.codigoInventario,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: componente.estado == 'Disponible'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                componente.estado,
                style: TextStyle(
                  fontSize: 12,
                  color: componente.estado == 'Disponible'
                      ? Colors.green[700]
                      : Colors.orange[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
        onPressed: () => caseProv.quitarComponente(componente.id),
      ),
    ),
  );
}
