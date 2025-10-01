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
    return Scaffold(
      appBar: AppBar(title: const Text('Listado de Usuarios')),
      body: Column(
        children: [
          // Búsqueda y filtro
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre o código',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      busqueda = value;
                      fetchUsuarios(reset: true);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por estado',
                      border: OutlineInputBorder(),
                    ),
                    value: estadoFiltro.isEmpty ? null : estadoFiltro,
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Todos')),
                      ...estados
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                    ],
                    onChanged: (value) {
                      estadoFiltro = value ?? '';
                      fetchUsuarios(reset: true);
                    },
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
