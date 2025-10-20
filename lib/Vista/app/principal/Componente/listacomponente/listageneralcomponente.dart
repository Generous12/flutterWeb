import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Asignacion/Carrito/CarritocaseService.dart';
import 'package:proyecto_web/Controlador/Componentes/eliminar_componente.dart';
import 'package:proyecto_web/Controlador/Componentes/list_Update_Component.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/listacomponente/detallecomponente.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/navegator.dart';

class ComponentesList extends StatefulWidget {
  const ComponentesList({Key? key}) : super(key: key);

  @override
  State<ComponentesList> createState() => _ComponentesListState();
}

class _ComponentesListState extends State<ComponentesList> {
  final ComponenteUpdateService service = ComponenteUpdateService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<ComponenteUpdate> componentes = [];
  bool loading = true;
  bool loadingMore = false;
  bool allLoaded = false;
  Set<int> seleccionados = {};
  bool modoSeleccion = false;
  String busqueda = '';
  int _lastRequestId = 0;
  int offset = 0;
  final int limit = 20;
  String filtroTipo = 'General';
  @override
  void initState() {
    super.initState();
    fetchComponentes();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchComponentes({bool reset = false}) async {
    final currentRequestId = ++_lastRequestId;

    if (reset) {
      offset = 0;
      allLoaded = false;
      componentes.clear();
    }

    if (allLoaded) return;
    final isInitialLoad = offset == 0;
    setState(() {
      loading = isInitialLoad;
      loadingMore = !isInitialLoad;
    });

    try {
      final nuevos = await service.listar(
        busqueda: busqueda,
        tipo: filtroTipo,
        offset: offset,
        limit: limit,
      );

      if (currentRequestId != _lastRequestId) return;

      if (!mounted) return;
      setState(() {
        if (reset) {
          componentes = nuevos;
        } else {
          componentes.addAll(nuevos);
        }
        offset += nuevos.length;
        allLoaded = nuevos.length < limit;
        loading = false;
        loadingMore = false;
      });
    } catch (e) {
      if (currentRequestId != _lastRequestId) return;
      if (!mounted) return;
      setState(() {
        loading = false;
        loadingMore = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !loadingMore &&
        !allLoaded) {
      fetchComponentes();
    }
  }

  void _onSearchChanged(String value) async {
    busqueda = value;
    offset = 0;
    allLoaded = false;
    setState(() {
      componentes.clear();
      loading = true;
    });

    try {
      final nuevos = await service.listar(
        busqueda: busqueda,
        tipo: filtroTipo,
        offset: offset,
        limit: limit,
      );

      setState(() {
        componentes = nuevos;
        offset += nuevos.length;
        if (nuevos.length < limit) allLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
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
                        if (modoSeleccion)
                          IconButton(
                            icon: const Icon(
                              Iconsax.close_circle,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                seleccionados.clear();
                                modoSeleccion = false;
                              });
                            },
                          ),
                        Expanded(
                          child: modoSeleccion
                              ? Text(
                                  "Seleccionados ${seleccionados.length}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : TextField(
                                  controller: _searchController,
                                  onChanged: _onSearchChanged,
                                  decoration: InputDecoration(
                                    hintText: 'Buscar componente',
                                    border: InputBorder.none,
                                    prefixIcon: IconButton(
                                      icon: const Icon(
                                        Iconsax.arrow_left,
                                        color: Colors.black,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
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
                        IconButton(
                          icon: Icon(
                            modoSeleccion
                                ? Iconsax.trash
                                : filtroTipo == "General"
                                ? Iconsax.filter
                                : Iconsax.close_circle,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            if (modoSeleccion) {
                              if (seleccionados.isEmpty) return;

                              final confirmar = await showCustomDialog(
                                context: context,
                                title: "Confirmar eliminación",
                                message:
                                    "¿Deseas eliminar los ${seleccionados.length} componentes seleccionados?",
                                confirmButtonText: "Sí",
                                cancelButtonText: "No",
                              );

                              if (confirmar == true) {
                                final service = EliminarComponenteService();
                                final idsTipo = seleccionados
                                    .map(
                                      (id) => componentes
                                          .firstWhere((c) => c.id == id)
                                          .idTipo,
                                    )
                                    .toSet()
                                    .toList();

                                final result = await service.eliminarTipos(
                                  idsTipo,
                                );

                                await showCustomDialog(
                                  context: context,
                                  title: result['success'] ? "Éxito" : "Error",
                                  message: result['message'],
                                  confirmButtonText: "Cerrar",
                                );

                                if (result['success']) {
                                  setState(() {
                                    seleccionados.clear();
                                    modoSeleccion = false;
                                    componentes.clear();
                                    loading = true;
                                  });
                                  await fetchComponentes(reset: true);
                                }
                              }
                            } else {
                              if (filtroTipo != "General") {
                                setState(() {
                                  filtroTipo = "General";
                                  offset = 0;
                                  allLoaded = false;
                                  componentes.clear();
                                  loading = true;
                                });
                                await fetchComponentes(reset: true);
                              } else {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                Iconsax.mouse,
                                              ),
                                              title: const Text("Periféricos"),
                                              onTap: () {
                                                Navigator.pop(context);
                                                if (filtroTipo !=
                                                    "Periféricos") {
                                                  filtroTipo = "Periféricos";
                                                  offset = 0;
                                                  allLoaded = false;
                                                  fetchComponentes(reset: true);
                                                }
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Iconsax.cpu),
                                              title: const Text("Componentes"),
                                              onTap: () {
                                                Navigator.pop(context);
                                                if (filtroTipo !=
                                                    "Componentes") {
                                                  filtroTipo = "Componentes";
                                                  offset = 0;
                                                  allLoaded = false;

                                                  fetchComponentes(reset: true);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: loading && componentes.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(0),
                      itemCount: componentes.length + (loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < componentes.length) {
                          final c = componentes[index];
                          Color stockColor;
                          String stockTexto;

                          switch (c.estado) {
                            case "Mantenimiento":
                              stockColor = const Color(0xFFFF6B6B);
                              stockTexto = 'En Mantenimiento';
                              break;

                            case "En uso":
                              stockColor = const Color(0xFFFFC107);
                              stockTexto = 'En Uso';
                              break;

                            case "Dañado":
                              stockColor = const Color(0xFFB71C1C);
                              stockTexto = 'Dañado';
                              break;

                            case "Arreglado":
                              stockColor = const Color(0xFF42A5F5);
                              stockTexto = 'Arreglado';
                              break;

                            case "Pendiente":
                              stockColor = const Color(0xFF9C27B0);
                              stockTexto = 'Pendiente de revisión';
                              break;

                            default:
                              stockColor = const Color(0xFF2ECC71);
                              stockTexto = 'Disponible';
                          }

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(vertical: 0),
                            color: seleccionados.contains(c.id)
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                if (modoSeleccion) {
                                  setState(() {
                                    if (seleccionados.contains(c.id)) {
                                      seleccionados.remove(c.id);
                                      if (seleccionados.isEmpty)
                                        modoSeleccion = false;
                                    } else {
                                      seleccionados.add(c.id);
                                    }
                                  });
                                } else {
                                  navegarConSlideDerecha(
                                    context,
                                    ComponenteDetail(componente: c),
                                    onVolver: () {
                                      setState(() {
                                        fetchComponentes(reset: true);
                                      });
                                    },
                                  );
                                }
                              },
                              onLongPress: () {
                                setState(() {
                                  modoSeleccion = true;
                                  seleccionados.add(c.id);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    c.imagenesBase64.isEmpty
                                        ? const Icon(
                                            Iconsax.folder5,
                                            color: Colors.black,
                                            size: 50,
                                          )
                                        : ComponenteImageHero(c: c),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.nombreTipo,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            c.codigoInventario,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: stockColor,
                                              borderRadius:
                                                  BorderRadius.circular(90),
                                            ),
                                            child: Center(
                                              child: Text(
                                                stockTexto,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Iconsax.arrow_right_3,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ComponenteImageHero extends StatelessWidget {
  final ComponenteUpdate c;

  const ComponenteImageHero({super.key, required this.c});

  Uint8List? _getFirstBytes() {
    for (int i = 0; i < c.imagenesBase64.length; i++) {
      final bytes = c.imagenBytes(i);
      if (bytes != null) return bytes;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final firstBytes = _getFirstBytes();
    int firstIndex = firstBytes != null
        ? c.imagenesBase64.indexWhere(
            (b64) => c.imagenBytes(c.imagenesBase64.indexOf(b64)) != null,
          )
        : -1;

    if (firstBytes == null) {
      return const Icon(Iconsax.folder5, color: Colors.black, size: 50);
    }

    return Hero(
      tag: 'imagen_${c.id}_$firstIndex',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          firstBytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}

extension ComponenteUpdateExtension on ComponenteUpdate {
  Uint8List? imagenBytes(int index) {
    if (index < 0 || index >= imagenesBase64.length) return null;

    String? base64Str = imagenesBase64[index];
    if (base64Str == null) return null;

    base64Str = base64Str.trim();
    if (base64Str.isEmpty) return null;

    try {
      final regex = RegExp(r'data:image/[^;]+;base64,');
      base64Str = base64Str.replaceAll(regex, '');

      final mod = base64Str.length % 4;
      if (mod != 0) {
        base64Str = base64Str.padRight(base64Str.length + (4 - mod), '=');
      }

      return base64Decode(base64Str);
    } catch (e) {
      return null;
    }
  }
}

//MODO ASIGNACION DE COMPONENTES O PERIFERICOS CON AREA
class ComponentesCarrito extends StatefulWidget {
  const ComponentesCarrito({super.key});

  @override
  State<ComponentesCarrito> createState() => _ComponentesCarritonState();
}

class _ComponentesCarritonState extends State<ComponentesCarrito> {
  final ComponenteUpdateService service = ComponenteUpdateService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<Set<int>> seleccionadosNotifier = ValueNotifier({});
  final ValueNotifier<bool> modoSeleccionNotifier = ValueNotifier(false);

  List<ComponenteUpdate> componentes = [];
  bool loading = true;
  bool loadingMore = false;
  bool allLoaded = false;
  Set<int> seleccionados = {};
  bool modoSeleccion = false;
  String busqueda = '';
  int _lastRequestId = 0;
  int offset = 0;
  final int limit = 20;
  String filtroTipo = 'General';
  String? filtroEstadoAsignacion;

  @override
  void initState() {
    super.initState();
    fetchComponentes();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchComponentes({bool reset = false}) async {
    final currentRequestId = ++_lastRequestId;

    if (reset) {
      offset = 0;
      allLoaded = false;
      componentes.clear();
    }

    if (allLoaded) return;
    final isInitialLoad = offset == 0;
    setState(() {
      loading = isInitialLoad;
      loadingMore = !isInitialLoad;
    });

    try {
      final nuevos = await service.listar(
        busqueda: busqueda,
        tipo: filtroTipo,
        offset: offset,
        limit: limit,
        estadoAsignacion: filtroEstadoAsignacion,
      );

      if (currentRequestId != _lastRequestId) return;
      if (!mounted) return;

      setState(() {
        if (reset) {
          componentes = nuevos;
        } else {
          componentes.addAll(nuevos);
        }
        offset += nuevos.length;
        allLoaded = nuevos.length < limit;
        loading = false;
        loadingMore = false;
      });
    } catch (e) {
      if (currentRequestId != _lastRequestId) return;
      if (!mounted) return;
      setState(() {
        loading = false;
        loadingMore = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !loadingMore &&
        !allLoaded) {
      fetchComponentes();
    }
  }

  void _onSearchChanged(String value) async {
    busqueda = value;
    offset = 0;
    allLoaded = false;
    setState(() {
      componentes.clear();
      loading = true;
    });

    try {
      final nuevos = await service.listar(
        busqueda: busqueda,
        tipo: filtroTipo,
        offset: offset,
        limit: limit,
      );

      setState(() {
        componentes = nuevos;
        offset += nuevos.length;
        if (nuevos.length < limit) allLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseProv = Provider.of<CaseProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
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
                        if (modoSeleccion)
                          IconButton(
                            icon: const Icon(
                              Iconsax.close_circle,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                seleccionados.clear();
                                modoSeleccion = false;
                              });
                            },
                          ),
                        Expanded(
                          child: modoSeleccion
                              ? Text(
                                  "Seleccionados ${seleccionados.length}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : TextField(
                                  controller: _searchController,
                                  onChanged: _onSearchChanged,
                                  decoration: InputDecoration(
                                    hintText: 'Buscar componente',
                                    border: InputBorder.none,
                                    prefixIcon: IconButton(
                                      icon: const Icon(
                                        Iconsax.arrow_left,
                                        color: Colors.black,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
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
                        IconButton(
                          icon: Icon(
                            modoSeleccion
                                ? Iconsax.add_circle
                                : filtroTipo == "General"
                                ? Iconsax.filter
                                : Iconsax.close_circle,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            if (modoSeleccion) {
                              if (seleccionados.isEmpty) return;
                              for (final id in seleccionados) {
                                final comp = componentes.firstWhere(
                                  (c) => c.id == id,
                                );
                                await caseProv.agregarComponente(context, comp);
                              }
                              setState(() {
                                seleccionados.clear();
                                modoSeleccion = false;
                              });
                            } else {
                              if (filtroTipo != "General") {
                                setState(() {
                                  filtroTipo = "General";
                                  componentes.clear();
                                  loading = true;
                                });
                                fetchComponentes(reset: true);
                              } else {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                Iconsax.mouse,
                                              ),
                                              title: const Text("Periféricos"),
                                              onTap: () {
                                                Navigator.pop(context);
                                                filtroTipo = "Periféricos";
                                                fetchComponentes(reset: true);
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Iconsax.cpu),
                                              title: const Text("Componentes"),
                                              onTap: () {
                                                Navigator.pop(context);
                                                filtroTipo = "Componentes";
                                                fetchComponentes(reset: true);
                                              },
                                            ),
                                            const Divider(),
                                            const Text(
                                              "Filtrar por estado de asignación",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            ListTile(
                                              title: const Text("Asignado"),
                                              onTap: () {
                                                filtroEstadoAsignacion =
                                                    "Asignado";
                                                Navigator.pop(context);
                                                fetchComponentes(reset: true);
                                              },
                                            ),
                                            ListTile(
                                              title: const Text("No Asignado"),
                                              onTap: () {
                                                filtroEstadoAsignacion =
                                                    "No Asignado";
                                                Navigator.pop(context);
                                                fetchComponentes(reset: true);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: loading && componentes.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: componentes.length + (loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= componentes.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final c = componentes[index];
                        final seleccionado = seleccionados.contains(c.id);
                        final yaAgregado = caseProv.componentesSeleccionados
                            .any((comp) => comp.id == c.id);

                        Color stockColor;
                        String stockTexto;
                        switch (c.estado) {
                          case "Mantenimiento":
                            stockColor = const Color(0xFFFF1100);
                            stockTexto = 'Está en Mantenimiento';
                            break;
                          case "En uso":
                            stockColor = const Color(0xFFFFE600);
                            stockTexto = 'Está en Uso';
                            break;
                          case "Dañado":
                            stockColor = const Color(0xFF800000);
                            stockTexto = 'Está Dañado';
                            break;
                          case "Arreglado":
                            stockColor = const Color(0xFF0066CC);
                            stockTexto = 'Ha sido Arreglado';
                            break;
                          default:
                            stockColor = const Color(0xFF00A706);
                            stockTexto = 'Disponible';
                        }
                        final asignado =
                            (c.estadoAsignacion?.toLowerCase() == "asignado");
                        final asignColor = asignado
                            ? Colors.red
                            : Colors.grey[500];
                        final asignTexto = asignado
                            ? "Asignado"
                            : "No Asignado";
                        return Opacity(
                          opacity: yaAgregado ? 0.5 : 1.0,
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            color: seleccionado
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.white,
                            child: InkWell(
                              onTap: yaAgregado
                                  ? null
                                  : () {
                                      if (modoSeleccion) {
                                        setState(() {
                                          if (seleccionado) {
                                            seleccionados.remove(c.id);
                                            if (seleccionados.isEmpty)
                                              modoSeleccion = false;
                                          } else {
                                            seleccionados.add(c.id);
                                          }
                                        });
                                      }
                                    },
                              onLongPress: yaAgregado
                                  ? null
                                  : () {
                                      setState(() {
                                        modoSeleccion = true;
                                        seleccionados.add(c.id);
                                      });
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    ComponenteImageHero(c: c),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.nombreTipo,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  c.codigoInventario,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: asignColor!
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  asignTexto,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: asignColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: stockColor,
                                              borderRadius:
                                                  BorderRadius.circular(90),
                                            ),
                                            child: Center(
                                              child: Text(
                                                stockTexto,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (yaAgregado)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
