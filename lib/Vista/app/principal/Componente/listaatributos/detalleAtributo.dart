import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
                "controllerNombre": TextEditingController(
                  text: atr.nombreAtributo,
                ),
                "controllerValor": TextEditingController(text: atr.valor),
                "tipo": atr.tipoDato,
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
    return SafeArea(
      child: Scaffold(
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
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 10,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.fromLTRB(3, 0, 3, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const Text(
                                  "Atributos",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _addAtributo,
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Color.fromARGB(110, 210, 210, 210),
                              thickness: 1,
                            ),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.blueAccent
                                      .withOpacity(0.1),
                                  child: const Icon(
                                    Iconsax.box,
                                    color: Colors.blueAccent,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Componente #${_cabecera?["id_componente"] ?? "-"}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Iconsax.category,
                                          size: 18,
                                          color: Colors.blueAccent,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _cabecera?["nombre_tipo"] ?? "-",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Iconsax.code,
                                          size: 18,
                                          color: Colors.blueAccent,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _cabecera?["codigo_inventario"] ??
                                              "-",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Activo",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
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
                              borderRadius: BorderRadius.circular(
                                20,
                              ), // 👈 también redondeo el fondo rojo
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (attr["esNuevo"] == true) {
                              return true;
                            }
                            final confirmado = await showCustomDialog(
                              context: context,
                              title: "Confirmar",
                              message: "¿Deseas eliminar este atributo?",
                              confirmButtonText: "Sí",
                              cancelButtonText: "No",
                            );
                            return confirmado ?? false;
                          },
                          onDismissed: (direction) {
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
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                20,
                              ), // 👈 esquinas redondeadas
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
                  ],
                ),
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(12),

          child: ElevatedButton(
            onPressed: () async {
              for (var attr in atributos) {
                final nombre = attr["controllerNombre"].text.trim();
                final valor = attr["controllerValor"].text.trim();
                final tipo = attr["tipo"];

                if (attr["esNuevo"] == true) {
                  // 1️⃣ Insertar atributo
                  final insertado = await _service.insertarAtributo(
                    _cabecera!["id_tipo"], // viene de la cabecera
                    nombre,
                    tipo,
                  );

                  if (insertado["success"] == true) {
                    final nuevoId = insertado["id_atributo"];

                    // 2️⃣ Guardar valor
                    await _service.guardarValor(
                      _cabecera!["id_componente"],
                      nuevoId,
                      valor,
                    );
                  }
                } else {
                  // 3️⃣ Actualizar atributo
                  await _service.actualizarAtributo(
                    attr["id_atributo"],
                    nombre,
                    tipo,
                  );

                  // 4️⃣ Guardar valor
                  await _service.guardarValor(
                    _cabecera!["id_componente"],
                    attr["id_atributo"],
                    valor,
                  );
                }
              }

              // Feedback al usuario
              if (mounted) {
                SnackBarUtil.mostrarSnackBarPersonalizado(
                  context: context,
                  mensaje: "Cambios guardados correctamente",
                  icono: Icons.check_circle,
                  duracion: const Duration(seconds: 2),
                );
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Guardar Cambios",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
