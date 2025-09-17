import 'dart:convert';
import 'package:http/http.dart' as http;

class AreaService {
  final String baseUrl =
      "http://192.168.236.89/proyecto_web/backend/procedimientoAlm/areas_padre_sub.php";

  /// Crear Área Padre
  Future<Map<String, dynamic>> crearAreaPadre(String nombreArea) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"accion": "crearAreaPadre", "nombre_area": nombreArea}),
    );

    return jsonDecode(resp.body);
  }

  /// Crear Subárea
  Future<Map<String, dynamic>> crearSubArea(
    String nombreArea,
    int idAreaPadre,
  ) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accion": "crearSubArea",
        "nombre_area": nombreArea,
        "id_area_padre": idAreaPadre,
      }),
    );

    return jsonDecode(resp.body);
  }

  /// Listar Áreas Padres
  Future<List<dynamic>> listarAreasPadres() async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"accion": "listarAreasPadres"}),
    );

    final decoded = jsonDecode(resp.body);
    if (decoded["success"] == true) {
      return decoded["areas"] as List;
    }
    return [];
  }
}
