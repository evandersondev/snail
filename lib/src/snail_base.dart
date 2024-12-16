import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'snail_table_model.dart';

class Snail {
  static Database? _database;

  /// Inicializa o banco de dados e cria as tabelas
  static Future<void> initialize({
    required String databaseName,
    required List<SnailTableModel> models,
  }) async {
    print('*** SnailDatabase initialize ***');

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, '$databaseName.db');
    print(models);

    _database = await openDatabase(
      path,
      version: 1,
      // onCreate: (db, version) async {
      //   print('Creating tables');
      //   for (var model in models) {
      //     // Verifica se o tipo é uma subclasse de SnailTableModel
      //     var metadata = model.metadata;
      //     var createTableQuery = metadata.generateCreateTableQuery();
      //     await db.execute(createTableQuery);
      //     print('Create table ${metadata.tableName}');
      //     // Aqui você pode executar a consulta para criar a tabela no banco
      //   }
      // },
      onOpen: (db) async {
        print('Creating tables');
        for (var model in models) {
          // Verifica se o tipo é uma subclasse de SnailTableModel
          print(model.hashCode);
          var metadata = model.metadata;
          var createTableQuery = metadata.generateCreateTableQuery();
          print(createTableQuery);
          // await db.execute(createTableQuery);
          print('Create table ${metadata.tableName}');
          // Aqui você pode executar a consulta para criar a tabela no banco
        }

        // final result = await db.rawQuery('SELECT * from users;');

        // print(result);
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
