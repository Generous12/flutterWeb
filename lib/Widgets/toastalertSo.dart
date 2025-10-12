import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  /// 🟢 Éxito
  static void showSuccess(String message) {
    _showToast(message, Colors.greenAccent.shade700, Icons.check_circle);
  }

  /// 🔴 Error
  static void showError(String message) {
    _showToast(message, Colors.redAccent.shade700, Icons.error_outline);
  }

  /// 🟠 Advertencia
  static void showWarning(String message) {
    _showToast(
      message,
      Colors.orangeAccent.shade700,
      Icons.warning_amber_rounded,
    );
  }

  /// 🔵 Información
  static void showInfo(String message) {
    _showToast(message, Colors.blueAccent.shade700, Icons.info_outline);
  }

  /// ⚙️ Método privado reutilizable
  static void _showToast(String message, Color bgColor, IconData icon) {
    Fluttertoast.showToast(
      msg: "  ${String.fromCharCode(0x2022)}  $message",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 15.0,
    );
  }
}
