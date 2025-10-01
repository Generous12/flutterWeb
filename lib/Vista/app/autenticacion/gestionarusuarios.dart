import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:proyecto_web/Controlador/Usuarios/gestiousuario.dart';
import 'package:proyecto_web/Widgets/dropdownbutton.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({Key? key}) : super(key: key);

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final GestiousuarioService usuarioService = GestiousuarioService();
  List<Map<String, dynamic>> usuarios = [];
  bool loading = true;
  bool loadingMore = false;
  int paginaActual = 1;
  bool modoSeleccion = false;
  List<String> seleccionados = [];
  final TextEditingController _searchController = TextEditingController();

  bool hasMore = true;

  String busqueda = '';
  String estadoFiltro = '';

  final ScrollController _scrollController = ScrollController();

  final List<String> roles = ['Admin', 'Practicante'];
  final List<String> estados = ['Activo', 'Inactivo'];

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
    _scrollController.addListener(_scrollListener);
  }

  void _onSearchChanged(String value) {
    busqueda = value;
    paginaActual = 1;
    usuarios.clear();
    hasMore = true;
    fetchUsuarios(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchUsuarios({bool reset = false}) async {
    if (reset) {
      paginaActual = 1;
      hasMore = true;
      usuarios.clear();
    }

    if (!hasMore) return;

    setState(() {
      if (paginaActual == 1) {
        loading = true;
      } else {
        loadingMore = true;
      }
    });

    try {
      final nuevosUsuarios = await usuarioService.listarUsuarios(
        busqueda: busqueda,
        estadoFiltro: estadoFiltro,
        pagina: paginaActual,
      );

      setState(() {
        usuarios.addAll(nuevosUsuarios);
        hasMore = nuevosUsuarios.length == 10; // 10 por página
        paginaActual++;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al listar usuarios: $e')));
    } finally {
      setState(() {
        loading = false;
        loadingMore = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !loadingMore &&
        hasMore) {
      fetchUsuarios();
    }
  }

  Future<void> actualizarUsuario(
    int index,
    String nuevoRol,
    String nuevoEstado,
  ) async {
    try {
      bool success = await usuarioService.actualizarUsuario(
        usuarios[index]['id_usuario'],
        nuevoRol,
        nuevoEstado,
      );
      if (success) {
        setState(() {
          usuarios[index]['rol'] = nuevoRol;
          usuarios[index]['estado'] = nuevoEstado;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Búsqueda y filtro
            // Búsqueda y filtro con lógica avanzada
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                            icon: const Icon(Icons.close, color: Colors.black),
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
                                    hintText: 'Buscar por nombre o código',
                                    border: InputBorder.none,
                                    prefixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.black,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              _onSearchChanged('');
                                            },
                                          )
                                        : const Icon(
                                            Icons.search,
                                            color: Colors.black,
                                          ),
                                  ),
                                ),
                        ),
                        IconButton(
                          icon: Icon(
                            modoSeleccion
                                ? Icons.delete
                                : estadoFiltro.isEmpty
                                ? Icons.filter_alt
                                : Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            if (modoSeleccion) {
                              // Lógica de eliminación múltiple
                              if (seleccionados.isEmpty) return;

                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Confirmar eliminación"),
                                  content: Text(
                                    "¿Deseas eliminar los ${seleccionados.length} usuarios seleccionados?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Sí"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmar == true) {
                                await usuarioService.eliminarUsuarios(
                                  seleccionados,
                                );
                                setState(() {
                                  seleccionados.clear();
                                  modoSeleccion = false;
                                  usuarios.clear();
                                  paginaActual = 1;
                                  hasMore = true;
                                  loading = true;
                                });
                                await fetchUsuarios(reset: true);
                              }
                            } else {
                              // Filtro por estado
                              if (estadoFiltro.isNotEmpty) {
                                setState(() {
                                  estadoFiltro = '';
                                  usuarios.clear();
                                  paginaActual = 1;
                                  hasMore = true;
                                  loading = true;
                                });
                                await fetchUsuarios(reset: true);
                              } else {
                                // Mostrar modal de filtrado avanzado
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
                                              title: const Text("Activo"),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                if (estadoFiltro != 'Activo') {
                                                  setState(() {
                                                    estadoFiltro = 'Activo';
                                                    usuarios.clear();
                                                    paginaActual = 1;
                                                    hasMore = true;
                                                    loading = true;
                                                  });
                                                  await fetchUsuarios(
                                                    reset: true,
                                                  );
                                                }
                                              },
                                            ),
                                            ListTile(
                                              title: const Text("Inactivo"),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                if (estadoFiltro !=
                                                    'Inactivo') {
                                                  setState(() {
                                                    estadoFiltro = 'Inactivo';
                                                    usuarios.clear();
                                                    paginaActual = 1;
                                                    hasMore = true;
                                                    loading = true;
                                                  });
                                                  await fetchUsuarios(
                                                    reset: true,
                                                  );
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
              child: loading && usuarios.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: usuarios.length + (loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= usuarios.length) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final usuario = usuarios[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Initicon(
                                  text: usuario['nombre'],
                                  backgroundColor: Colors.blue,
                                  size: 50,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        usuario['nombre'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Rol: ${usuario['rol']}'),
                                      Text('Estado: ${usuario['estado']}'),
                                      Text(
                                        'Registrado: ${usuario['fecha_registro']}',
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomDropdownSelector(
                                              labelText: 'Rol',
                                              hintText: 'Selecciona rol',
                                              value: usuario['rol'],
                                              items: roles,
                                              onChanged: (value) {
                                                actualizarUsuario(
                                                  index,
                                                  value,
                                                  usuario['estado'],
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: CustomDropdownSelector(
                                              labelText: 'Estado',
                                              hintText: 'Selecciona estado',
                                              value: usuario['estado'],
                                              items: estados,
                                              onChanged: (value) {
                                                actualizarUsuario(
                                                  index,
                                                  usuario['rol'],
                                                  value,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
