import 'package:path/path.dart';
import 'package:snail/src/snail_repository.dart';
import 'package:sqflite/sqflite.dart';

class Snail {
  static Database? _database;

  /// Inicializa o banco de dados e cria as tabelas
  static Future<void> initialize({
    String? databaseName,
    required List<SnailRepository> repositories,
  }) async {
    print('*** SnailDatabase initialized ***');

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, '${databaseName ?? "snail_database"}.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        for (var repository in repositories) {
          var createTableQuery = repository.generateCreateTableQuery();
          await db.execute(createTableQuery);
          print('--- Create table ${repository.tableName} ---');
        }
      },
      singleInstance: true,
    );
  }

  /// Recupera a instância do banco de dados
  static Future<Database> getDatabase() async {
    if (_database == null) {
      throw Exception(
        'Database not initialized. Call Snail.initialize() first.',
      );
    }
    return _database!;
  }
}
