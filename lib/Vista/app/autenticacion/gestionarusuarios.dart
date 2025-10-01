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

  final List<String> roles = ['Admin', 'Practicante'];
  final List<String> estados = ['Activo', 'Inactivo'];

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
  }

  Future<void> fetchUsuarios() async {
    setState(() => loading = true);
    try {
      usuarios = await usuarioService.listarUsuarios();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al listar usuarios: $e')));
    }
    setState(() => loading = false);
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
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
                              Text('Registrado: ${usuario['fecha_registro']}'),
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
    );
  }
}
