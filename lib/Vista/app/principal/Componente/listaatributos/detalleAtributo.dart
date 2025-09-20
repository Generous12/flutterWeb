import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/Atributos/atriListar_componente.dart';

class DetalleAtributoPage extends StatefulWidget {
  final int idComponente;

  const DetalleAtributoPage({super.key, required this.idComponente});

  @override
  State<DetalleAtributoPage> createState() => _DetalleAtributoPageState();
}

class _DetalleAtributoPageState extends State<DetalleAtributoPage> {
  final ComponenteServiceAtributo _service = ComponenteServiceAtributo();

  Map<String, dynamic>? _cabecera;
  List<AtributoDetalle> _atributos = [];
  bool _cargando = true;
  String? _error;

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
        _atributos = data["atributos"];
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle Componente")),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Error: $_error"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ID: ${_cabecera?["id_componente"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Tipo: ${_cabecera?["nombre_tipo"]}"),
                          Text("Código: ${_cabecera?["codigo_inventario"]}"),
                        ],
                      ),
                    ),
                  ),

                  // Lista atributos
                  const Text(
                    "Atributos:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _atributos.length,
                    itemBuilder: (context, index) {
                      final atr = _atributos[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(atr.nombreAtributo),
                          subtitle: Text("Tipo: ${atr.tipoDato}"),
                          trailing: Text(
                            atr.valor,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
