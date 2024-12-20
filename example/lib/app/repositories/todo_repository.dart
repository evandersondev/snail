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

  Future<List<TodoModel>> findByTitleStartingWith(String title) {
    return dynamicMethod('findByTitleStartingWith', [title]);
  }

  Future<List<TodoModel>> findByTitleEndingWith(String title) {
    return dynamicMethod('findByTitleEndingWith', [title]);
  }

  Future<List<TodoModel>> findByTitleContaining(String title) {
    return dynamicMethod('findByTitleContaining', [title]);
  }

  Future<List<TodoModel>> findByIsCompletedTrue() {
    return dynamicMethod('findByIsCompletedTrue');
  }

  Future<List<TodoModel>> findByIsCompletedFalse() {
    return dynamicMethod('findByIsCompletedFalse');
  }
}
