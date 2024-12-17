import 'package:sqflite/sqflite.dart';

import 'package:snail/snail.dart';

/// A base class for repositories that handle the operations on database tables.
///
/// It provides methods for creating, reading, updating, and deleting records in 
/// the database table defined by the repository. It uses SQLite as the database 
/// backend via the [sqflite] package.
abstract class SnailRepository<T, ID> {
  final String tableName;
  final String primaryKeyColumn;
  final Map<String, Type> defineFields;

  /// Creates an instance of [SnailRepository] with the specified table name, 
  /// primary key column, and field definitions.
  ///
  /// [tableName] is the name of the table in the database.
  /// [primaryKeyColumn] is the column name that serves as the primary key.
  /// [defineFields] is a map of column names to data types that defines the schema of the table.
  SnailRepository({
    required this.tableName,
    required this.primaryKeyColumn,
    required this.defineFields,
  });

  Future<Database> _getDatabase() async {
    return await Snail.getDatabase();
  }

  /// Generates the SQL query to create the table for this repository.
  ///
  /// This method converts the field definitions into a valid SQL `CREATE TABLE` statement.
  String generateCreateTableQuery() {
    final fieldDefinitions = defineFields.entries
        .map((entry) => '${entry.key} ${_typeToSql(entry.value)}')
        .join(', ');

    return '''
      CREATE TABLE IF NOT EXISTS $tableName (
        $fieldDefinitions,
        PRIMARY KEY ($primaryKeyColumn)
      )
    ''';
  }

  /// Converts a Dart [Type] to its corresponding SQL type.
  String _typeToSql(Type type) {
    if (type == int) {
      return 'INTEGER';
    } else if (type == String) {
      return 'TEXT';
    } else if (type == double) {
      return 'REAL';
    } else if (type == bool) {
      return 'INTEGER';
    } else {
      return 'BLOB';
    }
  }

  /// Inserts a new item into the database.
  ///
  /// [entity] is the object to be inserted into the database.
  /// Returns the ID of the newly created record.
  Future<int> create(T entity) async {
    final db = await _getDatabase();
    var result = await db.insert(tableName, toMap(entity));
    return result;
  }

  /// Inserts multiple items into the database.
  ///
  /// [entities] is a list of objects to be inserted into the database.
  /// Returns a list of IDs of the newly created records.
  Future<List<int>> createMany(List<T> entities) async {
    final db = await _getDatabase();
    List<int> ids = [];
    for (var entity in entities) {
      var result = await db.insert(tableName, toMap(entity));
      ids.add(result);
    }
    return ids;
  }

  /// Retrieves a single item by its ID from the database.
  ///
  /// [id] is the primary key value of the item to be retrieved.
  /// Returns the entity of type [T], or null if not found.
  Future<T?> findOne(ID id) async {
    final db = await _getDatabase();
    var result = await db.query(
      tableName,
      where: '$primaryKeyColumn = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return fromMap(result.first);
    }
    return null;
  }

  /// Retrieves all items from the database.
  ///
  /// Returns a list of entities of type [T].
  Future<List<T>> findMany() async {
    final db = await _getDatabase();
    var result = await db.query(tableName);
    return result.map((e) => fromMap(e)).toList();
  }

  /// Deletes an item by its ID from the database.
  ///
  /// [id] is the primary key value of the item to be deleted.
  /// Returns the number of rows affected.
  Future<int> delete(ID id) async {
    final db = await _getDatabase();
    var result = await db.delete(
      tableName,
      where: '$primaryKeyColumn = ?',
      whereArgs: [id],
    );
    return result;
  }

  /// Deletes multiple items by their IDs from the database.
  ///
  /// [ids] is a list of primary key values of the items to be deleted.
  /// Returns the number of rows affected.
  Future<int> deleteMany(List<ID> ids) async {
    final db = await _getDatabase();
    var result = await db.delete(
      tableName,
      where:
          '$primaryKeyColumn IN (${List.filled(ids.length, '?').join(', ')})',
      whereArgs: ids,
    );
    return result;
  }

  /// Updates an existing item in the database.
  ///
  /// [entity] is the object to be updated.
  /// Returns the number of rows affected.
  Future<int> update(T entity) async {
    final db = await _getDatabase();
    var result = await db.update(
      tableName,
      toMap(entity),
      where: '$primaryKeyColumn = ?',
      whereArgs: [primaryKeyColumn],
    );
    return result;
  }

  /// Updates multiple items in the database.
  ///
  /// [entities] is a list of objects to be updated.
  /// Returns the number of rows affected.
  Future<int> updateMany(List<T> entities) async {
    final db = await _getDatabase();
    int updatedCount = 0;
    for (var entity in entities) {
      updatedCount += await db.update(
        tableName,
        toMap(entity),
        where: '$primaryKeyColumn = ?',
        whereArgs: [primaryKeyColumn],
      );
    }
    return updatedCount;
  }

  /// Converts an entity of type [T] to a map that can be inserted into the database.
  ///
  /// This method must be implemented by subclasses to define how an entity is
  /// converted to a map representation.
  Map<String, dynamic> toMap(T entity);

  /// Converts a map from the database to an entity of type [T].
  ///
  /// This method must be implemented by subclasses to define how a map is
  /// converted back to an entity.
  T fromMap(Map<String, dynamic> map);
}