// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Controlador/areasService.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';

class DetalleAreaScreen extends StatefulWidget {
  final Map<String, dynamic> area;
  const DetalleAreaScreen({super.key, required this.area});

  @override
  State<DetalleAreaScreen> createState() => _DetalleAreaScreenState();
}

class _DetalleAreaScreenState extends State<DetalleAreaScreen> {
  final AreaService _areaService = AreaService();
  List<dynamic> _areas = [];
  List<dynamic> _detalleAreas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);

    final todas = await _areaService.listarAreasPadresGeneral(limit: 100);
    final detalle = await _areaService.detalleAreaPadre(widget.area["id_area"]);

    setState(() {
      _areas = todas
          .where((a) => a["id_area"] != widget.area["id_area"])
          .toList();
      _detalleAreas = detalle;
      _cargando = false;
    });
  }

  Future<void> _quitarAsignacion(int idArea) async {
    final resp = await _areaService.quitarAsignacionArea(idArea);

    SnackBarUtil.mostrarSnackBarPersonalizado(
      context: context,
      mensaje: resp["message"],
      icono: resp["success"] == true
          ? Iconsax.trash
          : Icons.warning_amber_rounded,
      colorFondo: Colors.black,
    );

    if (resp["success"] == true) _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    final area = widget.area;
    final subAreas = _detalleAreas
        .where((a) => a["tipo_area"] == "Subárea")
        .toList();
    final subSubAreas = _detalleAreas
        .where((a) => a["tipo_area"] == "Sub-Subárea")
        .toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "Detalle - ${area["nombre_area"]}",
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 2,
        ),

        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _cargarDatos,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      "Subáreas",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (subAreas.isEmpty)
                      const Center(
                        child: Text(
                          "No hay subáreas registradas.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    else
                      ...subAreas.map((sub) {
                        final subSubDeEsta = subSubAreas
                            .where((s) => s["id_area_padre"] == sub["id_area"])
                            .toList();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.account_tree_rounded,
                                        color: Colors.blueAccent,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          sub["nombre_area"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.link_off,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () =>
                                            _quitarAsignacion(sub["id_area"]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (subSubDeEsta.isNotEmpty)
                                Column(
                                  children: subSubDeEsta.map((subsub) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 0,
                                            ),
                                        dense: true,
                                        leading: const Icon(
                                          Icons.subdirectory_arrow_right,
                                          color: Colors.green,
                                          size: 22,
                                        ),
                                        title: Text(
                                          subsub["nombre_area"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),

                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.link_off,
                                            color: Colors.redAccent,
                                            size: 20,
                                          ),
                                          onPressed: () => _quitarAsignacion(
                                            subsub["id_area"],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
      ),
    );
  }
}
