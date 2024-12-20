import 'package:example/app/models/todo_model.dart';
import 'package:example/app/repositories/todo_repository.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TodoModel> todos = [];

  final _todoController = TextEditingController();
  final _respository = TodoRepository();

  @override
  void initState() {
    super.initState();

    initAsync();
  }

  Future<void> initAsync() async {
    final response = await _respository.findAll();

    setState(() {
      todos = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_todoController.text.isEmpty) {
            return;
          }

          await _respository.save(
            TodoModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _todoController.text,
            ),
          );
          _todoController.clear();

          await initAsync();
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _todoController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(todos[index].title),
                    trailing: IconButton(
                      onPressed: () async {
                        await _respository.deleteById(todos[index].id);
                        await initAsync();
                      },
                      icon: Icon(Icons.delete),
                    ),
                    onTap: () async {
                      await _respository.save(
                        TodoModel(
                          id: todos[index].id,
                          title: todos[index].title,
                          isCompleted: !todos[index].isCompleted,
                        ),
                      );

                      await initAsync();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
