// ignore_for_file: unused_field
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Areas/areasService.dart';
import 'package:proyecto_web/Controlador/Asignacion/Carrito/CarritocaseService.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/casesAsignados/caseyaAsignado.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/navegator.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';
import 'package:proyecto_web/Widgets/textfield.dart';
import 'package:proyecto_web/Widgets/toastalertSo.dart';

class DetalleAreaScreen extends StatefulWidget {
  final Map<String, dynamic> area;
  final bool modoCarrito;
  final bool modoVercases;
  const DetalleAreaScreen({
    super.key,
    required this.area,
    this.modoCarrito = false,
    this.modoVercases = false,
  });

  @override
  State<DetalleAreaScreen> createState() => _DetalleAreaScreenState();
}

class _DetalleAreaScreenState extends State<DetalleAreaScreen> {
  final AreaService _areaService = AreaService();

  List<dynamic> _detalleAreas = [];
  bool _cargando = true;
  List<dynamic> _areas = [];
  final AreaService areaService = AreaService();

  late TextEditingController _jefeAreaController;
  late TextEditingController _correoContactoController;
  late TextEditingController _telefonoContactoController;
  late TextEditingController _descripcionController;
  late String _jefeOriginal;
  late String _correoOriginal;
  late String _telefonoOriginal;
  late String _descripcionOriginal;

  @override
  void initState() {
    super.initState();
    _jefeAreaController = TextEditingController();
    _correoContactoController = TextEditingController();
    _telefonoContactoController = TextEditingController();
    _descripcionController = TextEditingController();

    _cargarDatos();
  }

  @override
  void dispose() {
    _jefeAreaController.dispose();
    _correoContactoController.dispose();
    _telefonoContactoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _quitarAsignacion(int idArea) async {
    final confirmar = await showCustomDialog(
      context: context,
      title: 'Confirmar acción',
      message: '¿Deseas quitar la asignación de esta área?',
      confirmButtonText: 'Sí, quitar',
      cancelButtonText: 'Cancelar',
      confirmButtonColor: Colors.redAccent,
    );

    if (confirmar != true) return;

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

  bool get huboCambio {
    if (_jefeAreaController.text != _jefeOriginal ||
        _correoContactoController.text != _correoOriginal ||
        _telefonoContactoController.text != _telefonoOriginal ||
        _descripcionController.text != _descripcionOriginal) {
      return true;
    }
    return false;
  }

  Future<bool> _onWillPop() async {
    if (huboCambio) {
      final salir = await showCustomDialog(
        context: context,
        title: "Cambios sin guardar",
        message: "Tienes cambios sin guardar. ¿Deseas salir de todas formas?",
        confirmButtonText: "Salir",
        cancelButtonText: "Cancelar",
      );
      return salir ?? false;
    }
    return true;
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);

    final todas = await _areaService.listarAreasPadresGeneral(limit: 100);
    final detalle = await _areaService.detalleAreaPadre(widget.area["id_area"]);

    if (detalle.isNotEmpty) {
      final areaPadre = detalle.first;

      // Valores en los TextFields
      _jefeAreaController.text = areaPadre["jefe_area"] ?? '';
      _correoContactoController.text = areaPadre["correo_contacto"] ?? '';
      _telefonoContactoController.text = areaPadre["telefono_contacto"] ?? '';
      _descripcionController.text = areaPadre["descripcion"] ?? '';

      // Guardar valores originales
      _jefeOriginal = areaPadre["jefe_area"] ?? '';
      _correoOriginal = areaPadre["correo_contacto"] ?? '';
      _telefonoOriginal = areaPadre["telefono_contacto"] ?? '';
      _descripcionOriginal = areaPadre["descripcion"] ?? '';
    }

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
      child: WillPopScope(
        onWillPop: _onWillPop,
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await _onWillPop()) {
                  Navigator.pop(context);
                }
              },
            ),
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
                          if (!widget.modoCarrito) ...[
                            CustomTextField(
                              controller: _jefeAreaController,
                              label: "Jefe del Área",
                              hintText: "Ejemplo: Carlos Pérez",
                              prefixIcon: Iconsax.user,
                            ),
                            CustomTextField(
                              controller: _correoContactoController,
                              label: "Correo de Contacto (Opcional)",
                              hintText: "ejemplo@empresa.com",
                              prefixIcon: Iconsax.sms,
                            ),
                            CustomTextField(
                              controller: _telefonoContactoController,
                              label: "Teléfono de Contacto (Opcional)",
                              hintText: "900 123 456",
                              prefixIcon: Iconsax.mobile,
                              isNumeric: true,
                              maxLength: 9,
                            ),
                            CustomTextField(
                              controller: _descripcionController,
                              label: "Descripción del Área (Opcional)",
                              hintText: "Descripción general de esta área...",
                              prefixIcon: Iconsax.note,
                              maxLines: 3,
                            ),
                          ],

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
                                        if (widget.modoVercases) {
                                          navegarConSlideDerecha(
                                            context,
                                            CasesDeAreaScreen(
                                              idArea: sub["id_area"],
                                              nombreArea: sub["nombre_area"],
                                            ),
                                          );
                                        } else if (widget.modoCarrito) {
                                          if (tieneSubSub) {
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
                                            if (widget.modoVercases)
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                              trailing: widget.modoVercases
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
                                                if (widget.modoVercases) {
                                                  navegarConSlideDerecha(
                                                    context,
                                                    CasesDeAreaScreen(
                                                      idArea: subsub["id_area"],
                                                      nombreArea:
                                                          subsub["nombre_area"],
                                                    ),
                                                  );
                                                } else if (widget.modoCarrito) {
                                                  await caseProv.seleccionarArea({
                                                    ...subsub,
                                                    "id_area_padre":
                                                        widget.area["id_area"],
                                                    "id_area_abue": widget
                                                        .area["id_area_padre"],
                                                  }, context: context);
                                                  if (context.mounted)
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
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
              child: LoadingOverlayButtonHabilitar(
                text: "Actualizar Datos",
                enabled: true,
                onPressedLogic: () async {
                  final confirmado = await showCustomDialog(
                    context: context,
                    title: "Confirmar",
                    message: "¿Deseas guardar los cambios?",
                    confirmButtonText: "Sí",
                    cancelButtonText: "No",
                  );

                  if (!confirmado) return;

                  try {
                    final ok = await areaService.actualizarAreaPadre(
                      idArea: widget.area["id_area"],
                      jefeArea: _jefeAreaController.text,
                      correoContacto: _correoContactoController.text,
                      telefonoContacto: _telefonoContactoController.text,
                      descripcion: _descripcionController.text,
                    );

                    if (ok) {
                      showCustomDialog(
                        context: context,
                        title: "Éxito",
                        message: "Datos actualizados correctamente",
                        confirmButtonText: "Cerrar",
                      );
                    } else {
                      showCustomDialog(
                        context: context,
                        title: "Error",
                        message: "No se pudo actualizar, intenta nuevamente",
                        confirmButtonText: "Cerrar",
                      );
                    }
                  } catch (e) {
                    showCustomDialog(
                      context: context,
                      title: "Error",
                      message: "Excepción: $e",
                      confirmButtonText: "Cerrar",
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
