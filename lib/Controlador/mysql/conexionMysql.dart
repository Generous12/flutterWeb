import 'package:mysql1/mysql1.dart';

class Database {
  final String host = 'localhost';
  final int port = 3306;
  final String user = 'Inventario';
  final String password = 'ca22ti07br12_1212@12A';
  final String db = 'inventarioapp';

  MySqlConnection? _connection;
  Future<void> connect() async {
    try {
      _connection ??= await MySqlConnection.connect(
        ConnectionSettings(
          host: host,
          port: port,
          user: user,
          password: password,
          db: db,
        ),
      );
      print('✅ Conexión a MySQL exitosa');
    } catch (e) {
      print('❌ Error al conectar a MySQL: $e');
    }
  }

  // Cerrar conexión
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
    print('🔌 Conexión cerrada');
  }
}
