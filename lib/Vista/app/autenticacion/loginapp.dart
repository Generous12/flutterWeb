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

  Future<void> _login() async {
    final correo = emailController.text.trim();
    final password = passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingresa correo y contraseña")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final respuesta = await apiService.loginUsuario(
        nombre: correo,
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

        navegarYRemoverConSlideDerecha(context, const InicioScreen());
      } else {
        SnackBarUtil.mostrarSnackBarPersonalizado(
          context: context,
          mensaje: respuesta["message"] ?? "Error en login",
          icono: Iconsax.alarm,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWeb = constraints.maxWidth > 800;

        double cardWidth = isWeb ? 450 : constraints.maxWidth;
        double horizontalPadding = isWeb ? 40 : 20;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Center(
                child: Container(
                  width: cardWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isWeb ? 40 : 20,
                  ),
                  decoration: isWeb
                      ? BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 15,
                              color: Colors.black12,
                              offset: Offset(0, 8),
                            ),
                          ],
                        )
                      : null,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/images/logo.png',
                          height: isWeb ? 180 : 220,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 30),
                        CustomTextField(
                          controller: emailController,
                          hintText: "Ingresar correo electrónico",
                          prefixIcon: Iconsax.sms,
                          label: "Correo electrónico",
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: passwordController,
                          label: "Contraseña",
                          prefixIcon: Iconsax.lock,
                          obscureText: true,
                        ),
                        const SizedBox(height: 25),
                        LoadingOverlayButton(
                          text: 'Iniciar Sesión',
                          onPressedLogic: _login,
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            '¿Deseas pedir ayuda? Contáctanos',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black38,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}
