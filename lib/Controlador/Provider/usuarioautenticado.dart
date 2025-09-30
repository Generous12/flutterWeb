import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioProvider with ChangeNotifier {
  String? _idUsuario;
  String? _rol;

  String? get idUsuario => _idUsuario;
  String? get rol => _rol;
  bool get isLoggedIn => _idUsuario != null;

  Future<void> cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    _idUsuario = prefs.getString("id_usuario");
    _rol = prefs.getString("rol");
    notifyListeners();
  }

  Future<void> setUsuario(String id, String? rol) async {
    _idUsuario = id;
    _rol = rol;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("id_usuario", id);

    if (rol != null) {
      await prefs.setString("rol", rol);
    } else {
      await prefs.remove("rol");
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _idUsuario = null;
    _rol = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("id_usuario");
    await prefs.remove("rol");
    notifyListeners();
  }
}
