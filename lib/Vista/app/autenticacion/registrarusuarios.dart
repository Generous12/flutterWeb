import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/Usuarios/usuariosservice.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/dropdownbutton.dart';
import 'package:proyecto_web/Widgets/textfield.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _api = ApiService();
  String? _rolSeleccionado;
  @override
  void initState() {
    super.initState();

    nombreController.addListener(() {
      if (nombreController.text.isNotEmpty) {
        final String codigoGenerado = _generarCodigo(nombreController.text);
        setState(() {
          idController.text = codigoGenerado;
        });
      } else {
        setState(() {
          idController.text = "";
        });
      }
    });
  }

  Future<void> _registrarUsuario() async {
    if (_rolSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor selecciona un rol")),
      );
      return;
    }

    final result = await _api.registrarUsuario(
      idUsuario: idController.text,
      nombre: nombreController.text,
      password: passwordController.text,
      rol: _rolSeleccionado!,
    );

    if (result["success"]) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["message"])));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${result["message"]}")));
    }
  }

  @override
  void dispose() {
    idController.dispose();
    nombreController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _generarCodigo(String nombre) {
    final iniciales = nombre.isNotEmpty
        ? nombre.trim().split(" ").map((e) => e[0].toUpperCase()).join()
        : "USR";
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return "$iniciales-$timestamp";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Usuario")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: idController,
              hintText: "Se genera automáticamente",
              label: "ID Usuario",
              enabled: false,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: nombreController,
              hintText: "Ingresa tu nombre",
              label: "Nombre",
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              hintText: "Ingresa tu contraseña",
              label: "Contraseña",
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomDropdownSelector(
              labelText: "Rol",
              hintText: "Selecciona...",
              value: _rolSeleccionado,
              items: const ["Admin", "Practicante"],
              onChanged: (value) {
                setState(() {
                  _rolSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 32),
            LoadingOverlayButtonHabilitar(
              text: "Registrar Usuario",
              icon: Icons.person_add,
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              textColor: Colors.white,
              onPressedLogic: () async {
                _registrarUsuario();
              },
            ),
          ],
        ),
      ),
    );
  }
}
