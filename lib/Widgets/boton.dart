import 'package:flutter/material.dart';

class LoadingOverlayButton extends StatefulWidget {
  final Future<void> Function() onPressedLogic;
  final String text;
  final IconData? icon;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? foregroundColor;
  final Color? color; // <-- nuevo parámetro opcional

  const LoadingOverlayButton({
    Key? key,
    required this.onPressedLogic,
    this.icon,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.foregroundColor,
    this.color,
  }) : super(key: key);

  @override
  State<LoadingOverlayButton> createState() => _LoadingOverlayButtonState();
}

class _LoadingOverlayButtonState extends State<LoadingOverlayButton> {
  bool isLoading = false;

  Future<void> _handlePressed() async {
    setState(() => isLoading = true);
    await widget.onPressedLogic();
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final backgroundColor =
        widget.color ??
        widget.backgroundColor ??
        (isDark ? const Color(0xFF2D2D2D) : Colors.black);

    final textColor =
        widget.foregroundColor ??
        widget.textColor ??
        (isDark ? Colors.white : Colors.white);

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isLoading,
          child: Opacity(
            opacity: isLoading ? 0.5 : 1,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handlePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                minimumSize: const Size(double.infinity, 50.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: textColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(fontSize: 16.7, color: textColor),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 76, 76, 76),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class LoadingOverlayButtonHabilitar extends StatefulWidget {
  final Future<void> Function() onPressedLogic;
  final String text;
  final IconData? icon;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? foregroundColor;
  final Color? color;

  const LoadingOverlayButtonHabilitar({
    Key? key,
    required this.onPressedLogic,
    required this.text,
    this.icon,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.foregroundColor,
    this.color,
  }) : super(key: key);

  @override
  State<LoadingOverlayButtonHabilitar> createState() =>
      _LoadingOverlayButtonHabilitarState();
}

class _LoadingOverlayButtonHabilitarState
    extends State<LoadingOverlayButtonHabilitar> {
  bool isLoading = false;

  Future<void> _handlePressed() async {
    setState(() => isLoading = true);
    await widget.onPressedLogic();
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final backgroundColor =
        widget.color ??
        widget.backgroundColor ??
        (isDark ? const Color(0xFF2D2D2D) : Colors.black);

    final textColor =
        widget.foregroundColor ??
        widget.textColor ??
        (isDark ? Colors.white : Colors.white);

    final isButtonEnabled = widget.enabled && !isLoading;

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: !isButtonEnabled,
          child: Opacity(
            opacity: isButtonEnabled ? 1 : 0.5,
            child: ElevatedButton(
              onPressed: isButtonEnabled ? _handlePressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                minimumSize: const Size(double.infinity, 50.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: textColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(fontSize: 16.7, color: textColor),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 76, 76, 76),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
