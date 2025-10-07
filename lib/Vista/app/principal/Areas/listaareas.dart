import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:proyecto_web/Controlador/areasService.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/crearAreas.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/detallearea.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class ListaAreasScreen extends StatefulWidget {
  const ListaAreasScreen({super.key});

  @override
  State<ListaAreasScreen> createState() => _ListaAreasScreenState();
}

class _ListaAreasScreenState extends State<ListaAreasScreen> {
  final AreaService _areaService = AreaService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<dynamic>> _futureAreas;
  String _busqueda = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _cargarAreas(); // Siempre se llama al iniciar
  }

  void _cargarAreas({bool reset = false}) {
    setState(() {
      _futureAreas = _areaService.listarAreasPadresGeneral(
        limit: 20,
        offset: 0,
        busqueda: _busqueda,
      );
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _busqueda = query.trim();
    });
    _cargarAreas();
  }

  Future<void> _refresh() async {
    _cargarAreas();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 238, 238, 238),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Buscar área padre',
                            border: InputBorder.none,
                            prefixIcon: IconButton(
                              icon: const Icon(
                                Iconsax.arrow_left,
                                color: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      LucideIcons.eraser,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : const Icon(
                                    Iconsax.search_normal,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _futureAreas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("❌ Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No hay áreas registradas"));
            }

            final areas = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: areas.length,
                itemBuilder: (context, index) {
                  final area = areas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        area["nombre_area"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "Subáreas: ${area["total_subareas"]}  •  Sub-subáreas: ${area["total_subsubareas"]}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        navegarConSlideDerecha(
                          context,
                          DetalleAreaScreen(area: area),
                          onVolver: () {
                            setState(() {
                              _refresh();
                            });
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          shape: const CircleBorder(),
          onPressed: () {
            navegarConSlideDerecha(
              context,
              CrearAreaScreen(),
              onVolver: () {
                setState(() {
                  _cargarAreas(reset: true);
                });
              },
            );
          },
          child: const Icon(Iconsax.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
