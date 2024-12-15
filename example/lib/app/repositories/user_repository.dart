import 'package:snail/snail.dart';

import '../models/user_model.dart';

class UserRepository extends SnailRepository<UserModel, int> {
  UserRepository() : super(tableName: 'users', primaryKeyColumn: 'id');

  @override
  Map<String, dynamic> toMap(UserModel entity) => entity.toMap();

  @override
  UserModel fromMap(Map<String, dynamic> map) => UserModel.fromMap(map);

  @override
  int getId(UserModel entity) => entity.id;
}
