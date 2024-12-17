import 'package:snail/snail.dart';
import 'package:sqflite/sqflite.dart';

abstract class SnailRepository<T, ID> {
  final String tableName;
  final String primaryKeyColumn;
  final Map<String, Type> defineFields;

  SnailRepository({
    required this.tableName,
    required this.primaryKeyColumn,
    required this.defineFields,
  });

  Future<Database> _getDatabase() async {
    return await Snail.getDatabase();
  }

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

  // Criar um item
  Future<int> create(T entity) async {
    final db = await _getDatabase();
    var result = await db.insert(tableName, toMap(entity));
    return result;
  }

  // Criar muitos itens
  Future<List<int>> createMany(List<T> entities) async {
    final db = await _getDatabase();
    List<int> ids = [];
    for (var entity in entities) {
      var result = await db.insert(tableName, toMap(entity));
      ids.add(result);
    }
    return ids;
  }

  // Encontrar um item por id
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

  // Encontrar muitos itens
  Future<List<T>> findMany() async {
    final db = await _getDatabase();
    var result = await db.query(tableName);
    return result.map((e) => fromMap(e)).toList();
  }

  // Deletar um item
  Future<int> delete(ID id) async {
    final db = await _getDatabase();
    var result = await db.delete(
      tableName,
      where: '$primaryKeyColumn = ?',
      whereArgs: [id],
    );
    return result;
  }

  // Deletar muitos itens
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

  // Atualizar um item
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

  // Atualizar muitos itens
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

  // Métodos a serem implementados nas subclasses
  Map<String, dynamic> toMap(T entity);
  T fromMap(Map<String, dynamic> map);
}
