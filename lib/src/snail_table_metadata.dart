class SnailTableMetadata {
  final String tableName;
  final String primaryKeyColumn;
  final List<Object> fields;

  const SnailTableMetadata({
    required this.tableName,
    required this.primaryKeyColumn,
    required this.fields,
  });

  /// Gera a consulta de criação da tabela
  String generateCreateTableQuery() {
    final fieldsMap = _typesToSqlMap(fields);

    final fieldDefinitions = fieldsMap.entries
        .map((entry) => '${entry.key} ${entry.value}')
        .join(', ');

    return '''
      CREATE TABLE $tableName (
        $fieldDefinitions,
        PRIMARY KEY ($primaryKeyColumn)
      )
    ''';
  }

  /// Converte os tipos dos objetos para tipos SQL
  Map<String, String> _typesToSqlMap(List<Object> objects) {
    Map<String, String> resultMap = {};

    for (var obj in objects) {
      var type = obj.runtimeType;
      resultMap[obj.toString()] = _sqlFromType(type);
    }

    return resultMap;
  }

  /// Converte o tipo para o tipo SQL correspondente
  String _sqlFromType(Type type) {
    if (type == int) {
      return 'INTEGER';
    } else if (type == String) {
      return 'TEXT';
    } else if (type == double) {
      return 'REAL';
    } else if (type == bool) {
      return 'INTEGER';
    } else {
      return 'UNKNOWN'; // Tipo não reconhecido
    }
  }
}
