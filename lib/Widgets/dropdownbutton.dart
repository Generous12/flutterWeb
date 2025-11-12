import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdownSelector extends StatefulWidget {
  final String labelText;
  final String hintText;
  final String? value;
  final List<String> items;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final Map<String, VoidCallback>? itemActions;
  final VoidCallback? onTap;
  final bool enabled; // mantenido

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
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomDropdownSelector> createState() => _CustomDropdownSelectorState();
}

class _CustomDropdownSelectorState extends State<CustomDropdownSelector> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleClear() {
    // Ejecuta callback onClear si existe
    if (widget.onClear != null) widget.onClear!();

    // Remueve foco para que la 'X' desaparezca inmediatamente
    _focusNode.unfocus();
    // Opcional: notificar que se limpió (si quieres manejar valor null desde fuera)
    // Por convención, podrías llamar onChanged con '' o algún valor sentinel si lo necesitas.
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AbsorbPointer(
        absorbing: !widget.enabled,
        child: Focus(
          focusNode: _focusNode,
          child: DropdownButtonFormField2<String>(
            value: widget.value?.isEmpty == true ? null : widget.value,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: widget.enabled ? Colors.black : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              filled: true,
              fillColor: widget.enabled ? Colors.white : Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 17,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.black.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.black, width: 1.6),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              isOverButton: false,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
              ),
              elevation: 4,
            ),
            iconStyleData: IconStyleData(
              // Mostrar 'X' solo si hay valor, el campo está enfocado y está habilitado
              icon: (widget.value != null && _isFocused && widget.enabled)
                  ? GestureDetector(
                      onTap: _handleClear,
                      child: const Icon(Icons.close, color: Colors.black),
                    )
                  : const Icon(Icons.arrow_drop_down),
              iconSize: 22,
            ),
            hint: Text(
              widget.hintText,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.grey[400] : const Color(0xFF6C6C6C),
              ),
            ),
            items: widget.items
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
            onChanged: widget.enabled
                ? (selectedValue) {
                    if (selectedValue != null) {
                      widget.onChanged(selectedValue);
                      if (widget.itemActions != null &&
                          widget.itemActions!.containsKey(selectedValue)) {
                        widget.itemActions![selectedValue]!();
                      }
                    }
                  }
                : null,
          ),
        ),
      ),
    );
  }
}
