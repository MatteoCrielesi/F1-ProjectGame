import 'package:postgres/postgres.dart';

class PostgresService {
  Connection? _connection;

  // Connessione al DB
  Future<void> _ensureConnected() async {
    if (_connection == null) {
      _connection = await Connection.open(
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

      await _connection!.execute('SET search_path TO "ForzaFerrari"');
      print('Connessione stabilita con PostgreSQL');
    }
  }

  // Chiudi connessione
  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      print('Connessione chiusa');
    }
  }

  // Ottieni piloti
  Future<List<Map<String, dynamic>>> getPilota() async {
    await _ensureConnected();
    final results = await _connection!.execute(
      'SELECT pilota_id, nome, numero FROM pilota_tp',
    );

    return results.map((row) {
      return {"id": row[0], "nome": row[1] ?? "N/A", "numero": row[2] ?? 0};
    }).toList();
  }

  // Record Tracks
  Future<List<Map<String, dynamic>>> getRecordTracks() async {
    await _ensureConnected();
    final result = await _connection!.execute('''
      SELECT 
        p.nome AS pista,
        p.lunghezza_circuito_km,
        p.zone_drs,
        p.record_pista_quali,
        pil_quali.nome AS pilota_quali,
        p.anno_quali,
        p.record_pista_gara,
        pil_gara.nome AS pilota_gara,
        p.anno_gara
      FROM piste_tp p
      LEFT JOIN pilota_tp pil_quali ON p.detentore_quali = pil_quali.pilota_id
      LEFT JOIN pilota_tp pil_gara ON p.detentore_gara = pil_gara.pilota_id
      ORDER BY p.nome;
    ''');

    return result.map((row) {
      return {
        "pista": row[0] ?? "N/A",
        "lunghezza": row[1] ?? 0,
        "drs": row[2] ?? 0,
        "record_quali": row[3] ?? "N/A",
        "pilota_quali": row[4] ?? "N/A",
        "anno_quali": row[5] ?? "N/A",
        "record_gara": row[6] ?? "N/A",
        "pilota_gara": row[7] ?? "N/A",
        "anno_gara": row[8] ?? "N/A",
      };
    }).toList();
  }

  // 🛑 DNF Totali
  Future<List<Map<String, dynamic>>> getDNFTotals() async {
    await _ensureConnected();
    final results = await _connection!.execute('''
    SELECT 
      pt.nome AS pilota,
      COUNT(*) AS dnf_totali
    FROM risultato_gara_as rga
    JOIN pilota_tp pt ON rga.pilota_id_fk = pt.pilota_id
    WHERE rga.dnf = true
    GROUP BY pt.nome
    ORDER BY dnf_totali DESC;
  ''');

    return results.map((row) {
      return {"pilota": row[0] ?? "N/A", "dnf_totali": row[1] ?? 0};
    }).toList();
  }

  // Pole Positions
  Future<List<Map<String, dynamic>>> getPolePositions() async {
    await _ensureConnected();
    final results = await _connection!.execute('''
      SELECT p.nome, COUNT(*) AS numero
      FROM risultato_gara_as r
      JOIN pilota_tp p ON r.pilota_id_fk = p.pilota_id
      WHERE r.pole = true
      GROUP BY p.nome
      ORDER BY numero DESC;
    ''');

    return results.map((row) {
      return {"pilota": row[0] ?? "N/A", "numero": row[1] ?? 0};
    }).toList();
  }

  // Fastest Laps
  Future<List<Map<String, dynamic>>> getFastestLaps() async {
    await _ensureConnected();
    final results = await _connection!.execute('''
      SELECT p.nome, COUNT(*) AS numero
      FROM risultato_gara_as r
      JOIN pilota_tp p ON r.pilota_id_fk = p.pilota_id
      WHERE r.fast_lap = true
      GROUP BY p.nome
      ORDER BY numero DESC;
    ''');

    return results.map((row) {
      return {"pilota": row[0] ?? "N/A", "numero": row[1] ?? 0};
    }).toList();
  }

  // 🏆 Podi totali (nuova funzione)
  Future<List<Map<String, dynamic>>> getPodiumsTotals() async {
    await _ensureConnected();
    final results = await _connection!.execute('''
      SELECT 
        pt.nome AS pilota,
        COUNT(*) AS podi_totali
      FROM risultato_gara_as rga
      JOIN pilota_tp pt ON rga.pilota_id_fk = pt.pilota_id
      WHERE rga.pista_annata_id_fk BETWEEN 23 AND 62
        AND rga.posizione <= 3
      GROUP BY pt.nome
      ORDER BY podi_totali DESC;
    ''');

    return results.map((row) {
      return {"pilota": row[0] ?? "N/A", "podi_totali": row[1] ?? 0};
    }).toList();
  }
}
