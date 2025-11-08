import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Provider/usuarioautenticado.dart';
import 'package:proyecto_web/Controlador/Usuarios/usuariosservice.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/dropdownbutton.dart';
import 'package:proyecto_web/Widgets/logicaspeque%C3%B1as.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';
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
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final PasswordValidator _passwordValidator = PasswordValidator();
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

  void _onPasswordChanged(String password) {
    setState(() {
      _passwordValidator.checkPasswordRequirements(password);
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
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: "Por favor ingresa un ID de usuario",
        icono: Icons.badge,
        colorFondo: const Color.fromARGB(255, 0, 0, 0),
      );
      return;
    }

    if (nombreController.text.trim().isEmpty) {
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: "Por favor ingresa un nombre",
        icono: Icons.person,
        colorFondo: const Color.fromARGB(255, 0, 0, 0),
      );
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: "Por favor ingresa una contraseña",
        icono: Icons.lock,
        colorFondo: const Color.fromARGB(255, 0, 0, 0),
      );
      return;
    }

    if (_rolSeleccionado == null) {
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: "Por favor selecciona un rol",
        icono: Icons.assignment_ind,
        colorFondo: const Color.fromARGB(255, 0, 0, 0),
      );
      return;
    }

    final confirmado = await showCustomDialog(
      context: context,
      title: "Confirmar",
      message: "¿Deseas registrar este usuario?",
      confirmButtonText: "Sí",
      cancelButtonText: "No",
    );

    if (confirmado != true) {
      print("⏹️ Usuario canceló la acción");
      return;
    }

    final usuarioProvider = Provider.of<UsuarioProvider>(
      context,
      listen: false,
    );

    final result = await _api.registrarUsuario(
      idUsuario: idController.text,
      nombre: nombreController.text,
      password: passwordController.text,
      rol: _rolSeleccionado!,
      idUsuarioCreador: usuarioProvider.idUsuario ?? "",
      rolCreador: usuarioProvider.rol ?? "",
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
      await showCustomDialog(
        context: context,
        title: "Error",
        message: "Error: ${result["message"]}",
        confirmButtonText: "Cerrar",
      );
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
            title: const Text(
              "Registrar usuarios",
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              children: [
                CustomTextField(
                  controller: idController,
                  hintText: "Se genera automáticamente",
                  label: "Se genera automáticamente el ID",
                  enabled: false,
                ),

                CustomTextField(
                  controller: nombreController,
                  hintText: "Ingresa tu nombre",
                  label: "Nombre",
                ),

                CustomTextField(
                  controller: passwordController,
                  label: "Ingrese una contraseña",
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  onChanged: _onPasswordChanged,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _passwordValidator.hasMinLength,
                          onChanged: null,
                        ),
                        Text('Min 6 caracteres'),
                        const SizedBox(width: 12),
                        Checkbox(
                          value: _passwordValidator.hasLowercase,
                          onChanged: null,
                        ),
                        Text('Una minúscula'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _passwordValidator.hasUppercase,
                          onChanged: null,
                        ),
                        Text('Una mayúscula'),
                        const SizedBox(width: 20),
                        Checkbox(
                          value: _passwordValidator.hasNumber,
                          onChanged: null,
                        ),
                        Text('Un número'),
                      ],
                    ),
                  ],
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
