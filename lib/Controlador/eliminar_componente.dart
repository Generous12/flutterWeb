import 'dart:convert';
import 'package:http/http.dart' as http;

class EliminarComponenteService {
  final String baseUrl =
      "http://192.168.8.14/proyecto_web/backend/procedimientoAlm";

  Future<Map<String, dynamic>> eliminarTipos(List<int> ids) async {
    final url = Uri.parse('$baseUrl/eliminar_componente.php');

    try {
      final idsString = ids.join(",");
      print("➡️ Enviando petición a: $url");
      print("📦 IDs a eliminar: $idsString");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ids": idsString}),
      );

      print("📡 Código de respuesta: ${response.statusCode}");
      print("📨 Respuesta completa: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Decodificado correctamente: $data");
        return data;
      } else {
        print("❌ Error en servidor con código: ${response.statusCode}");
        return {
          "success": false,
          "message": "Error en el servidor: ${response.statusCode}",
        };
      }
    } catch (e) {
      print("💥 Excepción capturada: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }
}
