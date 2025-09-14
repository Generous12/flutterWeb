import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ComponenteUpdate {
  final int id;
  final String codigoInventario;
  final String nombreTipo;
  final int cantidad;
  final List<String> imagenesBase64; // lista de imágenes en Base64

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
        // Convertir de array JSON a List<String>
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

  /// Devuelve la imagen decodificada en bytes para usar en Image.memory
  Uint8List? imagenBytes(int index) {
    if (index < 0 || index >= imagenesBase64.length) return null;
    try {
      // Limpiar saltos de línea por si acaso
      final cleanBase64 = imagenesBase64[index].replaceAll('\n', '');
      return base64Decode(cleanBase64);
    } catch (e) {
      print("❌ Error decodificando imagen $index: $e");
      return null;
    }
  }
}

class ComponenteUpdateService {
  final String url =
      "http://192.168.18.24/proyecto_web/backend/procedimientoAlm/list_update_component.php";

  /// =============================
  /// LISTAR COMPONENTES
  /// =============================
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

  /// =============================
  /// ACTUALIZAR CAMPOS (Cantidad, Código, etc)
  /// =============================
  Future<bool> actualizarCampo({
    required String identificador,
    required String columna,
    required String valor,
  }) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "actualizar",
        "identificador": identificador,
        "columna": columna,
        "valor": valor,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    }
    return false;
  }

  /// =============================
  /// ACTUALIZAR IMÁGENES (4 imágenes)
  /// =============================
  Future<bool> actualizarImagenes({
    required String identificador,
    required List<String> imagenes,
  }) async {
    if (imagenes.length != 4) {
      throw Exception("Se requieren 4 imágenes");
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "actualizar_imagenes",
        "identificador": identificador,
        "imagenes": imagenes,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    }
    return false;
  }
}
