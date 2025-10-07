import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ComponenteUpdate {
  final int id;
  final int idTipo;
  final String codigoInventario;
  final String nombreTipo;
  final String tipoNombre;

  final int cantidad;
  final List<String?> imagenesBase64;
  ComponenteUpdate({
    required this.id,
    required this.idTipo,
    required this.codigoInventario,
    required this.nombreTipo,
    required this.tipoNombre,
    required this.cantidad,
    required this.imagenesBase64,
  });
  factory ComponenteUpdate.fromJson(Map<String, dynamic> json) {
    List<String?> imagenes = [null, null, null, null];

    if (json['imagenes'] != null) {
      try {
        final List rawImgs = json['imagenes'];
        for (int i = 0; i < rawImgs.length && i < 4; i++) {
          final val = rawImgs[i];
          if (val == null || (val is String && val.isEmpty)) {
            imagenes[i] = null;
          } else {
            imagenes[i] = val.toString();
          }
        }
      } catch (e) {
        print("❌ Error al parsear imágenes: $e");
      }
    }

    return ComponenteUpdate(
      id: json['id_componente'],
      idTipo: json["id_tipo"],
      codigoInventario: json['codigo_inventario'],
      nombreTipo: json['nombre_tipo'],
      tipoNombre: json['tipo_nombre'] ?? '',
      cantidad: int.tryParse(json['cantidad'].toString()) ?? 0,
      imagenesBase64: imagenes,
    );
  }

  Uint8List? imagenBytes(int index) {
    if (index < 0 || index >= imagenesBase64.length) return null;

    try {
      final raw = imagenesBase64[index];

      if (raw == null || raw.isEmpty) {
        print("⚠️ Imagen[$index] inválida o vacía: $raw");
        return null;
      }
      String base64Str = raw.contains(",") ? raw.split(",").last : raw;
      base64Str = base64Str.replaceAll('\n', '').trim();
      final mod = base64Str.length % 4;
      if (mod != 0) {
        base64Str = base64Str.padRight(base64Str.length + (4 - mod), '=');
      }

      return base64Decode(base64Str);
    } catch (e) {
      print("❌ Error decodificando imagen $index: $e");
      return null;
    }
  }
}

class ComponenteUpdateService {
  final String url =
      "http://172.25.10.207/proyecto_web/backend/procedimientoAlm/list_update_component.php";

  Future<List<ComponenteUpdate>> listar({
    String busqueda = '',
    String tipo = 'General',
    int? offset,
    int? limit,
  }) async {
    final Map<String, dynamic> body = {
      "action": "listar",
      "busqueda": busqueda,
      "tipo": tipo,
    };

    if (offset != null && limit != null) {
      body["offset"] = offset;
      body["limit"] = limit;
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final jsonResp = jsonDecode(response.body);
      final List data = jsonResp['data'] ?? [];
      for (int i = 0; i < data.length; i++) {
        final comp = data[i];
        final imagenes = comp["imagenes"];
        print("📦 Componente $i => ${comp["codigo_inventario"]}");
        if (imagenes is List) {
          for (int j = 0; j < imagenes.length; j++) {
            final img = imagenes[j];
            if (img == null) {
              print("  🟤 Imagen[$j]: null");
            } else if ((img as String).isEmpty) {
              print("  ⚪ Imagen[$j]: VACÍA");
            } else if (img.startsWith("data:image")) {
              print(
                "  🟢 Imagen[$j]: con cabecera data:image (length=${img.length})",
              );
            } else {
              print("  🔵 Imagen[$j]: base64 pura (length=${img.length})");
            }
          }
        } else {
          print("  ❌ Imagenes no es lista: $imagenes");
        }
      }

      return data.map((e) => ComponenteUpdate.fromJson(e)).toList();
    } else {
      throw Exception('Error al listar componentes');
    }
  }

  Future<bool> actualizarComponente({
    required String identificador,
    int? cantidad,
    required List<String?> imagenesNuevas,
    List<String?>? imagenesActuales,
    String? nuevoCodigo,
    String? nuevoNombreTipo,
    String? nuevoTipoNombre,
    required String idUsuarioCreador,
    required String rolCreador,
  }) async {
    final List<String?> imagenesFinal = List.generate(4, (i) {
      if (i < imagenesNuevas.length && imagenesNuevas[i] != null) {
        return imagenesNuevas[i];
      }
      if (imagenesActuales != null && i < imagenesActuales.length) {
        return imagenesActuales[i];
      }
      return null;
    });

    print("📤 Preparando payload para backend:");
    print("Identificador: $identificador");
    print("Cantidad: $cantidad");
    print("Nuevo código: $nuevoCodigo");
    print("Nuevo nombre tipo: $nuevoNombreTipo");
    print("Nuevo tipo nombre: $nuevoTipoNombre");

    for (int i = 0; i < imagenesFinal.length; i++) {
      final img = imagenesFinal[i];
      if (img == null) {
        print("Imagen slot $i: (no tocar)");
      } else if (img.isEmpty) {
        print("Imagen slot $i: ELIMINAR");
      } else {
        print("Imagen slot $i: NUEVA/ACTUALIZADA (base64)");
      }
    }

    final Map<String, dynamic> cambios = {
      "identificador": identificador,
      "id_usuario": idUsuarioCreador,
      "rol": rolCreador,
    };
    if (cantidad != null) cambios["cantidad"] = cantidad;
    if (imagenesFinal.any((img) => img != null))
      cambios["imagenes"] = imagenesFinal;
    if (nuevoCodigo != null) cambios["nuevo_codigo"] = nuevoCodigo;
    if (nuevoNombreTipo != null) cambios["nuevo_nombre_tipo"] = nuevoNombreTipo;
    if (nuevoTipoNombre != null) cambios["nuevo_tipo_nombre"] = nuevoTipoNombre;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "actualizar", ...cambios}),
      );

      print("📥 Respuesta raw del backend: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Backend parsed: $data");
        return data['success'] ?? false;
      }

      print("❌ Error HTTP: ${response.statusCode}");
      return false;
    } catch (e) {
      print("❌ Excepción al actualizar componente: $e");
      return false;
    }
  }
}
