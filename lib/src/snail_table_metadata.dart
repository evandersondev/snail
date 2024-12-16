class SnailTableMetadata {
  final String tableName;
  final String primaryKeyColumn;
  final Map<String, SqliteType> fields;

  const SnailTableMetadata({
    required this.tableName,
    required this.primaryKeyColumn,
    required this.fields,
  });

  /// Gera a consulta de criação da tabela
  String generateCreateTableQuery() {
    final fieldDefinitions = fields.entries
        .map((entry) => '${entry.key} ${entry.value.toSql()}')
        .join(', ');

    return '''
      CREATE TABLE IF NOT EXISTS $tableName (
        $fieldDefinitions,
        PRIMARY KEY ($primaryKeyColumn)
      )
    ''';
  }
}

enum SqliteType {
  integer,
  text,
  real,
  blob;

  String toSql() {
    switch (this) {
      case SqliteType.integer:
        return 'INTEGER';
      case SqliteType.text:
        return 'TEXT';
      case SqliteType.real:
        return 'REAL';
      case SqliteType.blob:
        return 'BLOB';
    }
  }
}
