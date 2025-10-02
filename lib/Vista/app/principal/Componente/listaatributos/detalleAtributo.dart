import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:proyecto_web/Clases/plantillasComponente.dart';
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
  final List<Plantilla> plantillas = [
    Plantilla(
      nombre: "Periféricos",
      atributos: [
        {"nombre": "Marca", "tipo": "Texto"},
        {"nombre": "Modelo", "tipo": "Texto"},
        {"nombre": "Tipo de conexión", "tipo": "Texto"},
        {"nombre": "Color", "tipo": "Texto"},
        {"nombre": "Dimensiones", "tipo": "Texto"},
        {"nombre": "Peso", "tipo": "Número"},
      ],
    ),
    Plantilla(
      nombre: "RAM",
      atributos: [
        {"nombre": "Capacidad", "tipo": "Número"}, // GB
        {"nombre": "Velocidad", "tipo": "Número"}, // MHz
        {"nombre": "Tipo", "tipo": "Texto"}, // DDR4, DDR5, etc.
        {"nombre": "Latencia", "tipo": "Número"}, // CL
        {"nombre": "Voltaje", "tipo": "Número"}, // V
      ],
    ),
    Plantilla(
      nombre: "Procesador",
      atributos: [
        {"nombre": "Marca", "tipo": "Texto"}, // Intel, AMD
        {"nombre": "Modelo", "tipo": "Texto"},
        {"nombre": "Número de núcleos", "tipo": "Número"},
        {"nombre": "Número de hilos", "tipo": "Número"},
        {"nombre": "Frecuencia base", "tipo": "Número"}, // GHz
        {"nombre": "Frecuencia turbo", "tipo": "Número"}, // GHz
        {"nombre": "Litografía", "tipo": "Número"}, // nm
      ],
    ),
    Plantilla(
      nombre: "Disco duro / SSD",
      atributos: [
        {"nombre": "Capacidad", "tipo": "Número"}, // GB/TB
        {"nombre": "Tipo", "tipo": "Texto"}, // SSD, HDD
        {"nombre": "Interfaz", "tipo": "Texto"}, // SATA, NVMe
        {"nombre": "Velocidad de lectura", "tipo": "Número"}, // MB/s
        {"nombre": "Velocidad de escritura", "tipo": "Número"}, // MB/s
        {"nombre": "Formato", "tipo": "Texto"}, // 2.5", M.2, etc.
      ],
    ),
    Plantilla(
      nombre: "Tarjeta de video",
      atributos: [
        {"nombre": "Marca", "tipo": "Texto"}, // Nvidia, AMD
        {"nombre": "Modelo", "tipo": "Texto"},
        {"nombre": "Memoria", "tipo": "Número"}, // GB
        {"nombre": "Tipo de memoria", "tipo": "Texto"}, // GDDR6, etc.
        {"nombre": "Frecuencia del núcleo", "tipo": "Número"}, // MHz
        {"nombre": "Consumo energético", "tipo": "Número"}, // W
      ],
    ),
    Plantilla(
      nombre: "Placa base",
      atributos: [
        {"nombre": "Marca", "tipo": "Texto"},
        {"nombre": "Modelo", "tipo": "Texto"},
        {"nombre": "Socket", "tipo": "Texto"}, // LGA1700, AM5, etc.
        {"nombre": "Chipset", "tipo": "Texto"},
        {"nombre": "Memoria máxima", "tipo": "Número"}, // GB
        {"nombre": "Ranuras RAM", "tipo": "Número"},
        {"nombre": "Formato", "tipo": "Texto"}, // ATX, Micro-ATX
      ],
    ),
  ];

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

  Future<Plantilla?> mostrarModalPlantilla(BuildContext context) async {
    final Map<String, IconData> iconosPlantilla = {
      "Periféricos": LucideIcons.mouse,
      "RAM": LucideIcons.cpu,
      "Procesador": LucideIcons.cpu,
      "Disco duro / SSD": LucideIcons.hardDrive,
      "Tarjeta de video": LucideIcons.monitor,
    };

    return showModalBottomSheet<Plantilla>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Selecciona una plantilla",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ...plantillas.map((p) {
                    return ListTile(
                      leading: Icon(
                        iconosPlantilla[p.nombre] ?? LucideIcons.box,
                        color: Colors.blue,
                      ),
                      title: Text(p.nombre),
                      onTap: () => Navigator.pop(context, p),
                    );
                  }).toList(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      "id_atributo": null,
      "controllerNombre": TextEditingController(),
      "controllerValor": TextEditingController(),
      "tipo": tipos[0],
      "esNuevo": true,
      "originalNombre": "",
      "originalTipo": tipos[0],
      "originalValor": "",
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
            title: Text(
              _cabecera?["codigo_inventario"] ?? "Atributos",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: _addAtributo,
                icon: const Icon(Icons.add, color: Colors.blueAccent),
              ),
              // ===== NUEVO ICONO PARA PLANTILLAS =====
              IconButton(
                onPressed: () async {
                  final plantillaSeleccionada = await mostrarModalPlantilla(
                    context,
                  );
                  if (plantillaSeleccionada != null) {
                    // Agregar atributos de la plantilla a la lista
                    setState(() {
                      for (var attr in plantillaSeleccionada.atributos) {
                        atributos.add({
                          "controllerNombre": TextEditingController(
                            text: attr["nombre"],
                          ),
                          "controllerValor": TextEditingController(),
                          "tipo": attr["tipo"],
                          "esNuevo": true,
                        });
                      }
                    });
                  }
                },
                icon: const Icon(
                  Icons.grid_view,
                  color: Colors.blueAccent,
                ), // icono de plantilla
                tooltip: "Seleccionar plantilla",
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
                          color: attr["esNuevo"] == true
                              ? const Color.fromARGB(255, 241, 249, 255)
                              : Colors.white,
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
          final insertado = await _service.insertarAtributo(
            _cabecera!["id_tipo"],
            nombre,
            tipo,
          );

          final nuevoId = insertado["id_atributo"];
          if (insertado["success"] == true && nuevoId != null) {
            attr["id_atributo"] = nuevoId;

            final valorGuardado = await _service.guardarValor(
              _cabecera!["id_componente"],
              nuevoId,
              valor,
            );

            if (valorGuardado["success"] == true) {
              huboCambio = true;
              attr["esNuevo"] = false;
              attr["originalNombre"] = nombre;
              attr["originalTipo"] = tipo;
              attr["originalValor"] = valor;
            } else {
              throw Exception("No se pudo guardar el valor del nuevo atributo");
            }
          } else {
            throw Exception("No se pudo insertar el nuevo atributo");
          }
        } else {
          final int? idAtributo = attr["id_atributo"];
          if (idAtributo == null) {
            throw Exception("El atributo existente no tiene ID");
          }

          final bool cambioAtributo =
              nombre != attr["originalNombre"] || tipo != attr["originalTipo"];
          final bool cambioValor = valor != attr["originalValor"];

          if (cambioAtributo) {
            final actualizado = await _service.actualizarAtributo(
              idAtributo,
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
              idAtributo,
              valor,
            );

            if (valorGuardado["success"] == true) {
              huboCambio = true;
              attr["originalValor"] = valor;
            }
          }
        }
      }

      // ===== MENSAJES FINALES =====
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
