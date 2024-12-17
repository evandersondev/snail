import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:snail/src/snail_repository.dart';

/// A database handler for SQLite that simplifies the database initialization 
/// and table creation process in Flutter/Dart applications.
///
/// It provides the ability to initialize a database, create tables based 
/// on the provided repositories, and access the database instance.
class Snail {
  static Database? _database;

  /// Initializes the SQLite database and creates tables for the provided repositories.
  ///
  /// This method must be called before any database operations. It initializes 
  /// the database and generates tables based on the repository definitions.
  ///
  /// [databaseName] is the name of the database file. If not provided, it defaults to "snail_database".
  /// [repositories] is a list of [SnailRepository] objects that define the tables and fields to be created.
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
        // Creates tables for each repository
        for (var repository in repositories) {
          var createTableQuery = repository.generateCreateTableQuery();
          await db.execute(createTableQuery);
          print('--- Create table ${repository.tableName} ---');
        }
      },
      singleInstance: true,
    );
  }

  /// Returns the instance of the database.
  ///
  /// This method throws an exception if the database has not been initialized yet.
  static Future<Database> getDatabase() async {
    if (_database == null) {
      throw Exception(
        'Database not initialized. Call Snail.initialize() first.',
      );
    }
    return _database!;
  }
}