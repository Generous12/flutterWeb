import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_web/Clases/providerClases.dart';

class ComponentService extends ChangeNotifier {
  TipoComponente? tipoSeleccionado;
  final List<Atributo> atributos = [];
  Componente? componenteCreado;
  bool? conectado;
  final Map<int, String> valoresAtributos = {};
  final Map<int, int> atributoIdDBMap = {};
  int _tempIdCounter = 0;

  void crearTipoComponente(String nombre, {bool reemplazar = false}) {
    if (tipoSeleccionado != null && !reemplazar) return;

    tipoSeleccionado = TipoComponente(
      id: tipoSeleccionado?.id ?? _tempIdCounter++,
      nombre: nombre,
    );
    notifyListeners();
  }

  void agregarAtributo(
    String nombre,
    String tipoDato, {
    bool reemplazar = false,
  }) {
    if (tipoSeleccionado == null) return;

    if (reemplazar) {
      final index = atributos.indexWhere(
        (a) =>
            a.nombre == nombre &&
            a.tipoDato == tipoDato &&
            a.idTipo == tipoSeleccionado!.id,
      );
      if (index != -1) {
        atributos[index] = Atributo(
          id: atributos[index].id,
          idTipo: tipoSeleccionado!.id!,
          nombre: nombre,
          tipoDato: tipoDato,
        );
        notifyListeners();
        return;
      }
    }

    final tempId = _tempIdCounter++;
    atributos.add(
      Atributo(
        id: tempId,
        idTipo: tipoSeleccionado!.id!,
        nombre: nombre,
        tipoDato: tipoDato,
      ),
    );
    notifyListeners();
  }

  void eliminarAtributo(int idAtributo) {
    atributos.removeWhere((a) => a.id == idAtributo);
    valoresAtributos.remove(idAtributo);
    atributoIdDBMap.remove(idAtributo);
    notifyListeners();
  }

  void crearComponente(
    String codigo,
    int cantidad, {
    List<File>? imagenes,
    String? tipoNombre,
    bool reemplazar = false,
  }) {
    if (componenteCreado != null && !reemplazar) return;

    if (componenteCreado != null) {
      componenteCreado = Componente(
        id: componenteCreado!.id,
        idTipo: componenteCreado!.idTipo,
        codigoInventario: codigo,
        cantidad: cantidad,
        imagenes: imagenes ?? componenteCreado!.imagenes,
        tipoNombre: tipoNombre ?? componenteCreado!.tipoNombre,
      );
    } else {
      componenteCreado = Componente(
        idTipo: tipoSeleccionado!.id!,
        codigoInventario: codigo,
        cantidad: cantidad,
        imagenes: imagenes ?? [],
        tipoNombre: tipoNombre ?? tipoSeleccionado!.nombre,
      );
    }

    notifyListeners();
  }

  void setValorAtributo(int idAtributo, String valor) {
    if (valoresAtributos[idAtributo] == valor) return;
    valoresAtributos[idAtributo] = valor;
    notifyListeners();
  }

  void reset() {
    tipoSeleccionado = null;
    atributos.clear();
    componenteCreado = null;
    valoresAtributos.clear();
    atributoIdDBMap.clear();
    _tempIdCounter = 0;
    notifyListeners();
  }

  String generarCodigoInventario() {
    if (tipoSeleccionado == null) return "";
    final base = tipoSeleccionado!.nombre.substring(0, 3).toUpperCase();
    return "$base-${_tempIdCounter++}";
  }

  void mapAtributoDBId(int tempId, int dbId) {
    atributoIdDBMap[tempId] = dbId;
    notifyListeners();
  }

  int? getDbIdAtributo(int tempId) => atributoIdDBMap[tempId];

  Future<bool> guardarEnBackendB() async {
    print("🔹 Iniciando guardarEnBackendB()");

    if (tipoSeleccionado == null || componenteCreado == null) {
      print("❌ Error: tipoSeleccionado o componenteCreado es null");
      return false;
    }

    final url = Uri.parse(
      "http://192.168.72.89/proyecto_web/backend/procedimientoAlm/registrar_componente.php",
    );

    final atributosJson = atributos.map((attr) {
      final valor = valoresAtributos[attr.id!] ?? "";
      print("   Atributo a enviar -> ${attr.nombre}: $valor");
      return {
        "nombre": attr.nombre,
        "tipo_dato": attr.tipoDato,
        "valor": valor,
      };
    }).toList();

    final imagenesBase64 = componenteCreado!.imagenes!
        .map((file) {
          try {
            final base64Str = base64Encode(file.readAsBytesSync());
            print("   Imagen codificada: ${file.path}");
            return base64Str;
          } catch (e) {
            print("❌ Error codificando imagen ${file.path}: $e");
            return null;
          }
        })
        .whereType<String>()
        .toList();

    print("🔹 Número de imágenes a enviar: ${imagenesBase64.length}");

    final body = jsonEncode({
      "nombre_tipo": tipoSeleccionado!.nombre,
      "codigo_inventario": componenteCreado!.codigoInventario,
      "cantidad": componenteCreado!.cantidad,
      "atributos": atributosJson,
      "imagenes": imagenesBase64,
      "tipo_nombre": componenteCreado!.tipoNombre,
    });

    print("🚀 Body enviado al backend: $body");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("📶 Status code: ${response.statusCode}");
      print("📦 Respuesta raw: ${response.body}");

      final data = jsonDecode(response.body);
      print("📦 Respuesta parseada: $data");

      if (data['success'] == true) {
        print("✅ Componente registrado correctamente");

        tipoSeleccionado = TipoComponente(
          id: int.parse(data['id_tipo'].toString()),
          nombre: tipoSeleccionado!.nombre,
        );

        componenteCreado = Componente(
          id: int.parse(data['id_componente'].toString()),
          idTipo: tipoSeleccionado!.id!,
          codigoInventario: componenteCreado!.codigoInventario,
          cantidad: componenteCreado!.cantidad,
          tipoNombre: componenteCreado!.tipoNombre,
          imagenes: componenteCreado!.imagenes,
        );

        for (var i = 0; i < atributos.length; i++) {
          final dbId = data['atributos'][i]['id_atributo'] != null
              ? int.tryParse(data['atributos'][i]['id_atributo'].toString())
              : null;
          if (dbId != null) {
            atributoIdDBMap[atributos[i].id!] = dbId;
            print("   Atributo ${atributos[i].nombre} asignado ID: $dbId");
          }
        }

        return true;
      }

      print("❌ Error backend: ${data['message'] ?? 'sin mensaje'}");
      return false;
    } catch (e, stacktrace) {
      print("💥 Excepción al guardar en backend: $e");
      print("📝 Stacktrace: $stacktrace");
      return false;
    }
  }
}
