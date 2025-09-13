import 'dart:io';

class TipoComponente {
  final int? id; // ID temporal en memoria
  final String nombre;

  TipoComponente({this.id, required this.nombre});
}

class Atributo {
  final int? id; // ID temporal en memoria
  final int idTipo; // ID del TipoComponente al que pertenece
  final String nombre;
  final String tipoDato;

  Atributo({
    this.id,
    required this.idTipo,
    required this.nombre,
    required this.tipoDato,
  });
}

class Componente {
  final int? id;
  final int idTipo;
  final String codigoInventario;
  final int cantidad;
  final List<File>? imagenes;

  Componente({
    this.id,
    required this.idTipo,
    required this.codigoInventario,
    required this.cantidad,
    this.imagenes,
  });
}
