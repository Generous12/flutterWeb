import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Historial/historialservice.dart';
import 'package:proyecto_web/Controlador/Provider/usuarioautenticado.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:timeago/timeago.dart' as timeago;

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<Map<String, dynamic>> historial = [];
  Set<String> seleccionados = {};
  bool cargando = false;

  int _page = 1;
  final int _limit = 30;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cargarHistorial();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingMore &&
          _hasMore) {
        _cargarHistorial();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarHistorial({bool reset = false}) async {
    if (_isLoadingMore) return;

    if (reset) {
      _page = 1;
      historial.clear();
      _hasMore = true;
    }

    setState(() => _isLoadingMore = true);

    try {
      final data = await HistorialService().listarHistorial(
        page: _page,
        limit: _limit,
      );

      setState(() {
        historial.addAll(data);
        _isLoadingMore = false;
        _hasMore = data.length == _limit;
        if (_hasMore) _page++;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      print("Error al cargar historial: $e");
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> _eliminarSeleccionados() async {
    if (seleccionados.isEmpty) return;

    final usuarioProvider = Provider.of<UsuarioProvider>(
      context,
      listen: false,
    );

    final idUsuario = usuarioProvider.idUsuario;
    final rol = usuarioProvider.rol;

    if (idUsuario == null || rol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario no logueado o sin rol")),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      bool ok = await HistorialService().eliminarHistorial(
        ids: seleccionados.toList(),
      );

      if (ok) {
        showCustomDialog(
          context: context,
          title: "Exito",
          message: "Historial eliminado correctamente",
          confirmButtonText: "Cerrar",
        );
        seleccionados.clear();
        _cargarHistorial(reset: true);
      } else {
        showCustomDialog(
          context: context,
          title: "Espera",
          message: "No se pudo eliminar correctamente",
          confirmButtonText: "Cerrar",
        );
      }
    } catch (e) {
      showCustomDialog(
        context: context,
        title: "Espera",
        message: "No se pudo eliminar correctamente php",
        confirmButtonText: "Cerrar",
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 48,
          backgroundColor: Colors.black,
          title: Text(
            seleccionados.isNotEmpty
                ? "${seleccionados.length} seleccionados"
                : "Historial de acciones",
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            if (seleccionados.isNotEmpty)
              IconButton(
                icon: const Icon(Iconsax.trash, color: Colors.white),
                onPressed: _eliminarSeleccionados,
              ),
          ],
        ),

        body: RefreshIndicator(
          onRefresh: () => _cargarHistorial(reset: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(0),
            itemCount: historial.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == historial.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final item = historial[index];
              final id = item['id_historial'].toString();
              final seleccionado = seleccionados.contains(id);

              Color rolColor;
              switch (item['rol']) {
                case 'Admin':
                  rolColor = Colors.red.shade300;
                  break;
                case 'Practicante':
                  rolColor = Colors.green.shade200;
                  break;
                default:
                  rolColor = Colors.grey.shade200;
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onLongPress: () {
                    setState(() {
                      if (seleccionado) {
                        seleccionados.remove(id);
                      } else {
                        seleccionados.add(id);
                      }
                    });
                  },
                  onTap: () {
                    if (seleccionados.isNotEmpty) {
                      setState(() {
                        if (seleccionado) {
                          seleccionados.remove(id);
                        } else {
                          seleccionados.add(id);
                        }
                      });
                    }
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['accion'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    " ${item['id_usuario']}",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: rolColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item['rol'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Entidad afectada: ${item['id_entidad']}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Realizado ${timeago.format(DateTime.parse(item['fecha']), locale: 'es')}",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
