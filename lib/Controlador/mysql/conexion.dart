import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_web/Clases/providerClases.dart';

class ComponenteApiService {
  final String baseUrl = "https://flutterweb-production.up.railway.app";

  // Paso 1: Registrar Tipo de Componente
  Future<int> registrarTipoComponente(TipoComponente tipo) async {
    print("📌 Registrando tipo de componente: ${tipo.nombre}");
    final res = await http.post(
      Uri.parse("$baseUrl/tipo-componente"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": tipo.nombre}),
    );
    print("📌 Status code tipo: ${res.statusCode}");
    print("📌 Response tipo: ${res.body}");
    if (res.statusCode != 200) throw Exception("Error creando tipo");
    final id = jsonDecode(res.body)["id"];
    print("✅ Tipo creado con id: $id");
    return id;
  }

  // Paso 2: Registrar Atributo
  Future<int> registrarAtributo(Atributo atributo) async {
    print(
      "📌 Registrando atributo: ${atributo.nombre} para tipo ${atributo.idTipo}",
    );
    final res = await http.post(
      Uri.parse("$baseUrl/atributo"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_tipo": atributo.idTipo,
        "nombre_atributo": atributo.nombre,
        "tipo_dato": atributo.tipoDato,
      }),
    );
    print("📌 Status code atributo: ${res.statusCode}");
    print("📌 Response atributo: ${res.body}");
    if (res.statusCode != 200) throw Exception("Error creando atributo");
    final id = jsonDecode(res.body)["id"];
    print("✅ Atributo creado con id: $id");
    return id;
  }

  // Paso 3: Registrar Componente
  Future<int> registrarComponente(Componente comp) async {
    print("📌 Registrando componente con código: ${comp.codigoInventario}");
    final res = await http.post(
      Uri.parse("$baseUrl/componente"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_tipo": comp.idTipo,
        "codigo_inventario": comp.codigoInventario,
        "cantidad": comp.cantidad,
      }),
    );
    print("📌 Status code componente: ${res.statusCode}");
    print("📌 Response componente: ${res.body}");
    if (res.statusCode != 200) throw Exception("Error creando componente");
    final id = jsonDecode(res.body)["id"];
    print("✅ Componente creado con id: $id");
    return id;
  }

  // Paso 4: Registrar Valor de Atributo
  Future<void> registrarValorAtributo({
    required int idComponente,
    required int idAtributo,
    required String valor,
  }) async {
    print(
      "📌 Registrando valor de atributo: $valor para idAtributo $idAtributo",
    );
    final res = await http.post(
      Uri.parse("$baseUrl/valor-atributo"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_componente": idComponente,
        "id_atributo": idAtributo,
        "valor": valor,
      }),
    );
    print("📌 Status code valor atributo: ${res.statusCode}");
    print("📌 Response valor atributo: ${res.body}");
    if (res.statusCode != 200) {
      throw Exception("Error insertando valor atributo");
    }
    print("✅ Valor de atributo registrado");
  }
}
