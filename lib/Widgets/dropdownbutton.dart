import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final String? value;
  final void Function(String?)? onChanged;
  final IconData? icon;
  final String label;
  final Color? iconColor;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.icon,
    required this.label,
    this.iconColor,
  });

  InputDecoration _dropdownDecoration(
    BuildContext context,
    String label,
    IconData? icon,
    Color? iconColor,
  ) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      prefixIcon: icon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Icon(
                icon,
                size: 22,
                color: iconColor ?? theme.colorScheme.primary,
              ),
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 203, 203, 203),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 126, 126, 126),
          width: 1.3,
        ),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: _dropdownDecoration(context, label, icon, iconColor),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 11)),
            ),
          )
          .toList(),
      value: value,
      onChanged: onChanged,
      buttonStyleData: const ButtonStyleData(height: 50),
    );
  }
}

class CustomDropdownSelector extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String? value;
  final List<String> items;
  final Function(String) onChanged;
  final Map<String, VoidCallback>? itemActions;

  const CustomDropdownSelector({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField2<String>(
      value: value?.isEmpty == true ? null : value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isDarkMode
              ? Colors.grey[300]
              : const Color.fromARGB(255, 100, 100, 100),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : const Color(0xFFD4D4D4),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
            width: 1.2,
          ),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        isOverButton: false,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isDarkMode ? Colors.grey[900] : Colors.white,
        ),
        elevation: 4,
      ),
      hint: Text(
        hintText,
        style: TextStyle(
          fontSize: 13,
          color: isDarkMode
              ? Colors.grey[400]
              : const Color.fromARGB(255, 108, 108, 108),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    item,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value); // acción general
          if (itemActions != null && itemActions!.containsKey(value)) {
            itemActions![value]!();
          }
        }
      },
    );
  }
}
