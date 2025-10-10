import 'dart:io';

class TipoComponente {
  final int? id;
  final String nombre;

  TipoComponente({this.id, required this.nombre});
}

class Atributo {
  final int? id;
  final int idTipo;
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
  final String estado;
  final List<File>? imagenes;
  final String tipoNombre;

  Componente({
    this.id,
    required this.idTipo,
    required this.codigoInventario,
    required this.estado,
    this.imagenes,
    required this.tipoNombre,
  });
}
