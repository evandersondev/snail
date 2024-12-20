import 'package:snail/snail.dart';

import '../models/user_model.dart';

interface class UserRepository extends SnailRepository<UserModel, int> {
  UserRepository()
      : super(
          tableName: 'users',
          primaryKeyColumn: 'id',
          defineFields: {
            'id': int,
            'name': String,
            'email': String,
          },
        );
}
