import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:proyecto_web/Controlador/areasService.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/crearAreas.dart';
import 'package:proyecto_web/Vista/app/principal/Areas/detallearea.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class ListaAreasScreen extends StatefulWidget {
  const ListaAreasScreen({super.key});

  @override
  State<ListaAreasScreen> createState() => _ListaAreasScreenState();
}

class _ListaAreasScreenState extends State<ListaAreasScreen> {
  final AreaService _areaService = AreaService();
  final TextEditingController _searchController = TextEditingController();
  List<int> _selectedAreas = [];
  late Future<List<dynamic>> _futureAreas;
  String _busqueda = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _cargarAreas();
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

  Future<void> _eliminarSeleccionadas() async {
    if (_selectedAreas.isEmpty) return;

    await showCustomDialog(
      context: context,
      title: "Eliminar áreas",
      message: "¿Deseas eliminar las áreas padre que no tienen subniveles?",
      confirmButtonText: "Eliminar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: Colors.redAccent,
      onConfirm: () async {
        try {
          final result = await AreaService().eliminarAreasSinSubniveles();
          final count = result["total_eliminadas"] ?? 0;

          setState(() {
            _selectedAreas.clear();
            _cargarAreas(reset: true);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$count áreas eliminadas correctamente ✅")),
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error al eliminar: $e")));
        }
      },
    );
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
            color: _selectedAreas.isNotEmpty
                ? Colors.black
                : Colors.transparent, // 🔹 Cambia color si hay selección
            child: Column(
              children: [
                if (_selectedAreas.isEmpty)
                  // 🔸 AppBar normal con búsqueda
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
                  )
                else
                  // 🔸 AppBar de selección múltiple
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_selectedAreas.length} seleccionadas",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.trash, color: Colors.white),
                        onPressed: _eliminarSeleccionadas,
                      ),
                    ],
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
              return Center(child: Text(" Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No hay áreas registradas"));
            }

            // 🔹 Filtrar para que las áreas sin subniveles salgan primero
            final areas = snapshot.data!;
            final sinSubniveles = areas
                .where(
                  (a) =>
                      (a["total_subareas"] == 0 ||
                          a["total_subareas"] == null) &&
                      (a["total_subsubareas"] == 0 ||
                          a["total_subsubareas"] == null),
                )
                .toList();
            final conSubniveles = areas
                .where(
                  (a) =>
                      (a["total_subareas"] ?? 0) > 0 ||
                      (a["total_subsubareas"] ?? 0) > 0,
                )
                .toList();

            final ordenadas = [...sinSubniveles, ...conSubniveles];

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: ordenadas.length,
                itemBuilder: (context, index) {
                  final area = ordenadas[index];
                  final esSinSubniveles =
                      (area["total_subareas"] ?? 0) == 0 &&
                      (area["total_subsubareas"] ?? 0) == 0;
                  final estaSeleccionada = _selectedAreas.contains(
                    area["id_area"],
                  );

                  return GestureDetector(
                    onLongPress: () {
                      if (esSinSubniveles) {
                        setState(() {
                          if (estaSeleccionada) {
                            _selectedAreas.remove(area["id_area"]);
                          } else {
                            _selectedAreas.add(area["id_area"]);
                          }
                        });
                      }
                    },
                    child: Card(
                      color: estaSeleccionada
                          ? Colors.black.withOpacity(0.1)
                          : Colors.white,
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
                        trailing: esSinSubniveles
                            ? (estaSeleccionada
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.black,
                                    )
                                  : const Icon(Icons.radio_button_unchecked))
                            : const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          if (_selectedAreas.isNotEmpty && esSinSubniveles) {
                            setState(() {
                              if (estaSeleccionada) {
                                _selectedAreas.remove(area["id_area"]);
                              } else {
                                _selectedAreas.add(area["id_area"]);
                              }
                            });
                          } else {
                            navegarConSlideDerecha(
                              context,
                              DetalleAreaScreen(area: area),
                              onVolver: () {
                                setState(() {
                                  _refresh();
                                });
                              },
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: _selectedAreas.isEmpty
            ? FloatingActionButton(
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
              )
            : null,
      ),
    );
  }
}
