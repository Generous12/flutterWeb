import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_web/Clases/providerClases.dart';

class ComponenteApiService {
  final String baseUrl = "https://flutterweb-production.up.railway.app";

  // Paso 1: Registrar Tipo de Componente
  Future<int> registrarTipoComponente(TipoComponente tipo) async {
    final res = await http.post(
      Uri.parse("$baseUrl/tipo-componente"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": tipo.nombre}),
    );
    if (res.statusCode != 200) throw Exception("Error creando tipo");
    return jsonDecode(res.body)["id"];
  }

  // Paso 2: Registrar Atributo
  Future<int> registrarAtributo(Atributo atributo) async {
    final res = await http.post(
      Uri.parse("$baseUrl/atributo"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_tipo": atributo.idTipo,
        "nombre_atributo": atributo.nombre,
        "tipo_dato": atributo.tipoDato,
      }),
    );
    if (res.statusCode != 200) throw Exception("Error creando atributo");
    return jsonDecode(res.body)["id"];
  }

  // Paso 3: Registrar Componente
  Future<int> registrarComponente(Componente comp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/componente"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_tipo": comp.idTipo,
        "codigo_inventario": comp.codigoInventario,
        "cantidad": comp.cantidad,
      }),
    );
    if (res.statusCode != 200) throw Exception("Error creando componente");
    return jsonDecode(res.body)["id"];
  }

  // Paso 4: Registrar Valor de Atributo
  Future<void> registrarValorAtributo({
    required int idComponente,
    required int idAtributo,
    required String valor,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/valor-atributo"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_componente": idComponente,
        "id_atributo": idAtributo,
        "valor": valor,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception("Error insertando valor atributo");
    }
  }
}
