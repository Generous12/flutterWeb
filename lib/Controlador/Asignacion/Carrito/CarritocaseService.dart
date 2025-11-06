import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_web/Controlador/Componentes/list_Update_Component.dart';
import 'package:proyecto_web/Widgets/dialogalert.dart';
import 'package:proyecto_web/Widgets/toastalertSo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaseProvider extends ChangeNotifier {
  List<ComponenteUpdate> _componentesSeleccionados = [];
  Map<String, dynamic>? _areaSeleccionada;

  List<ComponenteUpdate> get componentesSeleccionados =>
      _componentesSeleccionados;
  Map<String, dynamic>? get areaSeleccionada => _areaSeleccionada;

  Future<void> cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();

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
    if (comp.estadoAsignacion == 'Asignado') {
      ToastUtil.showWarning("El componente ya está asignado");
      return;
    }
    final existe = _componentesSeleccionados.any((c) => c.id == comp.id);
    if (!existe) {
      _componentesSeleccionados.add(comp);
      await _guardarComponentes();
      notifyListeners();
    } else {
      ToastUtil.showWarning("El componente ya fue agregado");
    }
  }

  Future<void> quitarComponente(int idComponente) async {
    final existe = _componentesSeleccionados.any(
      (comp) => comp.id == idComponente,
    );

    if (!existe) {
      ToastUtil.showWarning("Este componente no existe en el carrito ");
      return;
    }

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
            "estado_asignacion": c.estadoAsignacion,
            "imagenes": c.imagenesBase64,
          }),
        )
        .toList();
    await prefs.setStringList('componentesSeleccionados', listaJson);
  }

  Future<void> seleccionarArea(
    Map<String, dynamic> nuevaArea, {
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (_areaSeleccionada != null &&
        _areaSeleccionada!["id_area"] != nuevaArea["id_area"]) {
      final confirmado = await showCustomDialog(
        context: context,
        title: "Confirmar",
        message:
            "Ya tienes un área asignada (${_areaSeleccionada!["nombre_area"]}). ¿Deseas reemplazarla por '${nuevaArea["nombre_area"]}'?",
        confirmButtonText: "Sí, reemplazar",
        cancelButtonText: "No",
      );

      if (confirmado != true) {
        Navigator.pop(context);
        return;
      }

      ToastUtil.showWarning("Área anterior reemplazada");
    }

    _areaSeleccionada = nuevaArea;
    await prefs.setString('areaSeleccionada', json.encode(nuevaArea));
    notifyListeners();
  }

  /// Limpiar todo
  Future<void> limpiarCase() async {
    final tieneDatos =
        _componentesSeleccionados.isNotEmpty || _areaSeleccionada != null;

    if (!tieneDatos) {
      ToastUtil.showInfo("No hay datos que limpiar");
      return;
    }

    _componentesSeleccionados.clear();
    _areaSeleccionada = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('componentesSeleccionados');
    await prefs.remove('areaSeleccionada');
    notifyListeners();

    ToastUtil.showSuccess("Carrito y área limpiados con éxito");
  }

  Future<void> quitarAreaSeleccionada() async {
    if (_areaSeleccionada == null) {
      ToastUtil.showInfo("No hay un área seleccionada actualmente");
      return;
    }

    _areaSeleccionada = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('areaSeleccionada');
    notifyListeners();
  }
}
