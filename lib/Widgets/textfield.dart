import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool isNumeric;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool showCounter;
  final bool enabled;
  final String? initialValue;
  final Widget? suffixIcon;
  final String? errorText;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    this.enabled = true,
    required this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.isNumeric = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.onChanged,
    this.focusNode,
    this.showCounter = false,
    this.initialValue,
    this.suffixIcon,
    this.errorText,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    if (widget.initialValue != null && widget.controller.text.isEmpty) {
      widget.controller.text = widget.initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bool isMultiline = widget.maxLines! > 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.isNumeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.multiline,
        obscureText: _obscureText,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.minLines ?? 1,
        onChanged: widget.onChanged,
        focusNode: widget.focusNode,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        enabled: widget.enabled,
        cursorColor: colorScheme.primary,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.transparent, width: 0),
          ),

          labelStyle: TextStyle(
            fontSize: 14,
            color: colorScheme.primary.withOpacity(0.8),
          ),
          floatingLabelStyle: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          alignLabelWithHint: isMultiline,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
          ),

          filled: false,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),

          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 6),
                  child: Icon(
                    widget.prefixIcon,
                    size: 22,
                    color: colorScheme.primary,
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 38,
            minHeight: 38,
          ),

          suffixIcon:
              widget.suffixIcon ??
              (widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: colorScheme.onBackground,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null),

          counterText: widget.showCounter ? null : "",

          // Borde elegante
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.grey.shade700
                  : Colors.black.withOpacity(0.3),
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
          ),

          errorText: widget.errorText,
        ),
      ),
    );
  }
}
