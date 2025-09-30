import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioProvider with ChangeNotifier {
  String? _idUsuario;

  String? get idUsuario => _idUsuario;

  Future<void> cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    _idUsuario = prefs.getString("id_usuario");
    notifyListeners();
  }

  Future<void> setUsuario(String id) async {
    _idUsuario = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("id_usuario", id);
    notifyListeners();
  }

  Future<void> logout() async {
    _idUsuario = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("id_usuario");
    notifyListeners();
  }

  bool get isLoggedIn => _idUsuario != null;
}
