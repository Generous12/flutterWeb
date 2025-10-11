import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/Componentes/list_Update_Component.dart';
import 'package:proyecto_web/Widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaseProvider extends ChangeNotifier {
  List<ComponenteUpdate> _componentesSeleccionados = [];
  Map<String, dynamic>? _areaSeleccionada;

  List<ComponenteUpdate> get componentesSeleccionados =>
      _componentesSeleccionados;
  Map<String, dynamic>? get areaSeleccionada => _areaSeleccionada;

  Future<void> cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();

    // Componentes
    final componentesStr = prefs.getStringList('componentesSeleccionados');
    if (componentesStr != null) {
      _componentesSeleccionados = componentesStr
          .map((jsonStr) => ComponenteUpdate.fromJson(json.decode(jsonStr)))
          .toList();
    }

    final areaStr = prefs.getString('areaSeleccionada');
    if (areaStr != null) {
      _areaSeleccionada = json.decode(areaStr);
    }

    notifyListeners();
  }

  Future<void> agregarComponente(
    BuildContext context,
    ComponenteUpdate comp,
  ) async {
    final existe = _componentesSeleccionados.any((c) => c.id == comp.id);
    if (!existe) {
      _componentesSeleccionados.add(comp);
      await _guardarComponentes();
      notifyListeners();
    } else {
      SnackBarUtil.mostrarSnackBarPersonalizado(
        context: context,
        mensaje: 'El componente ya fue agregado',
        icono: Icons.warning_amber_rounded,
        colorFondo: Colors.redAccent,
        duracion: const Duration(seconds: 2),
      );
    }
  }

  Future<void> quitarComponente(int idComponente) async {
    _componentesSeleccionados.removeWhere((comp) => comp.id == idComponente);
    await _guardarComponentes();
    notifyListeners();
  }

  Future<void> _guardarComponentes() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = _componentesSeleccionados
        .map(
          (c) => json.encode({
            "id_componente": c.id,
            "id_tipo": c.idTipo,
            "codigo_inventario": c.codigoInventario,
            "nombre_tipo": c.nombreTipo,
            "tipo_nombre": c.tipoNombre,
            "estado": c.estado,
            "imagenes": c.imagenesBase64,
          }),
        )
        .toList();
    await prefs.setStringList('componentesSeleccionados', listaJson);
  }

  /// Seleccionar área (guarda todos los datos del área)
  Future<void> seleccionarArea(Map<String, dynamic> area) async {
    _areaSeleccionada = area;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('areaSeleccionada', json.encode(area));
    notifyListeners();
  }

  /// Limpiar todo
  Future<void> limpiarCase() async {
    _componentesSeleccionados.clear();
    _areaSeleccionada = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('componentesSeleccionados');
    await prefs.remove('areaSeleccionada');
    notifyListeners();
  }
}
