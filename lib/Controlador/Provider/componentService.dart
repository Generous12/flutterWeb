import 'package:flutter/material.dart';
import 'package:proyecto_web/Clases/providerClases.dart';

class ComponentService extends ChangeNotifier {
  TipoComponente? tipoSeleccionado;
  final List<Atributo> atributos = [];
  Componente? componenteCreado;
  final Map<int, String> valoresAtributos = {};

  // Crear Tipo de Componente
  void crearTipoComponente(String nombre) {
    tipoSeleccionado = TipoComponente(
      id: DateTime.now().millisecondsSinceEpoch,
      nombre: nombre,
    );
    notifyListeners();
  }

  // Agregar Atributo
  void agregarAtributo(String nombre, String tipoDato) {
    if (tipoSeleccionado == null) return;
    atributos.add(
      Atributo(
        id: DateTime.now().millisecondsSinceEpoch,
        idTipo: tipoSeleccionado!.id!,
        nombre: nombre,
        tipoDato: tipoDato,
      ),
    );
    notifyListeners();
  }

  // Eliminar Atributo
  void eliminarAtributo(int idAtributo) {
    atributos.removeWhere((a) => a.id == idAtributo);
    valoresAtributos.remove(idAtributo);
    notifyListeners();
  }

  // Crear Componente
  void crearComponente(String codigo, int cantidad) {
    if (tipoSeleccionado == null) return;
    componenteCreado = Componente(
      id: DateTime.now().millisecondsSinceEpoch,
      idTipo: tipoSeleccionado!.id!,
      codigoInventario: codigo,
      cantidad: cantidad,
    );
    notifyListeners();
  }

  // Guardar valor de atributo
  void setValorAtributo(int idAtributo, String valor) {
    valoresAtributos[idAtributo] = valor;
    notifyListeners();
  }

  // Limpiar todo
  void reset() {
    tipoSeleccionado = null;
    atributos.clear();
    componenteCreado = null;
    valoresAtributos.clear();
    notifyListeners();
  }

  String generarCodigoInventario() {
    if (tipoSeleccionado == null) return "";
    // Ejemplo: usar las primeras 3 letras del nombre + timestamp
    final base = tipoSeleccionado!.nombre.substring(0, 3).toUpperCase();
    return "$base-${DateTime.now().millisecondsSinceEpoch}";
  }
}
