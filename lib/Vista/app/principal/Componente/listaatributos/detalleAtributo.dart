import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/Atributos/atriListar_componente.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';
import 'package:proyecto_web/Widgets/textfield.dart';

class DetalleAtributoPage extends StatefulWidget {
  final int idComponente;

  const DetalleAtributoPage({super.key, required this.idComponente});

  @override
  State<DetalleAtributoPage> createState() => _DetalleAtributoPageState();
}

class _DetalleAtributoPageState extends State<DetalleAtributoPage> {
  final ComponenteServiceAtributo _service = ComponenteServiceAtributo();

  Map<String, dynamic>? _cabecera;
  List<Map<String, dynamic>> atributos = [];
  bool _cargando = true;
  bool huboCambio = false;
  String? _error;

  final List<String> tipos = ["Texto", "Número", "Fecha"];
  final Map<String, String> abreviaturas = {
    "Texto": "T",
    "Número": "N",
    "Fecha": "F",
  };

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    try {
      final data = await _service.detalleComponente(widget.idComponente);
      setState(() {
        _cabecera = data["cabecera"];
        atributos = data["atributos"]
            .map<Map<String, dynamic>>(
              (atr) => {
                "id_atributo": atr.idAtributo,
                "controllerNombre": TextEditingController(
                  text: atr.nombreAtributo,
                ),
                "controllerValor": TextEditingController(text: atr.valor),
                "tipo": atr.tipoDato,
                "esNuevo": false,
                "originalNombre": atr.nombreAtributo,
                "originalTipo": atr.tipoDato,
                "originalValor": atr.valor,
              },
            )
            .toList();

        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _addAtributo() {
    atributos.add({
      "controllerNombre": TextEditingController(),
      "controllerValor": TextEditingController(),
      "tipo": tipos[0],
      "esNuevo": true,
    });
    setState(() {});
  }

  Future<void> _seleccionarTipo(Map<String, dynamic> attr) async {
    final seleccionado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selecciona el tipo de atributo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: tipos
              .map(
                (t) => ListTile(
                  title: Text(t),
                  onTap: () => Navigator.pop(context, t),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (seleccionado != null) {
      setState(() => attr["tipo"] = seleccionado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 48,
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            elevation: 2,
            leading: IconButton(
              onPressed: () async {
                final salir = await _onWillPop();
                if (salir) Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
            ),
            title: const Text(
              "Atributos",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: _addAtributo,
                icon: const Icon(Icons.add, color: Colors.blueAccent),
              ),
            ],
          ),
          body: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Text(
                    "Error: $_error",
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(6, 5, 6, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: atributos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final attr = entry.value;

                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (attr["esNuevo"] == true) return true;

                          final confirmado = await showCustomDialog(
                            context: context,
                            title: "Confirmar",
                            message: "¿Deseas eliminar este atributo?",
                            confirmButtonText: "Sí",
                            cancelButtonText: "No",
                          );
                          return confirmado ?? false;
                        },
                        onDismissed: (direction) async {
                          final eliminado = attr;
                          final indexEliminado = index;

                          setState(() {
                            atributos.removeAt(index);
                          });

                          if (eliminado["esNuevo"] == true) {
                            // Solo era local
                            SnackBarUtil.mostrarSnackBarPersonalizado(
                              context: context,
                              mensaje: "Atributo eliminado",
                              icono: Icons.delete,
                              duracion: const Duration(seconds: 2),
                              textoAccion: "Deshacer",
                              onAccion: () {
                                setState(() {
                                  atributos.insert(indexEliminado, eliminado);
                                });
                              },
                            );
                          } else {
                            // Ya existía en la DB
                            final resp = await _service.eliminarAtributo(
                              eliminado["id_atributo"],
                            );
                            if (resp["success"] == true) {
                              SnackBarUtil.mostrarSnackBarPersonalizado(
                                context: context,
                                mensaje:
                                    "Atributo eliminado de la base de datos",
                                icono: Icons.delete_forever,
                                duracion: const Duration(seconds: 2),
                              );
                            } else {
                              setState(() {
                                atributos.insert(indexEliminado, eliminado);
                              });
                              SnackBarUtil.mostrarSnackBarPersonalizado(
                                context: context,
                                mensaje: "Error al eliminar el atributo",
                                icono: Icons.error,
                                duracion: const Duration(seconds: 2),
                              );
                            }
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  controller: attr["controllerNombre"],
                                  hintText: "Nombre del atributo",
                                  label: "Atributo",
                                ),
                                const SizedBox(height: 8),
                                CustomTextField(
                                  controller: attr["controllerValor"],
                                  hintText: "Valor del atributo",
                                  label: "Valor",
                                  suffixIcon: GestureDetector(
                                    onTap: () => _seleccionarTipo(attr),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.blueAccent,
                                        child: Text(
                                          abreviaturas[attr["tipo"]] ?? "",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () async {
                _guardarAtributos();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Guardar Cambios",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Función para verificar cambios antes de salir
  Future<bool> _onWillPop() async {
    bool cambios = atributos.any((attr) {
      final nombre = attr["controllerNombre"].text.trim();
      final valor = attr["controllerValor"].text.trim();
      final tipo = attr["tipo"];

      return attr["esNuevo"] == true ||
          nombre != attr["originalNombre"] ||
          valor != attr["originalValor"] ||
          tipo != attr["originalTipo"];
    });

    if (cambios) {
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

  Future<void> _guardarAtributos() async {
    bool huboCambio = false;

    try {
      for (var attr in atributos) {
        final nombre = attr["controllerNombre"].text.trim();
        final valor = attr["controllerValor"].text.trim();
        final tipo = attr["tipo"];

        if (attr["esNuevo"] == true) {
          // 1️⃣ Insertar atributo nuevo
          final insertado = await _service.insertarAtributo(
            _cabecera!["id_tipo"],
            nombre,
            tipo,
          );

          if (insertado["success"] == true) {
            final nuevoId = insertado["id_atributo"];

            // 2️⃣ Guardar valor del atributo
            final valorGuardado = await _service.guardarValor(
              _cabecera!["id_componente"],
              nuevoId,
              valor,
            );

            if (valorGuardado["success"] == true) {
              huboCambio = true;

              // Actualizar datos locales para no volver a pedir confirmación
              attr["id_atributo"] = nuevoId;
              attr["esNuevo"] = false;
              attr["originalNombre"] = nombre;
              attr["originalTipo"] = tipo;
              attr["originalValor"] = valor;
            }
          }
        } else {
          // 3️⃣ Atributo existente: verificar cambios
          final bool cambioAtributo =
              nombre != attr["originalNombre"] || tipo != attr["originalTipo"];
          final bool cambioValor = valor != attr["originalValor"];

          if (cambioAtributo) {
            final actualizado = await _service.actualizarAtributo(
              attr["id_atributo"],
              nombre,
              tipo,
            );

            if (actualizado["success"] == true) {
              huboCambio = true;
              attr["originalNombre"] = nombre;
              attr["originalTipo"] = tipo;
            }
          }

          if (cambioValor) {
            final valorGuardado = await _service.guardarValor(
              _cabecera!["id_componente"],
              attr["id_atributo"],
              valor,
            );

            if (valorGuardado["success"] == true) {
              huboCambio = true;
              attr["originalValor"] = valor;
            }
          }
        }
      }

      if (huboCambio) {
        showCustomDialog(
          context: context,
          title: "Éxito",
          message: "Se registraron los cambios correctamente",
          confirmButtonText: "Cerrar",
        );
      } else {
        showCustomDialog(
          context: context,
          title: "Información",
          message: "No hubo cambios que guardar",
          confirmButtonText: "Cerrar",
        );
      }
    } catch (e) {
      showCustomDialog(
        context: context,
        title: "Error",
        message: "Ocurrió un error al guardar los cambios: $e",
        confirmButtonText: "Cerrar",
      );
    }
  }
}
