import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Controlador/Asignacion/registroasignacion.dart';
import 'package:proyecto_web/Controlador/Componentes/list_Update_Component.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/listacomponente/detallecomponente.dart';
import 'package:proyecto_web/Widgets/estadoscard.dart';
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
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : caseData == null
            ? const Center(child: Text("No se encontró información del case."))
            : RefreshIndicator(
                onRefresh: _cargarDetalle,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      buildMainInfoCard(caseData),
                      const SizedBox(height: 20),
                      if (_componentes.isEmpty)
                        const Text("No hay periféricos asociados."),
                      ..._componentes.map((comp) => buildComponenteCard(comp)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget buildMainInfoCard(Map<String, dynamic> data) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoRow("ID Asignación", data["id_case_asignado"]),
            const Divider(height: 22, color: Colors.black12),

            buildInfoRow("Área Asignada", data["nombre_area_asignada"]),
            const Divider(height: 22, color: Colors.black12),

            buildInfoRow("Fecha Asignación", data["fecha_asignacion"]),
            const Divider(height: 22, color: Colors.black12),

            buildInfoRow("Estado", estadoChip(data["estado_asignacion"])),
          ],
        ),
      ),
    );
  }

  Widget buildComponenteCard(dynamic comp) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
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
        shadowColor: Colors.black12,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.cpu, size: 18, color: Colors.blueAccent),
                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      comp["nombre_tipo"] ?? "Sin nombre",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  Text(
                    comp["codigo_inventario"] ?? "-",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              estadoChip(comp["estado"]),
              const SizedBox(height: 12),

              /// ITEMS REDUCIDOS
              sectionItem(
                icon: Iconsax.tag,
                label: "Estado Asignación",
                value: comp["estado_asignacion"],
              ),

              sectionItem(
                icon: Iconsax.calendar_1,
                label: "Fecha Instalación",
                value: comp["fecha_instalacion"],
              ),

              sectionItem(
                icon: Iconsax.calendar_remove,
                label: "Fecha Retiro",
                value: comp["fecha_retiro"],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String title, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: value is Widget
              ? value
              : Text(
                  value?.toString() ?? "-",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
        ),
      ],
    );
  }

  Widget sectionItem({
    required IconData icon,
    required String label,
    required dynamic value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueAccent),

          const SizedBox(width: 10),

          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          Expanded(
            flex: 6,
            child: Text(
              value?.toString() ?? "-",
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
