import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Provider/usuarioautenticado.dart';
import 'package:proyecto_web/Controlador/Usuarios/gestiousuario.dart';
import 'package:proyecto_web/Vista/app/autenticacion/registrarusuarios.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/dropdownbutton.dart';
import 'package:proyecto_web/Widgets/navegator.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    timeago.setLocaleMessages('es', timeago.EsMessages());
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
        hasMore = nuevosUsuarios.length == 10;
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
        final usuarioProvider = Provider.of<UsuarioProvider>(
          context,
          listen: false,
        );
        if (usuarios[index]['id_usuario'] == usuarioProvider.idUsuario) {
          await usuarioProvider.setUsuario(
            usuarioProvider.idUsuario!,
            nuevoRol,
          );
        }
        SnackBarUtil.mostrarSnackBarPersonalizado(
          context: context,
          mensaje: "Cambios guardados correctamente",
          icono: Iconsax.chart_success,
          duracion: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: "Error al actualizar",
        icono: Iconsax.warning_2,
        duracion: const Duration(seconds: 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(
      context,
      listen: false,
    );

    final idUsuarioActual = usuarioProvider.idUsuario;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
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
                                : estadoFiltro.isEmpty
                                ? Iconsax.filter
                                : Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            if (modoSeleccion) {
                              if (seleccionados.isEmpty) return;

                              final confirmar = await showCustomDialog(
                                context: context,
                                title: "Confirmar eliminación",
                                message:
                                    "¿Deseas eliminar los ${seleccionados.length} usuarios seleccionados?",
                                confirmButtonText: "Sí",
                                cancelButtonText: "No",
                                confirmButtonColor: Colors.red,
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
                      padding: const EdgeInsets.all(0),
                      itemCount: usuarios.length + (loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= usuarios.length) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final usuario = usuarios[index];
                        final usuarioId =
                            usuario['id_usuario']?.toString() ?? '';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (modoSeleccion) {
                                      if (seleccionados.contains(usuarioId)) {
                                        seleccionados.remove(usuarioId);
                                      } else {
                                        seleccionados.add(usuarioId);
                                      }
                                      if (seleccionados.isEmpty) {
                                        modoSeleccion = false;
                                      }
                                    } else {
                                      showBarModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.white,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (context) => SafeArea(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Initicon(
                                                      text: usuario['nombre'],
                                                      backgroundColor:
                                                          Colors.blue,
                                                      size: 50,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          usuario['id_usuario']
                                                                      .toString() ==
                                                                  idUsuarioActual
                                                              ? '${usuario['nombre']} (Yo)'
                                                              : usuario['nombre'],
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'Registrado ${timeago.format(DateTime.parse(usuario['fecha_registro']), locale: 'es')}',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
                                                const Text(
                                                  "Actualizar Rol y Estado",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                CustomDropdownSelector(
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
                                                const SizedBox(height: 10),
                                                CustomDropdownSelector(
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
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                const SizedBox(height: 20),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                                onLongPress: () {
                                  setState(() {
                                    if (!modoSeleccion) {
                                      modoSeleccion = true;
                                      if (usuarioId.isNotEmpty) {
                                        seleccionados.add(usuarioId);
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        modoSeleccion &&
                                            seleccionados.contains(usuarioId)
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Initicon(
                                            text: usuario['nombre'],
                                            backgroundColor: Colors.blue,
                                            size: 50,
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                usuario['id_usuario']
                                                            .toString() ==
                                                        idUsuarioActual
                                                    ? '${usuario['nombre']} (Yo)'
                                                    : usuario['nombre'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Registrado ${timeago.format(DateTime.parse(usuario['fecha_registro']), locale: 'es')}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: usuario['estado'] == 'Activo'
                                        ? Colors.green.withOpacity(0.7)
                                        : Colors.red.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    usuario['estado'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          shape: const CircleBorder(),
          onPressed: () {
            navegarConSlideDerecha(context, RegistroUsuarioScreen());
          },
          child: const Icon(Iconsax.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
