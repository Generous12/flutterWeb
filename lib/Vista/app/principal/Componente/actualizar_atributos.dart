import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/atriListar_componente.dart';

class ListaComponentesPage extends StatefulWidget {
  const ListaComponentesPage({super.key});

  @override
  State<ListaComponentesPage> createState() => _ListaComponentesPageState();
}

class _ListaComponentesPageState extends State<ListaComponentesPage> {
  final ComponenteServiceAtributo service = ComponenteServiceAtributo();
  final ScrollController _scrollController = ScrollController();

  List<ComponenteAtributo> _componentes = [];
  bool _cargando = false;
  bool _hayMas = true;
  int _offset = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _cargarMas();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_cargando &&
          _hayMas) {
        _cargarMas();
      }
    });
  }

  Future<void> _cargarMas() async {
    setState(() => _cargando = true);

    try {
      final nuevos = await service.listarComponentes(
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _componentes.addAll(nuevos);
        _offset += nuevos.length;
        if (nuevos.length < _limit) {
          _hayMas = false; // No hay más en backend
        }
      });
    } catch (e) {
      debugPrint("Error al cargar: $e");
    }

    setState(() => _cargando = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Componentes")),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _componentes.length + 1,
        itemBuilder: (context, index) {
          if (index < _componentes.length) {
            final comp = _componentes[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text("${comp.nombreTipo} (${comp.codigoInventario})"),
                subtitle: Text("Atributos: ${comp.totalAtributos}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleComponentePage(
                        idComponente: comp.idComponente,
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return _hayMas
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class DetalleComponentePage extends StatelessWidget {
  final int idComponente;
  const DetalleComponentePage({super.key, required this.idComponente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalle Componente #$idComponente")),
      body: const Center(
        child: Text("Aquí se cargarán los atributos y valores"),
      ),
    );
  }
}
