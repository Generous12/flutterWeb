import 'dart:math';

class PasswordValidator {
  bool hasMinLength = false;
  bool hasLowercase = false;
  bool hasUppercase = false;
  bool hasNumber = false;

  bool arePasswordsEqual(String password, String repeatPassword) {
    return password == repeatPassword;
  }

  void checkPasswordRequirements(String password) {
    hasMinLength = password.length >= 6;
    hasLowercase = password.contains(RegExp(r'[a-z]'));
    hasUppercase = password.contains(RegExp(r'[A-Z]'));
    hasNumber = password.contains(RegExp(r'[0-9]'));
  }
}

String generarCodigoInventario(String nombre) {
  final cleanName = nombre.replaceAll(' ', '').toUpperCase();
  final prefix = cleanName.length >= 3 ? cleanName.substring(0, 3) : cleanName;

  final now = DateTime.now();
  final datePart =
      "${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

  final randomNumber = (100 + Random().nextInt(900)).toString();

  return "$prefix-$datePart-$randomNumber";
}
