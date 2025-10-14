// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Areas/areasService.dart';
import 'package:proyecto_web/Controlador/Asignacion/Carrito/CarritocaseService.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';
import 'package:proyecto_web/Widgets/toastalertSo.dart';

class DetalleAreaScreen extends StatefulWidget {
  final Map<String, dynamic> area;
  final bool modoCarrito;
  const DetalleAreaScreen({
    super.key,
    required this.area,
    this.modoCarrito = false,
  });

  @override
  State<DetalleAreaScreen> createState() => _DetalleAreaScreenState();
}

class _DetalleAreaScreenState extends State<DetalleAreaScreen> {
  final AreaService _areaService = AreaService();

  List<dynamic> _detalleAreas = [];
  bool _cargando = true;
  List<dynamic> _areas = [];
  @override
  void initState() {
    super.initState();
    _cargarDatos();
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
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "${area["nombre_area"]}",
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          toolbarHeight: 48,
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _cargarDatos,
                child: Consumer<CaseProvider>(
                  builder: (context, caseProv, _) {
                    return ListView(
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
                                .where(
                                  (s) => s["id_area_padre"] == sub["id_area"],
                                )
                                .toList();
                            final tieneSubSub = subSubDeEsta.isNotEmpty;
                            final esSeleccionada =
                                caseProv.areaSeleccionada?["id_area"] ==
                                sub["id_area"];

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
                                    onTap: () async {
                                      if (widget.modoCarrito) {
                                        // Si está en modo carrito, quitar asignación directamente
                                        await _quitarAsignacion(sub["id_area"]);
                                      } else if (tieneSubSub) {
                                        ToastUtil.showWarning(
                                          "Selecciona una sub-subárea dentro de esta subárea.",
                                        );
                                      } else {
                                        await caseProv.seleccionarArea({
                                          ...sub,
                                          "id_area_padre":
                                              widget.area["id_area"],
                                        }, context: context);
                                        Navigator.pop(context);
                                      }
                                    },
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
                                          if (widget.modoCarrito)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.link_off,
                                                color: Colors.redAccent,
                                                size: 26,
                                              ),
                                              onPressed: () =>
                                                  _quitarAsignacion(
                                                    sub["id_area"],
                                                  ),
                                            )
                                          else
                                            (esSeleccionada
                                                ? const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 26,
                                                  )
                                                : const Icon(
                                                    Icons
                                                        .radio_button_unchecked,
                                                    color: Colors.grey,
                                                    size: 26,
                                                  )),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Sub-subáreas
                                  if (tieneSubSub)
                                    Column(
                                      children: subSubDeEsta.map((subsub) {
                                        final esSeleccionadaSubSub =
                                            caseProv
                                                .areaSeleccionada?["id_area"] ==
                                            subsub["id_area"];
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                            trailing: widget.modoCarrito
                                                ? IconButton(
                                                    icon: const Icon(
                                                      Icons.link_off,
                                                      color: Colors.redAccent,
                                                      size: 22,
                                                    ),
                                                    onPressed: () =>
                                                        _quitarAsignacion(
                                                          subsub["id_area"],
                                                        ),
                                                  )
                                                : (esSeleccionadaSubSub
                                                      ? const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.green,
                                                          size: 22,
                                                        )
                                                      : const Icon(
                                                          Icons
                                                              .radio_button_unchecked,
                                                          color: Colors.grey,
                                                          size: 22,
                                                        )),
                                            onTap: () async {
                                              if (widget.modoCarrito) {
                                                await _quitarAsignacion(
                                                  subsub["id_area"],
                                                );
                                              } else {
                                                await caseProv.seleccionarArea({
                                                  ...subsub,
                                                  "id_area_padre": widget
                                                      .area["id_area"], // el área actual (subárea padre)
                                                  "id_area_abue": widget
                                                      .area["id_area_padre"], // el abuelo si existe
                                                }, context: context);
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
