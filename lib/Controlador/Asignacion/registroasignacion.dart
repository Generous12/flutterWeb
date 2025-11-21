import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistrarAsignacionService {
  final String baseUrl =
      "http://192.168.8.25/proyecto_web/backend/asignacionesproAlm/registrarasignacion.php";

  final String baseUrlA =
      "http://192.168.8.25/proyecto_web/backend/asignacionesproAlm/listarcases.php";
  Future<Map<String, dynamic>> registrarAsignacion({
    required int idCaseAsignado, // 🔥 AÑADIDO
    required int idCase,
    required int idArea,
    required List<Map<String, dynamic>> componentes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_case_asignado": idCaseAsignado, // 🔥 AÑADIDO
          "id_case": idCase,
          "id_area": idArea,
          "componentes": componentes,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          return {
            "success": true,
            "message": data["message"],
            "id_case_asignado": data["id_case_asignado"],
          };
        } else {
          return {
            "success": false,
            "message": data["message"] ?? "Error desconocido",
          };
        }
      } else {
        return {
          "success": false,
          "message":
              "Error del servidor (${response.statusCode}): ${response.reasonPhrase}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  Future<List<Map<String, dynamic>>> listarCasesPorArea({
    required int idArea,
    int limit = 10,
    int offset = 0,
    String? busqueda,
  }) async {
    try {
      final body = {
        "accion": "listar",
        "id_area": idArea,
        "limit": limit,
        "offset": offset,
        "busqueda": busqueda ?? "",
      };

      print("🛰️ Enviando petición a $baseUrlA con datos:");
      print(jsonEncode(body));

      final response = await http.post(
        Uri.parse(baseUrlA),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("📡 Respuesta HTTP: ${response.statusCode}");
      print("📦 Cuerpo recibido: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          print("✅ Cases listados correctamente: ${data["data"].length}");
          return List<Map<String, dynamic>>.from(data["data"]);
        } else {
          print("⚠️ Error desde backend: ${data["message"]}");
          throw Exception(data["message"] ?? "Error al listar los cases");
        }
      } else {
        print("🚨 Error HTTP ${response.statusCode}");
        throw Exception("Error HTTP ${response.statusCode}");
      }
    } catch (e, stack) {
      print("❌ Excepción en listarCasesPorArea: $e");
      print(stack);
      throw Exception("Error en listarCasesPorArea: $e");
    }
  }

  Future<Map<String, dynamic>> detalleCaseAsignado(int idCaseAsignado) async {
    try {
      final body = {"accion": "detalle", "id_case_asignado": idCaseAsignado};

      print("🛰️ Enviando petición (detalleCaseAsignado) con datos:");
      print(jsonEncode(body));

      final response = await http.post(
        Uri.parse(baseUrlA),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("📡 Respuesta HTTP: ${response.statusCode}");
      print("📦 Cuerpo recibido: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          print("✅ Detalle obtenido correctamente.");
          return {"case": data["case"], "componentes": data["componentes"]};
        } else {
          print("⚠️ Error desde backend: ${data["message"]}");
          throw Exception(data["message"] ?? "Error al obtener el detalle");
        }
      } else {
        print("🚨 Error HTTP ${response.statusCode}");
        throw Exception("Error HTTP ${response.statusCode}");
      }
    } catch (e, stack) {
      print("❌ Excepción en detalleCaseAsignado: $e");
      print(stack);
      throw Exception("Error en detalleCaseAsignado: $e");
    }
  }
}
