import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/Asignacion/registroasignacion.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/casesAsignados/detallecase.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class CasesDeAreaScreen extends StatefulWidget {
  final int idArea;
  final String nombreArea;

  const CasesDeAreaScreen({
    Key? key,
    required this.idArea,
    required this.nombreArea,
  }) : super(key: key);

  @override
  State<CasesDeAreaScreen> createState() => _CasesDeAreaScreenState();
}

class _CasesDeAreaScreenState extends State<CasesDeAreaScreen> {
  final RegistrarAsignacionService _service = RegistrarAsignacionService();
  bool _cargando = true;
  List<dynamic> _cases = [];

  @override
  void initState() {
    super.initState();
    _cargarCases();
  }

  Future<void> _cargarCases() async {
    try {
      setState(() => _cargando = true);
      final data = await _service.listarCasesPorArea(idArea: widget.idArea);
      setState(() {
        _cases = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar cases: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Cases de ${widget.nombreArea}",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _cases.isEmpty
            ? const Center(
                child: Text(
                  "No hay cases registrados.",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : RefreshIndicator(
                onRefresh: _cargarCases,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cases.length,
                  itemBuilder: (context, index) {
                    final c = _cases[index];
                    return _buildCaseCard(c);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildCaseCard(dynamic c) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          navegarConSlideDerecha(
            context,
            DetalleCaseScreen(idCaseAsignado: c["id_case_asignado"]),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              /// ✅ Ícono grande a la izquierda
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.desktop_windows, size: 32),
              ),

              const SizedBox(width: 16),

              /// ✅ Información del Case
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c["nombre_case"] ?? "Case sin nombre",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 4),

                    _itemInfo("Código", c["id_case_asignado"]),
                    _itemInfo("Estado", c["estado"]),
                    _itemInfo("Fecha", c["fecha_asignacion"]),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        "$label: ${value ?? '-'}",
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
      ),
    );
  }
}
