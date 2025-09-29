import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      "http://192.168.8.14/proyecto_web/backend/procedimientoAlm";

  Future<Map<String, dynamic>> registrarUsuario({
    required String idUsuario,
    required String nombre,
    required String password,
    required String rol,
  }) async {
    final url = Uri.parse("$baseUrl/registrousuarios.php");

    // Datos que se van a enviar
    final body = {
      "accion": "registrarUsuario",
      "id_usuario": idUsuario,
      "nombre": nombre,
      "password": password,
      "rol": rol,
    };

    print("📤 Enviando petición a: $url");
    print("📦 Datos enviados: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("📥 Código de respuesta: ${response.statusCode}");
      print("📥 Respuesta cruda: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print("✅ Respuesta decodificada: $decoded");
        return decoded;
      } else {
        return {"success": false, "message": "Error ${response.statusCode}"};
      }
    } catch (e) {
      print("❌ Error en la petición: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }
}
