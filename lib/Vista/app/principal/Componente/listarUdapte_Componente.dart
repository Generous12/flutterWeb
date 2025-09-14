import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:proyecto_web/Controlador/list_Update_Component.dart';
import 'package:proyecto_web/Vista/app/principal/Componente/list_updateDetailComponent.dart';

class ComponentesList extends StatefulWidget {
  const ComponentesList({Key? key}) : super(key: key);

  @override
  State<ComponentesList> createState() => _ComponentesListState();
}

class _ComponentesListState extends State<ComponentesList> {
  final ComponenteUpdateService service = ComponenteUpdateService();
  final ScrollController _scrollController = ScrollController();

  List<ComponenteUpdate> componentes = [];
  bool loading = true;
  bool loadingMore = false;
  bool allLoaded = false;

  String busqueda = '';
  int offset = 0;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    fetchComponentes();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      if (offset == 0)
        loading = true;
      else
        loadingMore = true;
    });

    try {
      final nuevos = await service.listar(
        busqueda: busqueda,
        offset: offset,
        limit: limit,
      );

      if (nuevos.length < limit) allLoaded = true;

      setState(() {
        componentes.addAll(nuevos);
        offset += limit;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)], // degradado azul
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Iconsax.arrow_left_2,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text(
                  "Componentes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Iconsax.search_normal,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () async {
                    final resultado = await showSearch(
                      context: context,
                      delegate: ComponentesSearch(
                        componentes: componentes,
                        service: service,
                        clearIcon: Icons.close,
                        backIcon: Icons.arrow_back_ios_new,
                      ),
                    );
                    if (resultado != null && resultado.isNotEmpty) {
                      setState(() {
                        busqueda = resultado;
                      });
                      fetchComponentes(reset: true);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      body: loading && componentes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => fetchComponentes(reset: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: componentes.length + (loadingMore ? 1 : 0),
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  if (index < componentes.length) {
                    final c = componentes[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ComponenteDetail(componente: c),
                            ),
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
                                  : SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: c.imagenesBase64.length,
                                        itemBuilder: (_, i) {
                                          final bytes = c.imagenBytes(i);
                                          return bytes != null
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 6,
                                                      ),
                                                  child: Hero(
                                                    tag: 'imagen_${c.id}_$i',
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.memory(
                                                        bytes,
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                );
                                        },
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      '${c.codigoInventario} • Stock: ${c.cantidad}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Iconsax.arrow_right_3,
                                color: Colors.blue,
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
    );
  }
}

/// Adaptación para Base64 segura
extension ComponenteUpdateExtension on ComponenteUpdate {
  Uint8List? imagenBytes(int index) {
    if (index < 0 || index >= imagenesBase64.length) return null;
    final base64Str = imagenesBase64[index]
        .replaceAll('\n', '')
        .replaceAll(' ', '');
    try {
      return base64Decode(base64Str);
    } catch (_) {
      return null;
    }
  }
}

/// Búsqueda por nombre o código
class ComponentesSearch extends SearchDelegate<String> {
  final List<ComponenteUpdate> componentes;
  final ComponenteUpdateService service;
  final IconData clearIcon;
  final IconData backIcon;

  ComponentesSearch({
    required this.componentes,
    required this.service,
    this.clearIcon = Icons.close,
    this.backIcon = Icons.arrow_back_ios_new,
  }) : super(
         searchFieldLabel: 'Buscar por nombre o inventario',
         textInputAction: TextInputAction.search,
       );

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(clearIcon, color: Colors.black),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: Icon(backIcon, color: Colors.black),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = componentes
        .where(
          (c) =>
              c.nombreTipo.toLowerCase().contains(query.toLowerCase()) ||
              c.codigoInventario.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron componentes',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final c = results[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            leading: c.imagenBytes(0) != null
                ? Hero(
                    tag: 'imagen_${c.id}_0',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        c.imagenBytes(0)!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const Icon(Iconsax.folder5, color: Colors.black, size: 40),
            title: Text(
              c.nombreTipo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              'Inventario: ${c.codigoInventario} • Stock: ${c.cantidad}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            trailing: const Icon(Iconsax.arrow_right_3, color: Colors.blue),
            onTap: () => close(context, query),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = componentes
        .where(
          (c) =>
              c.nombreTipo.toLowerCase().contains(query.toLowerCase()) ||
              c.codigoInventario.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: suggestions.length,
      itemBuilder: (context, i) {
        final c = suggestions[i];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            title: Text(
              c.nombreTipo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Inventario: ${c.codigoInventario}'),
            onTap: () => close(context, query),
          ),
        );
      },
    );
  }
}
