import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onBack; // lógica del botón atrás

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar componente',
          border: InputBorder.none,
          prefixIcon: IconButton(
            icon: const Icon(Iconsax.arrow_left, color: Colors.black),
            onPressed: onBack,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : const Icon(Iconsax.search_normal, color: Colors.black),
        ),
      ),
    );
  }
}
