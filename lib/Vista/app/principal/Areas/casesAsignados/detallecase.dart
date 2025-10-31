import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/Asignacion/registroasignacion.dart';

class DetalleCaseScreen extends StatefulWidget {
  final int idCaseAsignado;

  const DetalleCaseScreen({Key? key, required this.idCaseAsignado})
    : super(key: key);

  @override
  State<DetalleCaseScreen> createState() => _DetalleCaseScreenState();
}

class _DetalleCaseScreenState extends State<DetalleCaseScreen> {
  final RegistrarAsignacionService _service = RegistrarAsignacionService();
  bool _cargando = true;
  Map<String, dynamic>? _case;
  List<dynamic> _componentes = [];

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    try {
      setState(() => _cargando = true);

      final data = await _service.detalleCaseAsignado(widget.idCaseAsignado);

      setState(() {
        _case = data["case"];
        _componentes = data["componentes"] ?? [];
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar detalle: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseData = _case;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Detalle del Case"),
          backgroundColor: Colors.black,
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : caseData == null
            ? const Center(child: Text("No se encontró información del case."))
            : RefreshIndicator(
                onRefresh: _cargarDetalle,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Información General"),
                      const SizedBox(height: 8),
                      _infoRow("ID Asignación", caseData["id_case_asignado"]),
                      _infoRow("Nombre del Case", caseData["nombre_case"]),
                      _infoRow(
                        "Código Inventario",
                        caseData["codigo_inventario"],
                      ),
                      _infoRow("Marca", caseData["marca"]),
                      _infoRow("Modelo", caseData["modelo"]),
                      _infoRow("Serie", caseData["serie"]),
                      _infoRow(
                        "Estado Asignación",
                        caseData["estado_asignacion"],
                      ),
                      _infoRow(
                        "Área Asignada",
                        caseData["nombre_area_asignada"],
                      ),
                      _infoRow(
                        "Fecha de Asignación",
                        caseData["fecha_asignacion"],
                      ),
                      _infoRow("Estado", caseData["estado"]),
                      const Divider(height: 32),

                      _buildSectionTitle("Componentes Asociados"),
                      const SizedBox(height: 8),

                      if (_componentes.isEmpty)
                        const Text("No hay componentes asociados."),
                      ..._componentes.map(
                        (comp) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              comp["nombre_componente"] ?? "Sin nombre",
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Código Inventario: ${comp["codigo_inventario"] ?? '-'}",
                                ),

                                Text(
                                  "Estado Asignación: ${comp["estado_asignacion"] ?? '-'}",
                                ),
                                Text(
                                  "Fecha Instalación: ${comp["fecha_instalacion"] ?? '-'}",
                                ),
                                Text(
                                  "Fecha Retiro: ${comp["fecha_retiro"] ?? '-'}",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.toString() ?? "-")),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }
}
