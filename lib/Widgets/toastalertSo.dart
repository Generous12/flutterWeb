import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  /// 🟢 Éxito
  static void showSuccess(String message) {
    _showToast(
      message,
      const Color.fromARGB(112, 0, 200, 83),
      Icons.check_circle,
    );
  }

  /// 🔴 Error
  static void showError(String message) {
    _showToast(
      message,
      const Color.fromARGB(133, 213, 0, 0),
      Icons.error_outline,
    );
  }

  /// 🟠 Advertencia
  static void showWarning(String message) {
    _showToast(
      message,
      const Color.fromARGB(102, 255, 111, 0),
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
