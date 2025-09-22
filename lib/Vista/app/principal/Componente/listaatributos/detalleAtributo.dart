import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Controlador/Atributos/atriListar_componente.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
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

  // Tipos y abreviaturas
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
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Atributos", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.blueAccent),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.box,
                                  color: Colors.blueAccent,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "ID: ${_cabecera?["id_componente"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.category,
                                  color: Colors.blueAccent,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Tipo: ${_cabecera?["nombre_tipo"]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.code,
                                  color: Colors.blueAccent,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Código: ${_cabecera?["codigo_inventario"]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      "Atributos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
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
                            setState(() {
                              atributos.removeAt(index);
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
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
      ),
    );
  }
}
