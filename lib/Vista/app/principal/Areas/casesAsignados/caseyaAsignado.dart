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
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),

          title: Text(
            "Cases de ${widget.nombreArea}",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),

        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _cases.isEmpty
            ? const Center(child: Text("No hay cases registrados."))
            : RefreshIndicator(
                onRefresh: _cargarCases,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cases.length,
                  itemBuilder: (context, index) {
                    final c = _cases[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          c["nombre_case"] ?? "Case sin nombre",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Código: ${c["id_case_asignado"] ?? '-'}"),
                            Text("Estado: ${c["estado"] ?? '-'}"),
                            Text("Fecha: ${c["fecha_asignacion"] ?? '-'}"),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          navegarConSlideDerecha(
                            context,
                            DetalleCaseScreen(
                              idCaseAsignado: c["id_case_asignado"],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
