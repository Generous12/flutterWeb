import 'dart:convert';
import 'package:http/http.dart' as http;

class EliminarComponenteService {
  final String baseUrl =
      "http://192.168.18.21/proyecto_web/backend/procedimientoAlm";

  /// Método para eliminar un Tipo_Componente por id
  Future<Map<String, dynamic>> eliminarTipo(int idTipo) async {
    final url = Uri.parse('$baseUrl/eliminar_componente.php');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_tipo": idTipo}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Contendrá success y message
      } else {
        return {
          "success": false,
          "message": "Error en el servidor: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
