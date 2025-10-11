import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaseProvider extends ChangeNotifier {
  bool _modoCarrito = false;
  List<int> _componentesSeleccionados = [];
  int? _idAreaSeleccionada;

  bool get modoCarrito => _modoCarrito;
  List<int> get componentesSeleccionados => _componentesSeleccionados;
  int? get idAreaSeleccionada => _idAreaSeleccionada;

  /// Inicializa el estado desde SharedPreferences
  Future<void> cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    _modoCarrito = prefs.getBool('modoCarrito') ?? false;
    _componentesSeleccionados =
        prefs
            .getStringList('componentesSeleccionados')
            ?.map(int.parse)
            .toList() ??
        [];
    _idAreaSeleccionada = prefs.getInt('idAreaSeleccionada');
    notifyListeners();
  }

  /// Activa o desactiva el modo carrito
  Future<void> toggleModoCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    _modoCarrito = !_modoCarrito;
    await prefs.setBool('modoCarrito', _modoCarrito);

    // Si se desactiva, limpia todo
    if (!_modoCarrito) {
      _componentesSeleccionados.clear();
      _idAreaSeleccionada = null;
      await prefs.remove('componentesSeleccionados');
      await prefs.remove('idAreaSeleccionada');
    }

    notifyListeners();
  }

  /// Agregar un componente/periférico al carrito
  Future<void> agregarComponente(int idComponente) async {
    if (!_componentesSeleccionados.contains(idComponente)) {
      _componentesSeleccionados.add(idComponente);
      await _guardarComponentes();
      notifyListeners();
    }
  }

  /// Quitar un componente del carrito
  Future<void> quitarComponente(int idComponente) async {
    _componentesSeleccionados.remove(idComponente);
    await _guardarComponentes();
    notifyListeners();
  }

  /// Seleccionar el área
  Future<void> seleccionarArea(int idArea) async {
    _idAreaSeleccionada = idArea;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('idAreaSeleccionada', idArea);
    notifyListeners();
  }

  /// Limpiar todos los datos del case actual
  Future<void> limpiarCase() async {
    _modoCarrito = false;
    _componentesSeleccionados.clear();
    _idAreaSeleccionada = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('modoCarrito');
    await prefs.remove('componentesSeleccionados');
    await prefs.remove('idAreaSeleccionada');
    notifyListeners();
  }

  /// Guardar lista de componentes en SharedPreferences
  Future<void> _guardarComponentes() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = _componentesSeleccionados.map((e) => e.toString()).toList();
    await prefs.setStringList('componentesSeleccionados', lista);
  }
}
