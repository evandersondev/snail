import 'package:sqflite/sqflite.dart';

import 'package:snail/snail.dart';

/// A base class for repositories that handle the operations on database tables.
///
/// It provides methods similar to Spring Data JPA, such as saving, finding,
/// counting, and deleting entities in the database.
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

  /// Gets the database instance.
  Future<Database> _getDatabase() async {
    return await Snail.getDatabase();
  }

  /// Generates the SQL query to create the table for this repository.
  ///
  /// This method converts the field definitions into a valid SQL CREATE TABLE statement.
  String generateCreateTableQuery() {
    final fields = _getFields();

    /// Converts the field names to snake_case and joins them with their types.
    final fieldDefinitions = fields.entries.map((entry) {
      final columnName = toSnakeCase(entry.key);
      final columnType = _typeToSql(entry.value);

      return '$columnName $columnType';
    }).join(', ');

    return '''
      CREATE TABLE IF NOT EXISTS $tableName (
        $fieldDefinitions,
        PRIMARY KEY ($primaryKeyColumn)
      )
    ''';
  }

  /// Gets the fields of the table.
  ///
  /// This method returns the fields defined in [defineFields] and adds the `createdAt` and `updatedAt` fields if they are not already defined.
  Map<String, Type> _getFields() {
    final fieldsMap = defineFields;

    /// Adds the `createdAt` field if it is not already defined.
    if (!fieldsMap.keys.contains('createdAt')) {
      fieldsMap.addAll({'createdAt': DateTime});
    }

    /// Adds the `updatedAt` field if it is not already defined.
    if (!fieldsMap.keys.contains('UpdatedAt')) {
      fieldsMap.addAll({'UpdatedAt': DateTime});
    }

    return fieldsMap;
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
    } else if (type == DateTime) {
      return 'TEXT';
    } else {
      return 'BLOB';
    }
  }

  // CRUD Operations

  /// Saves or updates an entity in the database.
  ///
  /// If the entity exists (based on its primary key), it will be updated; otherwise, it will be inserted.
  Future<int> save(T entity) async {
    final db = await _getDatabase();

    // Verifica se a entidade já existe
    final id = getEntityId(entity);
    final exists = await existsById(id);

    final map = entityToMapValue(entity);

    if (exists) {
      map.addAll({'updated_at': DateTime.now().toString()});

      // Atualiza a entidade
      return await db.update(
        tableName,
        map,
        where: '$primaryKeyColumn = ?',
        whereArgs: [id],
      );
    } else {
      map.addAll({'created_at': DateTime.now().toString()});
      map.addAll({'updated_at': DateTime.now().toString()});

      // Insere a entidade
      return await db.insert(tableName, map);
    }
  }

  /// Saves or updates a list of entities in the database.
  ///
  /// For each entity, if it exists (based on its primary key), it will be updated; otherwise, it will be inserted.
  Future<List<int>> saveAll(List<T> entities) async {
    final db = await _getDatabase();
    List<int> results = [];

    for (var entity in entities) {
      final id = getEntityId(entity);
      final exists = await existsById(id);

      final map = entityToMapValue(entity);

      if (exists) {
        map.addAll({'updated_at': DateTime.now().toString()});

        await db.update(
          tableName,
          map,
          where: '$primaryKeyColumn = ?',
          whereArgs: [id],
        );
      } else {
        map.addAll({'created_at': DateTime.now().toString()});
        map.addAll({'updated_at': DateTime.now().toString()});

        final insertedId = await db.insert(tableName, map);
        results.add(insertedId);
      }
    }

    return results;
  }

  /// Finds an entity by its ID.
  Future<T?> findById(ID id) async {
    final db = await _getDatabase();
    var result = await db.query(
      tableName,
      where: '$primaryKeyColumn = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return mapValueToEntity(result.first);
    }
    return null;
  }

  /// Finds all entities in the database.
  Future<List<T>> findAll({
    int? size,
    String? sort,
    int? page,
  }) async {
    final db = await _getDatabase();

    final sortList = sort?.split(',');
    List<String>? order = ['created_at', 'DESC'];

    if (sortList != null) {
      order[0] = toSnakeCase(sortList[0]);
    }

    if (sortList != null && sortList.length > 1) {
      order[1] = sortList[1].toUpperCase();
    }

    final offset = page != null && size != null ? (page - 1) * size : null;

    var result = await db.query(
      tableName,
      limit: size,
      orderBy: order.join(' '),
      offset: offset,
    );

    return result.map((e) => mapValueToEntity(e)).toList();
  }

  /// Finds all entities by their IDs.
  Future<List<T>> findAllById(
    List<ID> ids, {
    int? size,
    String? sort,
    int? page,
  }) async {
    final db = await _getDatabase();

    final sortList = sort?.split(',');
    List<String>? order = ['created_at', 'DESC'];

    if (sortList != null) {
      order[0] = toSnakeCase(sortList[0]);
    }

    if (sortList != null && sortList.length > 1) {
      order[1] = sortList[1].toUpperCase();
    }

    final offset = page != null && size != null ? (page - 1) * size : null;

    var result = await db.query(
      tableName,
      where:
          '$primaryKeyColumn IN (${List.filled(ids.length, '?').join(', ')})',
      whereArgs: ids,
      limit: size,
      orderBy: order.join(' '),
      offset: offset,
    );

    return result.map((e) => mapValueToEntity(e)).toList();
  }

  /// Checks if an entity exists by its ID.
  Future<bool> existsById(ID id) async {
    if (id == null) return false;
    final db = await _getDatabase();
    var result = await db.query(
      tableName,
      where: '$primaryKeyColumn = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  /// Returns the count of entities in the database.
  Future<int> count() async {
    final db = await _getDatabase();
    var result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Deletes an entity by its ID.
  Future<int> deleteById(ID id) async {
    final db = await _getDatabase();
    return await db.delete(
      tableName,
      where: '$primaryKeyColumn = ?',
      whereArgs: [id],
    );
  }

  /// Deletes an entity from the database.
  Future<int> delete(T entity) async {
    final id = toMap(entity)[primaryKeyColumn];
    if (id == null) throw ArgumentError('Entity must have a primary key.');
    return await deleteById(id as ID);
  }

  /// Deletes multiple entities from the database.
  ///
  /// [entities] is a list of entities to be deleted.
  /// Returns the number of rows affected.
  Future<int> deleteAll(List<T>? entities) async {
    if (entities != null) {
      int deletedCount = 0;
      for (var entity in entities) {
        final id = toMap(entity)[primaryKeyColumn];
        if (id == null) throw ArgumentError('Entity must have a primary key.');
        deletedCount += await deleteById(id as ID);
      }
      return deletedCount;
    } else {
      final db = await _getDatabase();
      return await db.delete(tableName);
    }
  }

  /// Gets the primary key value of an entity.
  ID getEntityId(T entity) {
    final map = toMap(entity);
    return map[primaryKeyColumn] as ID;
  }

  /// Converts an entity of type [T] to a map representation.
  Map<String, dynamic> toMap(T entity);

  /// Converts an entity of type [T] to a map with values ready for database storage.
  Map<String, dynamic> entityToMapValue(T entity) {
    final map = toMap(entity);

    // Converts boolean values to 0 and 1, if necessary
    final convertedMap = map.map((key, value) {
      /// Converts a boolean value to an integer representation for database storage.
      if (value is bool) {
        return MapEntry(key, _boolToInt(value)); // True -> 1, False -> 0
      }

      /// Converts a DateTime object to a string representation.
      if (value is DateTime) {
        return MapEntry(key, value.toString());
      }
      return MapEntry(key, value);
    });

    return keysToSnakeCase(convertedMap);
  }

  /// Converts a map to an entity of type [T].
  T fromMap(Map<String, dynamic> map);

  /// Converts a map from the database to an entity of type [T].
  T mapValueToEntity(Map<String, dynamic> map) {
    final fields = keysToSnakeCase(_getFields());

    final convertedMap = map.map((key, value) {
      /// Converts a boolean value from an integer representation in the database.
      if (fields[key] == bool) {
        return MapEntry(key, _intToBool(value)); // True -> 1, False -> 0
      }

      /// Converts a string to a DateTime object.
      if (fields[key] == DateTime) {
        return MapEntry(key, DateTime.parse(value));
      }

      return MapEntry(key, value);
    });

    return fromMap(keysToCamelCase(convertedMap));
  }

  /// Converts a boolean value to an integer representation for database storage.
  ///
  /// Returns `1` if [value] is `true`, otherwise `0`.
  int _boolToInt(bool value) => value ? 1 : 0;

  /// Converts an integer representation from the database to a boolean value.
  ///
  /// Returns `true` if [value] is `1`, otherwise `false`.
  bool _intToBool(int value) => value == 1;

  /// Parses the method name and constructs a query fragment.
  ///
  /// [methodName] is the method name following the naming conventions.
  /// [parameters] is a list of parameters that match the placeholders in the query.
  Future<List<T>> dynamicMethod(String methodName,
      [List<dynamic>? args]) async {
    final db = await _getDatabase();
    final regex = RegExp(r'^(find|findAll)(Where|By)?(.*)$');
    final match = regex.firstMatch(methodName);
    if (match == null) {
      throw UnimplementedError("Method $methodName not implemented");
    }

    final conditions = match.group(3)!;

    String query = 'SELECT * FROM $tableName';
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (conditions.isNotEmpty) {
      final conditionRegex = RegExp(
          r'(And|Or)?(\w+?)(Between|LessThan|GreaterThan|Like|StartingWith|EndingWith|Containing|In|NotIn|OrderBy|True|False|IsNull|NotNull)?$');
      for (final conditionMatch in conditionRegex.allMatches(conditions)) {
        final operator = conditionMatch.group(1) ?? 'And';
        final field = toSnakeCase(conditionMatch.group(2)!);
        final comparator = conditionMatch.group(3);

        if (!keysToSnakeCase(defineFields).containsKey(field)) {
          throw ArgumentError("Field $field not defined in table schema");
        }

        final not = comparator != null && comparator.startsWith('Not');
        String clause;
        switch (comparator) {
          case 'Between':
            clause =
                not ? '$field NOT BETWEEN ? AND ?' : '$field BETWEEN ? AND ?';
            whereArgs.addAll(args!.sublist(
                whereClauses.length * 2, (whereClauses.length + 1) * 2));
            break;
          case 'LessThan':
            clause = not ? '$field >= ?' : '$field < ?';
            whereArgs.add(args![whereClauses.length]);
            break;
          case 'GreaterThan':
            clause = not ? '$field <= ?' : '$field > ?';
            whereArgs.add(args![whereClauses.length]);
            break;
          case 'Like':
            clause = not ? '$field NOT LIKE ?' : '$field LIKE ?';
            whereArgs.add(args![whereClauses.length]);
            break;
          case 'StartingWith':
            clause = not ? '$field NOT LIKE ?' : '$field LIKE ?';
            whereArgs.add('${args![whereClauses.length]}%');
            break;
          case 'EndingWith':
            clause = not ? '$field NOT LIKE ?' : '$field LIKE ?';
            whereArgs.add('%${args![whereClauses.length]}');
            break;
          case 'Containing':
            clause = not ? '$field NOT LIKE ?' : '$field LIKE ?';
            whereArgs.add('%${args![whereClauses.length]}%');
            break;
          case 'In':
            clause = not
                ? '$field NOT IN (${List.filled(args!.length, '?').join(', ')})'
                : '$field IN (${List.filled(args!.length, '?').join(', ')})';
            whereArgs.addAll(args);
            break;
          case 'NotIn':
            clause = not
                ? '$field IN (${List.filled(args!.length, '?').join(', ')})'
                : '$field NOT IN (${List.filled(args!.length, '?').join(', ')})';
            whereArgs.addAll(args);
            break;
          case 'OrderBy':
            clause = '';
            query += ' ORDER BY $field ${not ? 'DESC' : 'ASC'}';
            break;
          case 'True':
            clause = '$field = 1';
            break;
          case 'False':
            clause = '$field = 0';
            break;
          case 'IsNull':
            clause = '$field IS NULL';
            break;
          case 'NotNull':
            clause = '$field IS NOT NULL';
            break;
          default:
            clause = not ? '$field != ?' : '$field = ?';
            whereArgs.add(args![whereClauses.length]);
        }

        if (clause.isNotEmpty) {
          if (operator == 'And' && whereClauses.isNotEmpty) {
            whereClauses.add('AND $clause');
          } else if (operator == 'Or' && whereClauses.isNotEmpty) {
            whereClauses.add('OR $clause');
          } else {
            whereClauses.add(clause);
          }
        }
      }
    }

    if (whereClauses.isNotEmpty) {
      query += ' WHERE ${whereClauses.join(' ')}';
    }

    final result = await db.rawQuery(query, whereArgs);
    return result.map((e) => mapValueToEntity(e)).toList();
  }

  /// Converts a string from camelCase to snake_case.
  String toSnakeCase(String input) {
    if (input.isEmpty) return input;
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      if (i > 0 && input[i].toUpperCase() == input[i]) {
        buffer.write('_');
      }
      buffer.write(input[i].toLowerCase());
    }
    return buffer.toString();
  }

  /// Converts a string from snake_case to camelCase.
  String toCamelCase(String input) {
    final regex = RegExp(r'_([a-z])');
    return input.replaceAllMapped(regex, (Match match) {
      return match.group(1)!.toUpperCase();
    });
  }

  /// Converts the keys of a given Map from camelCase to snake_case.
  Map<String, dynamic> keysToSnakeCase(Map<String, dynamic> map) {
    return map.map((key, value) {
      return MapEntry(toSnakeCase(key), value);
    });
  }

  /// Converts the keys of a given Map from snake_case to camelCase.
  Map<String, dynamic> keysToCamelCase(Map<String, dynamic> map) {
    return map.map((key, value) {
      return MapEntry(toCamelCase(key), value);
    });
  }
}
