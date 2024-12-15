import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'snail_table_model.dart';

class Snail {
  static Database? _database;

  /// Inicializa o banco de dados e cria as tabelas
  static Future<void> initialize({
    required String databaseName,
    required List<Type> models,
  }) async {
    print('*** SnailDatabase initialize ***');

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, '$databaseName.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print(models);
        for (var model in models) {
          // Verifica se o tipo é uma subclasse de SnailTableModel
          if (model is SnailTableModel) {
            var metadata = (model as SnailTableModel).metadata;
            var createTableQuery = metadata.generateCreateTableQuery();
            await db.execute(createTableQuery);
            print('Create table ${metadata.tableName}');
            // Aqui você pode executar a consulta para criar a tabela no banco
          }
        }
      },
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
