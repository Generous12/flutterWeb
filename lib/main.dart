import 'package:flutter/material.dart';
import 'package:proyecto_web/Vista/app/loginapp.dart';
import 'package:proyecto_web/Vista/web/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Test',
      theme: ThemeData(
        fontFamily: 'HubotSans',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
          return const LoginScreenApp();
        }
      },
    );
  }
}
