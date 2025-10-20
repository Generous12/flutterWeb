import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistrarAsignacionService {
  final String baseUrl =
      "http://192.168.8.25/proyecto_web/backend/asignacionesproAlm/registrarasignacion.php";

  Future<Map<String, dynamic>> registrarAsignacion({
    required int idCase,
    required int idArea,
    required List<Map<String, dynamic>> componentes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
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
}
