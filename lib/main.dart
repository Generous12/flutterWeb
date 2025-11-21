import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Asignacion/Carrito/CarritocaseService.dart';
import 'package:proyecto_web/Controlador/Provider/componentService.dart';
import 'package:proyecto_web/Controlador/Provider/usuarioautenticado.dart';
import 'package:proyecto_web/Vista/app/autenticacion/loginapp.dart';
import 'package:proyecto_web/Vista/app/principal/inicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final usuarioProvider = UsuarioProvider();
  await usuarioProvider.cargarUsuario();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UsuarioProvider>.value(value: usuarioProvider),
        ChangeNotifierProvider(create: (_) => ComponentService()),
        ChangeNotifierProvider(create: (_) => CaseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);

    return MaterialApp(
      title: 'Flutter Web Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Afacad',
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),

      home: usuarioProvider.isLoggedIn ? const InicioScreen() : LoginScreen(),
    );
  }
}
