import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Controlador/Atributos/atriListar_componente.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/listaatributos/detalleAtributo.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class ComponentesPageAtributo extends StatefulWidget {
  const ComponentesPageAtributo({super.key});

  @override
  State<ComponentesPageAtributo> createState() =>
      _ComponentesPageAtributoState();
}

class _ComponentesPageAtributoState extends State<ComponentesPageAtributo> {
  final _service = ComponenteServiceAtributo();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<ComponenteAtributo> _componentes = [];
  int _limit = 10;
  int _offset = 0;
  bool _cargando = false;
  bool _hayMas = true;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarComponentes();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_cargando &&
          _hayMas) {
        _cargarComponentes();
      }
    });
  }

  void _onSearchChanged(String value) {
    _busqueda = value;
    _offset = 0;
    _componentes.clear();
    _hayMas = true;
    _cargarComponentes();
  }

  Future<void> _cargarComponentes({bool reset = false}) async {
    if (_cargando) return;

    if (reset) {
      setState(() {
        _componentes.clear();
        _offset = 0;
        _hayMas = true;
      });
    }

    if (!_hayMas) return;

    setState(() => _cargando = true);

    try {
      final lista = await _service.listarComponentes(
        limit: _limit,
        offset: _offset,
        busqueda: _busqueda.isEmpty ? null : _busqueda,
      );

      setState(() {
        _componentes.addAll(lista);
        _offset += lista.length;
        _hayMas = lista.length == _limit;
      });
    } catch (e) {
      debugPrint("Error al cargar componentes: $e");
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF000000), Color.fromARGB(255, 0, 0, 0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(0),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Iconsax.arrow_left,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Componentes Atributo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Buscar componente',
                      border: InputBorder.none,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : const Icon(Iconsax.search_normal),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _componentes.length + 1,
              itemBuilder: (context, index) {
                if (index < _componentes.length) {
                  final comp = _componentes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black45,
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Iconsax.box,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        "${comp.nombreTipo}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        "Código: ${comp.codigoInventario}\nAtributos: ${comp.totalAtributos}",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(
                        Iconsax.arrow_right_3,
                        color: Colors.blueAccent,
                        size: 24,
                      ),
                      onTap: () {
                        navegarConSlideDerecha(
                          context,
                          DetalleAtributoPage(idComponente: comp.idComponente),
                          onVolver: () {
                            _cargarComponentes(reset: true);
                          },
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
          ),
        ],
      ),
    );
  }
}
