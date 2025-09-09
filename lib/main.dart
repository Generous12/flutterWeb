import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_web/Controlador/Provider/componentService.dart';
import 'package:proyecto_web/Vista/app/principal/inicio.dart';
import 'package:proyecto_web/Vista/web/login.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ComponentService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Test',
      theme: ThemeData(
        fontFamily: 'FunnelDisplay',

        // 🔹 Fondo global blanco
        scaffoldBackgroundColor: Colors.white,

        // 🔹 AppBar blanco
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // color de texto e íconos
          elevation: 0, // opcional: sin sombra
        ),

        // 🔹 Color scheme basado en blanco
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          background: Colors.white, // Fondo general
          surface: Colors.white, // Fondos de cards, dialogs, etc.
        ),
        useMaterial3: true,
      ),
      home: const ResponsiveWrapper(),
    );
  }
}

class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Pantallas grandes → web
          return const LoginScreenWeb();
        } else {
          // Pantallas pequeñas → app/móvil
          return const InicioScreen();
        }
      },
    );
  }
}
