import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/Usuarios/usuariosservice.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
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

  bool get huboCambio {
    return idController.text.isNotEmpty ||
        nombreController.text.isNotEmpty ||
        passwordController.text.isNotEmpty ||
        _rolSeleccionado != null;
  }

  Future<bool> _onWillPop() async {
    if (huboCambio) {
      final salir = await showCustomDialog(
        context: context,
        title: "Cambios sin guardar",
        message:
            "Tienes datos escritos que no se han guardado.\n\n¿Deseas salir de todas formas?",
        confirmButtonText: "Salir",
        cancelButtonText: "Cancelar",
      );
      return salir ?? false;
    }
    return true;
  }

  Future<void> _registrarUsuario() async {
    if (idController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa un ID de usuario")),
      );
      return;
    }
    if (nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa un nombre")),
      );
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa una contraseña")),
      );
      return;
    }
    if (_rolSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor selecciona un rol")),
      );
      return;
    }

    // 🔹 Paso 1: Confirmar acción
    final confirmado = await showCustomDialog(
      context: context,
      title: "Confirmar",
      message: "¿Deseas registrar este usuario?",
      confirmButtonText: "Sí",
      cancelButtonText: "No",
    );

    if (confirmado == true) {
      print("➡️ Usuario confirmó, intentando registrar en backend...");

      final result = await _api.registrarUsuario(
        idUsuario: idController.text,
        nombre: nombreController.text,
        password: passwordController.text,
        rol: _rolSeleccionado!,
      );

      if (result["success"]) {
        final continuar = await showCustomDialog(
          context: context,
          title: "Éxito",
          message: "${result["message"]}\n\n¿Deseas registrar otro usuario?",
          confirmButtonText: "Sí",
          cancelButtonText: "No",
        );

        if (continuar == true) {
          print("🔄 Usuario quiere seguir registrando");
          idController.clear();
          nombreController.clear();
          passwordController.clear();
          setState(() {
            _rolSeleccionado = null;
          });
        } else {
          print("🏠 Usuario quiere volver al inicio");
          Navigator.pop(context);
        }
      } else {
        // 🔹 Paso 3: Error
        await showCustomDialog(
          context: context,
          title: "Error",
          message: "Error: ${result["message"]}",
          confirmButtonText: "Cerrar",
        );
      }
    } else {
      print("⏹️ Usuario canceló la acción");
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 48,
            title: const Text("Usuarios"),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 6,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  controller: idController,
                  hintText: "Se genera automáticamente",
                  label: "Se genera automáticamente el ID",
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
        ),
      ),
    );
  }
}
