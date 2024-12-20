import 'package:example/app/models/todo_model.dart';
import 'package:snail/snail.dart';

interface class TodoRepository extends SnailRepository<TodoModel, String> {
  TodoRepository()
      : super(
          tableName: 'todos',
          primaryKeyColumn: 'id',
          defineFields: {
            'id': String,
            'title': String,
            'isCompleted': bool,
          },
        );

  @override
  TodoModel fromMap(Map<String, dynamic> map) => TodoModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(TodoModel entity) => entity.toMap();
}
