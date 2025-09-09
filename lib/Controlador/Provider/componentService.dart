import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_web/Clases/providerClases.dart';
import 'package:proyecto_web/Controlador/mysql/conexion.dart';

class ComponentService extends ChangeNotifier {
  TipoComponente? tipoSeleccionado;
  final List<Atributo> atributos = [];
  Componente? componenteCreado;
  final Map<int, String> valoresAtributos = {};
  //CONEXION MYSQL---------------------------------------------------------------

  final String baseUrl = "https://flutterweb-production.up.railway.app";

  Future<void> guardarEnBackend() async {
    if (tipoSeleccionado == null || componenteCreado == null) {
      throw Exception("❌ Tipo de componente o componente vacío");
    }

    final api = ComponenteApiService();

    try {
      // 1. Registrar Tipo
      final tipoId = await api.registrarTipoComponente(tipoSeleccionado!);
      await Future.delayed(const Duration(milliseconds: 300));

      // 2. Registrar Atributos
      final Map<int, int> mapaAtributoIds = {};
      // clave = atributo.id local, valor = atributo.id real BD
      for (final atributo in atributos) {
        final res = await http.post(
          Uri.parse("${api.baseUrl}/atributo"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id_tipo": tipoId,
            "nombre_atributo": atributo.nombre,
            "tipo_dato": atributo.tipoDato,
          }),
        );
        if (res.statusCode != 200) {
          throw Exception("Error creando atributo: ${atributo.nombre}");
        }
        final attrId = jsonDecode(res.body)["id"];
        mapaAtributoIds[atributo.id!] = attrId;

        await Future.delayed(const Duration(milliseconds: 200));
      }

      // 3. Registrar Componente
      final compId = await api.registrarComponente(
        Componente(
          id: componenteCreado!.id,
          idTipo: tipoId,
          codigoInventario: componenteCreado!.codigoInventario,
          cantidad: componenteCreado!.cantidad,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 300));

      // 4. Registrar valores de atributos
      for (final atributo in atributos) {
        final val = valoresAtributos[atributo.id];
        if (val == null) continue;

        final idAtributoBD = mapaAtributoIds[atributo.id];
        if (idAtributoBD == null) continue;

        await api.registrarValorAtributo(
          idComponente: compId,
          idAtributo: idAtributoBD,
          valor: val,
        );
        await Future.delayed(const Duration(milliseconds: 200));
      }

      print("✅ Guardado en backend completado");
    } catch (e) {
      print("❌ Error en guardarEnBackend: $e");
      rethrow;
    }
  }

  //CONEXION MYSQL---------------------------------------------------------------

  // Crear Tipo de Componente REGITRAR 1
  void crearTipoComponente(String nombre) {
    tipoSeleccionado = TipoComponente(
      id: DateTime.now().millisecondsSinceEpoch,
      nombre: nombre,
    );
    notifyListeners();
  }

  // Agregar Atributo REGITRAR 2
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

  // Crear Componente REGITRAR 3
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

  // Guardar valor de atributo REGITRAR 4
  void setValorAtributo(int index, String valor) {
    valoresAtributos[index] = valor;
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
