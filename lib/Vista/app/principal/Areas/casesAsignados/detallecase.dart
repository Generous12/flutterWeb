import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/Asignacion/registroasignacion.dart';
import 'package:proyecto_web/Controlador/Componentes/list_Update_Component.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/listacomponente/detallecomponente.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

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
        backgroundColor: const Color(0xFFF4F5F7),
        appBar: AppBar(
          toolbarHeight: 48,
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Detalle del Case",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
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
                    children: [
                      _buildMainInfoCard(caseData),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Objetos Asociados", Icons.devices),

                      const SizedBox(height: 10),

                      if (_componentes.isEmpty)
                        const Text("No hay periféricos asociados."),
                      ..._componentes.map((comp) => _buildComponenteCard(comp)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMainInfoCard(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Información General", Icons.info),
            const SizedBox(height: 12),

            _infoItem("ID Asignación", data["id_case_asignado"]),
            _infoItem("Área Asignada", data["nombre_area_asignada"]),
            _infoItem("Fecha de Asignación", data["fecha_asignacion"]),
            _infoItem("Estado", data["estado_asignacion"]),
          ],
        ),
      ),
    );
  }

  Widget _buildComponenteCard(dynamic comp) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        final componente = ComponenteUpdate.fromJson({
          'id_componente': comp['id_componente'],
          'id_tipo': comp['id_tipo'] ?? 0,
          'codigo_inventario': comp['codigo_inventario'] ?? '',
          'nombre_tipo': comp['nombre_tipo'] ?? '',
          'tipo_nombre': comp['nombre_componente'] ?? '',
          'estado': comp['estado'] ?? 'Desconocido',
          'estado_asignacion': comp['estado_asignacion'] ?? '',
        });

        navegarConSlideDerecha(
          context,
          ComponenteDetailAsignacion(componente: componente),
        );
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      comp["nombre_tipo"] ?? "Sin nombre",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    comp["codigo_inventario"] ?? "-",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _infoSub("Estado Asignación", comp["estado_asignacion"]),
              _infoSub("Fecha Instalación", comp["fecha_instalacion"]),
              _infoSub("Fecha Retiro", comp["fecha_retiro"]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: Colors.blueGrey.shade300),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Text(value?.toString() ?? "-", style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _infoSub(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        "$label: ${value ?? '-'}",
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
