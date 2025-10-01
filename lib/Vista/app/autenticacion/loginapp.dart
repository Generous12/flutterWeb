import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Provider/usuarioautenticado.dart';
import 'package:proyecto_web/Controlador/Usuarios/usuariosservice.dart';
import 'package:proyecto_web/Vista/app/principal/inicio.dart';
import 'package:proyecto_web/Widgets/boton.dart';
import 'package:proyecto_web/Widgets/navegator.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';
import 'package:proyecto_web/Widgets/textfield.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    final nombre = emailController.text.trim();
    final password = passwordController.text.trim();

    if (nombre.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa correo y contraseña")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final respuesta = await apiService.loginUsuario(
        nombre: nombre,
        password: password,
      );

      if (respuesta["success"]) {
        final usuarioProvider = Provider.of<UsuarioProvider>(
          context,
          listen: false,
        );
        await usuarioProvider.setUsuario(
          respuesta["id_usuario"],
          respuesta["rol"],
        );

        navegarYRemoverConSlideDerecha(context, InicioScreen());
      } else {
        SnackBarUtil.mostrarSnackBarPersonalizado(
          context: context,
          mensaje: respuesta["message"] ?? "Error en login",
          icono: Iconsax.alarm,
          duracion: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20.0),
                          Image.asset(
                            'assets/images/logo.png',
                            height: 230.0,
                            fit: BoxFit.fitWidth,
                          ),

                          CustomTextField(
                            controller: emailController,
                            hintText: "Ingresar correo electrónico",
                            prefixIcon: Iconsax.sms,
                            label: "Correo electronico",
                          ),
                          const SizedBox(height: 20.0),
                          CustomTextField(
                            controller: passwordController,
                            label: "Contraseña",
                            prefixIcon: Iconsax.lock,
                            obscureText: true,
                          ),
                          const SizedBox(height: 20.0),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              LoadingOverlayButton(
                                text: 'Iniciar Sesión',
                                onPressedLogic: () async {
                                  _login();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          InkWell(
                            onTap: () {},
                            child: Text(
                              '¿Deseas pedir ayuda? Contactanos',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
