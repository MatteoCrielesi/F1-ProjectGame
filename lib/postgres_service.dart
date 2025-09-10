import 'package:postgres/postgres.dart';

class PostgresService {
  late Connection connection;

  Future<void> connect() async {
    connection = await Connection.open(
      Endpoint(
        host:
            'localhost', //Computer e andorid (per android 1. download https://developer.android.com/tools/releases/platform-tools?hl=it    2. dopo aver estratto inserire il percorso in variabili d'ambiente PATH 3.    adb reverse tcp:5432 tcp:5432)
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
