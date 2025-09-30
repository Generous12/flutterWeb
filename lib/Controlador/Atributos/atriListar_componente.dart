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

class AtributoDetalle {
  final int idAtributo;
  final String nombreAtributo;
  final String tipoDato;
  final String valor;

  AtributoDetalle({
    required this.idAtributo,
    required this.nombreAtributo,
    required this.tipoDato,
    required this.valor,
  });

  factory AtributoDetalle.fromJson(Map<String, dynamic> json) {
    return AtributoDetalle(
      idAtributo: int.parse(json["id_atributo"].toString()),
      nombreAtributo: json["nombre_atributo"] ?? "",
      tipoDato: json["tipo_dato"] ?? "",
      valor: json["valor"] ?? "Sin valor",
    );
  }
}

class ComponenteServiceAtributo {
  final String url =
      "http://192.168.137.50/proyecto_web/backend/procedimientoAlm/atributosComponente/listarcomponenAtri.php";
  final String urlCrud =
      "http://192.168.137.50/proyecto_web/backend/procedimientoAlm/atributosComponente/crudAtri.php";
  Future<List<ComponenteAtributo>> listarComponentes({
    int limit = 10,
    int offset = 0,
    String? busqueda,
  }) async {
    final body = {
      "accion": "listar",
      "limit": limit,
      "offset": offset,
      "busqueda": busqueda,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
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

  Future<Map<String, dynamic>> detalleComponente(int idComponente) async {
    final body = {"accion": "detalle", "id_componente": idComponente};

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final cabecera =
            data["cabecera"]; // contiene id_componente, id_tipo, nombre_tipo, codigo_inventario
        final List listaAtributos = data["atributos"] ?? [];

        return {
          "cabecera": cabecera,
          "atributos": listaAtributos
              .map((e) => AtributoDetalle.fromJson(e))
              .toList(),
        };
      } else {
        throw Exception(data["message"] ?? "Error al obtener detalle");
      }
    } else {
      throw Exception("Error de conexión: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> insertarAtributo(
    int idTipo,
    String nombre,
    String tipoDato,
  ) async {
    final response = await http.post(
      Uri.parse(urlCrud),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accion": "insertar_atributo",
        "id_tipo": idTipo,
        "nombre_atributo": nombre,
        "tipo_dato": tipoDato,
      }),
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true && data["id_atributo"] != null) {
      return data;
    } else {
      return {
        "success": false,
        "id_atributo": null,
        "mensaje": data["mensaje"] ?? "Error al insertar atributo",
      };
    }
  }

  // 2️⃣ Actualizar atributo
  Future<Map<String, dynamic>> actualizarAtributo(
    int idAtributo,
    String nombre,
    String tipoDato,
  ) async {
    final response = await http.post(
      Uri.parse(urlCrud),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accion": "actualizar_atributo",
        "id_atributo": idAtributo,
        "nombre_atributo": nombre,
        "tipo_dato": tipoDato,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> guardarValor(
    int idComponente,
    int idAtributo,
    String valor,
  ) async {
    final response = await http.post(
      Uri.parse(urlCrud),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accion": "guardar_valor",
        "id_componente": idComponente,
        "id_atributo": idAtributo,
        "valor": valor,
      }),
    );

    return jsonDecode(response.body);
  }

  // 4️⃣ Eliminar atributo
  Future<Map<String, dynamic>> eliminarAtributo(int idAtributo) async {
    final response = await http.post(
      Uri.parse(urlCrud),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "accion": "eliminar_atributo",
        "id_atributo": idAtributo,
      }),
    );

    return jsonDecode(response.body);
  }
}
