import 'dart:convert';

import 'package:snail/snail.dart';

class UserModel extends SnailTableModel {
  final int id;
  final String name;
  final String email;

  UserModel({
    this.id = 0,
    this.name = '',
    this.email = '',
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'email': email});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  SnailTableMetadata get metadata => SnailTableMetadata(
        tableName: 'users',
        primaryKeyColumn: 'id',
        fields: {
          'id': SqliteType.integer,
          'name': SqliteType.text,
          'email': SqliteType.text,
        },
      );
}
