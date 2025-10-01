import 'dart:convert';
import 'package:http/http.dart' as http;

class GestiousuarioService {
  final String baseUrl =
      "http://192.168.18.21/proyecto_web/backend/procedimientoAlm/usuarios/gestionusuarios.php";

  // Listar usuarios con búsqueda, filtro y paginación
  Future<List<Map<String, dynamic>>> listarUsuarios({
    String? busqueda,
    String? estadoFiltro,
    int pagina = 1,
  }) async {
    final body = jsonEncode({
      "accion": "LISTAR",
      "busqueda": busqueda ?? "",
      "estado_filtro": estadoFiltro ?? "",
      "pagina": pagina,
    });
    print("LISTAR: Enviando request a $baseUrl con body: $body");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("LISTAR: Código de respuesta: ${response.statusCode}");
    print("LISTAR: Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        print("LISTAR: Datos recibidos: ${data['data']}");
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        print("LISTAR: Error desde el servidor: ${data['message']}");
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Error en la conexión: ${response.statusCode}');
    }
  }

  // Actualizar rol y estado de un usuario
  Future<bool> actualizarUsuario(
    String idUsuario,
    String nuevoRol,
    String nuevoEstado,
  ) async {
    final body = jsonEncode({
      "accion": "ACTUALIZAR",
      "id_usuario": idUsuario,
      "nuevo_rol": nuevoRol,
      "nuevo_estado": nuevoEstado,
    });
    print("ACTUALIZAR: Enviando request a $baseUrl con body: $body");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("ACTUALIZAR: Código de respuesta: ${response.statusCode}");
    print("ACTUALIZAR: Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("ACTUALIZAR: Resultado success: ${data['success']}");
      return data['success'];
    } else {
      throw Exception('Error en la conexión: ${response.statusCode}');
    }
  }

  // Eliminar uno o varios usuarios
  Future<bool> eliminarUsuarios(List<String> ids) async {
    String idsStr = ids.map((id) => "'$id'").join(',');
    final body = jsonEncode({"accion": "ELIMINAR", "id_usuario": idsStr});
    print("ELIMINAR: Enviando request a $baseUrl con body: $body");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("ELIMINAR: Código de respuesta: ${response.statusCode}");
    print("ELIMINAR: Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("ELIMINAR: Resultado success: ${data['success']}");
      return data['success'];
    } else {
      throw Exception('Error en la conexión: ${response.statusCode}');
    }
  }
}
