import 'dart:convert';

import 'package:http/http.dart' as http;

class ComponenteAtributo {
  final int idComponente;
  final String nombreTipo;
  final String codigoInventario;
  final int totalAtributos;

  ComponenteAtributo({
    required this.idComponente,
    required this.nombreTipo,
    required this.codigoInventario,
    required this.totalAtributos,
  });

  factory ComponenteAtributo.fromJson(Map<String, dynamic> json) {
    return ComponenteAtributo(
      idComponente: int.parse(json["id_componente"].toString()),
      nombreTipo: json["nombre_tipo"] ?? "",
      codigoInventario: json["codigo_inventario"] ?? "",
      totalAtributos: int.parse(json["total_atributos"].toString()),
    );
  }
}

class ComponenteServiceAtributo {
  final String url =
      "http://192.168.18.21/proyecto_web/backend/procedimientoAlm/atributosComponente/listarcomponenAtri.php";

  Future<List<ComponenteAtributo>> listarComponentes({
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"limit": limit, "offset": offset}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"] == true && data["data"] != null) {
        final List lista = data["data"];
        return lista.map((e) => ComponenteAtributo.fromJson(e)).toList();
      } else {
        throw Exception(data["message"] ?? "Error al obtener datos");
      }
    } else {
      throw Exception("Error de conexión: ${response.statusCode}");
    }
  }
}
