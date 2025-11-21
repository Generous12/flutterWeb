import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/Asignacion/registroasignacion.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/casesAsignados/detallecase.dart';
import 'package:proyecto_web/Widgets/estadoscard.dart';
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
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Cases de ${widget.nombreArea}",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          toolbarHeight: 48,
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: _cases.map((c) => _buildCaseCard(c)).toList(),
                ),
              ),
      ),
    );
  }

  Widget _buildCaseCard(dynamic c) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 6),
            blurRadius: 14,
            spreadRadius: -2,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            navegarConSlideDerecha(
              context,
              DetalleCaseScreen(idCaseAsignado: c["id_case_asignado"]),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.shade800,
                        Colors.blueGrey.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.desktop_windows_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _chipInfo("Código", "${c["id_case_asignado"]}"),
                          const SizedBox(width: 6),
                          estadoChip(c["estado"]),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Text(
                        "Asignado: ${c["fecha_asignacion"] ?? "-"}",
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chipInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}
