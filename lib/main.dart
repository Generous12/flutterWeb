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

        scaffoldBackgroundColor: Colors.white,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          background: Colors.white,
          surface: Colors.white,
        ),

        cardTheme: const CardThemeData(
          color: Colors.white, // color de todas las cartas
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // opcional
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
          return const LoginScreenWeb();
        } else {
          return const InicioScreen();
        }
      },
    );
  }
}
