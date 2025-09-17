import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ComponenteUpdate {
  final int id;
  final String codigoInventario;
  final String nombreTipo;
  final int cantidad;
  final List<String> imagenesBase64;
  ComponenteUpdate({
    required this.id,
    required this.codigoInventario,
    required this.nombreTipo,
    required this.cantidad,
    required this.imagenesBase64,
  });
  factory ComponenteUpdate.fromJson(Map<String, dynamic> json) {
    List<String> imagenes = [];
    if (json['imagenes'] != null) {
      try {
        imagenes = List<String>.from(json['imagenes']);
      } catch (e) {
        print("❌ Error al parsear imágenes: $e");
        imagenes = [];
      }
    }
    return ComponenteUpdate(
      id: json['id_componente'],
      codigoInventario: json['codigo_inventario'],
      nombreTipo: json['nombre_tipo'],
      cantidad: int.tryParse(json['cantidad'].toString()) ?? 0,
      imagenesBase64: imagenes,
    );
  }
  Uint8List? imagenBytes(int index) {
    if (index < 0 || index >= imagenesBase64.length) return null;

    try {
      String base64Str = imagenesBase64[index].replaceAll('\n', '').trim();

      // Rellenar con '=' para que sea múltiplo de 4
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
      "http://localhost/proyecto_web/backend/procedimientoAlm/list_update_component.php";

  /// 192.168.236.89
  Future<List<ComponenteUpdate>> listar({
    String busqueda = '',
    int? offset,
    int? limit,
  }) async {
    final Map<String, dynamic> body = {
      "action": "listar",
      "busqueda": busqueda,
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
      final List data = jsonDecode(response.body)['data'] ?? [];
      return data.map((e) => ComponenteUpdate.fromJson(e)).toList();
    } else {
      throw Exception('Error al listar componentes');
    }
  }

  Future<bool> actualizarComponente({
    required String identificador,
    int? cantidad,
    required List<String?> imagenes,
  }) async {
    // 🔹 Aseguramos siempre 4 slots
    final List<String?> imagenesFinal = List.generate(4, (i) {
      if (i < imagenes.length) return imagenes[i];
      return null;
    });

    print("📤 Preparando payload para backend:");
    print("Identificador: $identificador");
    print("Cantidad: $cantidad");
    for (int i = 0; i < imagenesFinal.length; i++) {
      final img = imagenesFinal[i];
      print(
        img != null
            ? "Imagen slot $i: ${img.substring(0, img.length > 50 ? 0 : 0)}..." // Solo debug
            : "Imagen slot $i: null",
      );
    }

    // 🔹 Preparar payload
    final Map<String, dynamic> cambios = {"identificador": identificador};

    if (cantidad != null) cambios["cantidad"] = cantidad;

    // Aquí distinguimos entre actualizar/añadir y eliminar imágenes
    // - null = no tocar
    // - "" = eliminar
    // - base64 o URL = actualizar
    if (imagenesFinal.any((img) => img != null)) {
      cambios["imagenes"] = imagenesFinal;
    }

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
  }
}
