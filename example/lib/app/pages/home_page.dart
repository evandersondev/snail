import 'package:example_snail_package/app/models/user_model.dart';
import 'package:example_snail_package/app/repositories/user_repository.dart';
import 'package:flutter/material.dart';

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

    // initAsync();
  }

  Future<void> initAsync() async {
    final response = await _respository.findMany();

    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index].name),
            subtitle: Text(users[index].email),
          );
        },
      ),
    );
  }
}
