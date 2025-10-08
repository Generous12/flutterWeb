import 'dart:convert';
import 'package:http/http.dart' as http;

class AreaService {
  final String baseUrl =
      "http://192.168.18.23/proyecto_web/backend/procedimientoAlm/areas_padre_sub.php";

  Future<Map<String, dynamic>> crearAreaPadre(String nombreArea) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"accion": "crearAreaPadre", "nombre_area": nombreArea}),
    );

    return jsonDecode(resp.body);
  }

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

  Future<List<dynamic>> listarAreasPadresGeneral({
    int limit = 10,
    int offset = 0,
    String? busqueda, // ✅ parámetro opcional para búsqueda
  }) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accion": "listarAreasPadresGeneral",
        "limit": limit,
        "offset": offset,
        "busqueda": busqueda ?? "", // 🔹 si no hay búsqueda, se envía vacío
      }),
    );

    final decoded = jsonDecode(resp.body);
    if (decoded["success"] == true) {
      return decoded["areas"] as List;
    }
    return [];
  }

  Future<List<dynamic>> detalleAreaPadre(
    int idAreaPadre, {
    int limit = 10,
    int offset = 0,
  }) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accion": "detalleAreaPadre",
        "id_area_padre": idAreaPadre,
        "limit": limit,
        "offset": offset,
      }),
    );

    final decoded = jsonDecode(resp.body);
    if (decoded["success"] == true) {
      return decoded["areas"] as List;
    }
    return [];
  }

  Future<Map<String, dynamic>> quitarAsignacionArea(int idArea) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"accion": "quitarAsignacionArea", "id_area": idArea}),
    );

    return jsonDecode(resp.body);
  }

  Future<Map<String, dynamic>> asignarAreaPadre(
    int idArea,
    int idAreaPadre,
  ) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accion": "asignarAreaPadre",
        "id_area": idArea,
        "id_area_padre": idAreaPadre,
      }),
    );

    final decoded = jsonDecode(resp.body);
    return decoded;
  }

  Future<List<dynamic>> listarSubAreasPorPadre(int idAreaPadre) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accion": "detalleAreaPadre",
        "id_area_padre": idAreaPadre,
        "limit": 100,
        "offset": 0,
      }),
    );

    final decoded = jsonDecode(resp.body);
    if (decoded["success"] == true) {
      return decoded["areas"] as List;
    }
    return [];
  }
}
