import 'package:flutter/material.dart';

void navegarYRemoverConSlideDerecha(BuildContext context, Widget pantalla) {
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => pantalla,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    ),
    (route) => false,
  );
}

void navegarYRemoverConSlideIzquierda(BuildContext context, Widget pantalla) {
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => pantalla,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    ),
    (route) => false,
  );
}

void navegarConSlideDerecha(
  BuildContext context,
  Widget pantalla, {
  VoidCallback? onVolver,
}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => pantalla,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    ),
  ).then((_) {
    if (onVolver != null) onVolver();
  });
}

void navegarConSlideIzquierda(
  BuildContext context,
  Widget pantalla, {
  VoidCallback? onVolver,
}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => pantalla,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    ),
  ).then((_) {
    if (onVolver != null) onVolver();
  });
}

void navegarConSlideArriba(
  BuildContext context,
  Widget pantalla, {
  VoidCallback? onVolver,
}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => pantalla,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, anim, __, child) {
        var tween = Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));

        return SlideTransition(position: anim.drive(tween), child: child);
      },
    ),
  ).then((_) {
    if (onVolver != null) onVolver();
  });
}
