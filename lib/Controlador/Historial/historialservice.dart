import 'dart:convert';
import 'package:http/http.dart' as http;

class HistorialService {
  final String baseUrl =
      "http://192.168.18.23/proyecto_web/backend/procedimientoAlm/historial/gestionarhistorial.php";
  Future<List<Map<String, dynamic>>> listarHistorial({
    int page = 1,
    int limit = 30,
  }) async {
    final body = {"accion": "LISTAR", "page": page, "limit": limit};

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception("Error en la conexión: ${response.statusCode}");
    }
  }

  Future<bool> eliminarHistorial({required List<String> ids}) async {
    if (ids.isEmpty) return false;

    final body = {"accion": "ELIMINAR", "ids": ids};

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } else {
      throw Exception("Error en la conexión: ${response.statusCode}");
    }
  }
}
