import 'package:postgres/postgres.dart';

class PostgresService {
  late Connection connection;

  Future<void> connect() async {
    connection = await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'postgres',
        username: 'postgres',
        password: '1234',
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );

    await connection.execute(Sql.named('SET search_path TO "ForzaFerrari"'));

    print('Connessione stabilita con PostgreSQL');
  }

  Future<Result> getPilota() async {
    final results = await connection.execute(
      Sql.named('SELECT pilota_id, nome, numero FROM pilota_tp'),
    );
    return results;
  }

  Future<void> close() async {
    await connection.close();
    print('Connessione chiusa');
  }
}
