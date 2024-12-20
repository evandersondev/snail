import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<UserModel> users = [];

  final _respository = UserRepository();

  @override
  void initState() {
    super.initState();

    initAsync();
  }

  Future<void> initAsync() async {
    final response = await _respository.findAll();

    setState(() {
      users = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _respository.save(
            UserModel(
              id: 1,
              name: 'Evnderson',
              email: 'evandersondev@mail.com',
            ),
          );

          await initAsync();
        },
        child: Icon(Icons.add),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index].name),
            subtitle: Text(users[index].email),
            trailing: IconButton(
              onPressed: () async {
                await _respository.deleteById(users[index].id);
                await initAsync();
              },
              icon: Icon(Icons.delete),
            ),
          );
        },
      ),
    );
  }
}
