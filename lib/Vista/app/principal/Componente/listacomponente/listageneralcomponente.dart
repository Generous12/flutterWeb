import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Controlador/list_Update_Component.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/listacomponente/detallecomponente.dart';
import 'package:proyecto_web/Widgets/navegator.dart';
import 'package:proyecto_web/Widgets/selectores.dart';

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

  String busqueda = '';
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
    if (reset) {
      offset = 0;
      allLoaded = false;
      componentes.clear();
    }

    if (allLoaded) return;

    setState(() {
      loading = offset == 0;
      loadingMore = offset != 0;
    });

    try {
      final nuevos = await service.listar(
        busqueda: busqueda,
        tipo: filtroTipo,
        offset: offset,
        limit: limit,
      );

      if (!mounted) return;

      setState(() {
        if (reset) {
          componentes = nuevos;
        } else {
          componentes.addAll(nuevos);
        }
        offset += nuevos.length;
        if (nuevos.length < limit) allLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadingMore = false;
      });
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
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 238, 238, 238),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
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
                          : const Icon(
                              Iconsax.search_normal,
                              color: Colors.black,
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                CustomChoiceChips(
                  opciones: ["General", "Periféricos", "Componentes"],
                  selected: filtroTipo,
                  onSelected: (tipo) async {
                    if (filtroTipo != tipo) {
                      filtroTipo = tipo;
                      offset = 0;
                      allLoaded = false;
                      setState(() {
                        componentes.clear();
                        loading = true;
                      });
                      await fetchComponentes(reset: true);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: loading && componentes.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  )
                : RefreshIndicator(
                    onRefresh: () => fetchComponentes(reset: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: componentes.length + (loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < componentes.length) {
                          final c = componentes[index];
                          Color stockColor;
                          String stockTexto;
                          if (c.cantidad <= 5) {
                            stockColor = const Color.fromARGB(
                              255,
                              255,
                              137,
                              129,
                            );
                            stockTexto = 'Bajo Stock';
                          } else if (c.cantidad <= 20) {
                            stockColor = const Color.fromARGB(
                              255,
                              255,
                              242,
                              124,
                            );
                            stockTexto = 'Medio Stock';
                          } else {
                            stockColor = const Color.fromARGB(
                              255,
                              123,
                              180,
                              125,
                            );
                            stockTexto = 'Stock Disponible';
                          }
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                navegarConSlideDerecha(
                                  context,
                                  ComponenteDetail(componente: c),
                                  onVolver: () {
                                    setState(() {
                                      fetchComponentes(reset: true);
                                    });
                                  },
                                );
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
                                        : _buildFirstImage(c),
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
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  stockTexto,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${c.cantidad}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
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
          ),
        ],
      ),
    );
  }
}

Widget _buildFirstImage(ComponenteUpdate c) {
  Uint8List? firstBytes;
  int firstIndex = -1;

  for (int i = 0; i < c.imagenesBase64.length; i++) {
    final bytes = c.imagenBytes(i);
    if (bytes != null) {
      firstBytes = bytes;
      firstIndex = i;
      break;
    }
  }

  if (firstBytes == null) {
    return const Icon(Iconsax.folder5, color: Colors.black, size: 50);
  }

  return Hero(
    tag: 'imagen_${c.id}_$firstIndex',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        firstBytes,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50,
            height: 50,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      ),
    ),
  );
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
      print("❌ Imagen[$index] inválida, se usará placeholder: $e");
      return null;
    }
  }
}
