import 'package:snail/snail.dart';
import 'package:sqflite/sqflite.dart';

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

  Future<Database> _getDatabase() async {
    return await Snail.getDatabase();
  }

  /// Generates the SQL query to create the table for this repository.
  ///
  /// This method converts the field definitions into a valid SQL CREATE TABLE statement.
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

  final Map<String, String> _operators = {
    'And': 'AND',
    'Or': 'OR',
    'Between': 'BETWEEN',
    'LessThan': '<',
    'GreaterThan': '>',
    'Like': 'LIKE',
    'StartingWith': 'LIKE',
    'EndingWith': 'LIKE',
    'Containing': 'LIKE',
    'In': 'IN',
    'NotIn': 'NOT IN',
    'OrderBy': 'ORDER BY',
    'True': '= 1',
    'False': '= 0',
    'IsNull': 'IS NULL',
    'NotNull': 'IS NOT NULL',
  };

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
      // Atualiza a entidade
      return await db.update(
        tableName,
        map,
        where: '$primaryKeyColumn = ?',
        whereArgs: [id],
      );
    } else {
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
        await db.update(
          tableName,
          map,
          where: '$primaryKeyColumn = ?',
          whereArgs: [id],
        );
      } else {
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
      return fromMap(result.first);
    }
    return null;
  }

  /// Finds all entities in the database.
  Future<List<T>> findAll() async {
    final db = await _getDatabase();
    var result = await db.query(tableName);
    return result.map((e) => fromMap(e)).toList();
  }

  /// Finds all entities by their IDs.
  Future<List<T>> findAllById(List<ID> ids) async {
    final db = await _getDatabase();
    var result = await db.query(
      tableName,
      where:
          '$primaryKeyColumn IN (${List.filled(ids.length, '?').join(', ')})',
      whereArgs: ids,
    );
    return result.map((e) => fromMap(e)).toList();
  }

  /// Checks if an entity exists by its ID.
  Future<bool> existsById(ID id) async {
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

  ID getEntityId(T entity) {
    final map = toMap(entity);
    return map[primaryKeyColumn] as ID;
  }

  /// Converts an entity of type [T] to a map that can be inserted into the database.
  ///
  /// This method must be implemented by subclasses to define how an entity is
  /// converted to a map representation.
  Map<String, dynamic> toMap(T entity) {
    final map = <String, dynamic>{};

    defineFields.forEach((key, type) {
      final value =
          entityToMapValue(entity); // Implementação depende do seu modelo.
      map[key] = type == bool ? _boolToInt(value as bool) : value;
    });

    return map;
  }

  /// Converts a map from the database to an entity of type [T].
  ///
  /// This method must be implemented by subclasses to define how a map is
  /// converted back to an entity.
  T fromMap(Map<String, dynamic> map) {
    final entity =
        createEmptyEntity(); // Método para criar uma instância vazia.

    defineFields.forEach((key, type) {
      final value = map[key];
      final parsedValue = type == bool ? _intToBool(value as int) : value;
      mapValueToEntity(
          entity, key, parsedValue); // Implementação depende do seu modelo.
    });

    return entity;
  }

  Map<String, dynamic> entityToMapValue(T entity) {
    final map = toMap(entity);

    // Converte valores booleanos para 0 e 1, se necessário
    final convertedMap = map.map((key, value) {
      if (value is bool) {
        return MapEntry(key, value ? 1 : 0); // True -> 1, False -> 0
      }
      return MapEntry(key, value);
    });

    return convertedMap;
  }

  T createEmptyEntity() {
    throw UnimplementedError(
        'Subclasses must implement createEmptyEntity to provide an empty instance of T');
  }

  void mapValueToEntity(T entity, String key, dynamic value) {
    // Aqui você deve implementar a lógica para atribuir o valor ao campo correspondente na entidade.
    // Essa implementação dependerá de como sua entidade é estruturada.
    // Por exemplo:
    final fieldSetter = entity as dynamic;
    fieldSetter[key] =
        value; // Isso funciona se a entidade for dinâmica ou usar reflection.
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
  Future<List<T>>? parseMethod(
      String methodName, List<dynamic> parameters) async {
    if (!methodName.startsWith('findBy')) {
      throw ArgumentError('Method name must start with "findBy".');
    }

    // Remove the "findBy" prefix
    String conditions = methodName.substring(6);

    // Tokenize conditions based on the connectors (And, Or, etc.)
    final tokens = _tokenize(conditions);
    if (tokens.isEmpty) {
      throw ArgumentError('No valid conditions found in the method name.');
    }

    // Validate and convert tokens to SQL-like query
    final queryBuilder = StringBuffer();
    int paramIndex = 0;

    for (final token in tokens) {
      if (_operators.containsKey(token)) {
        // Add SQL operator
        queryBuilder.write(' ${_operators[token]} ');
      } else {
        // Check if there are more parameters for the current token
        if (paramIndex >= parameters.length && !_isUnaryOperator(token)) {
          throw ArgumentError(
              'Insufficient parameters provided for the method name.');
        }

        // Handle different conditions
        if (token == 'Between') {
          queryBuilder.write(
              '${parameters[paramIndex]} BETWEEN ? AND ?'); // Assumes 2 params
          paramIndex += 2;
        } else if (token == 'StartingWith') {
          queryBuilder.write("'${parameters[paramIndex]}%'");
          paramIndex++;
        } else if (token == 'EndingWith') {
          queryBuilder.write("'%'${parameters[paramIndex]}'");
          paramIndex++;
        } else if (token == 'Containing') {
          queryBuilder.write("'%'${parameters[paramIndex]}%'");
          paramIndex++;
        } else if (_isUnaryOperator(token)) {
          queryBuilder.write(token); // True, False, IsNull, NotNull
        } else {
          queryBuilder.write('${parameters[paramIndex]} ${_operators[token]}');
          paramIndex++;
        }
      }
    }

    final db = await _getDatabase();
    var result = await db.rawQuery(queryBuilder.toString());
    return result.map((e) => fromMap(e)).toList();
  }

  /// Tokenizes the conditions part of the method name.
  static List<String> _tokenize(String conditions) {
    final regex = RegExp(
        r'(And|Or|Between|LessThan|GreaterThan|Like|StartingWith|EndingWith|Containing|In|NotIn|OrderBy|True|False|IsNull|NotNull)');
    final matches = regex.allMatches(conditions);
    return matches.map((match) => match.group(0)!).toList();
  }

  /// Checks if the operator is unary (requires no parameters).
  static bool _isUnaryOperator(String operator) {
    return operator == 'True' ||
        operator == 'False' ||
        operator == 'IsNull' ||
        operator == 'NotNull';
  }
}
