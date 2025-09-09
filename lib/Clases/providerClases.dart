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
  final int cantidad;

  Componente({
    this.id,
    required this.idTipo,
    required this.codigoInventario,
    required this.cantidad,
  });
}

class ValorAtributo {
  final int? id;
  final int idComponente;
  final int idAtributo;
  final String valor;

  ValorAtributo({
    this.id,
    required this.idComponente,
    required this.idAtributo,
    required this.valor,
  });
}
