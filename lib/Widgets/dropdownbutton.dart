import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdownSelector extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String? value;
  final List<String> items;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final Map<String, VoidCallback>? itemActions;
  final VoidCallback? onTap;

  const CustomDropdownSelector({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.onClear,
    this.itemActions,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: false,
        child: DropdownButtonFormField2<String>(
          value: value?.isEmpty == true ? null : value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
              fontSize: 13,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 20,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 0, 0, 0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 1.2),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            isOverButton: false,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            elevation: 4,
          ),
          iconStyleData: IconStyleData(
            icon: value == null
                ? const Icon(Icons.arrow_drop_down)
                : GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
            iconSize: 22,
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
                  child: Text(
                    item,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (selectedValue) {
            if (selectedValue != null) {
              onChanged(selectedValue);
              if (itemActions != null &&
                  itemActions!.containsKey(selectedValue)) {
                itemActions![selectedValue]!();
              }
            }
          },
        ),
      ),
    );
  }
}
