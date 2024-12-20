import 'package:flutter/material.dart';
import 'package:snail/snail.dart';

import './app/app_widget.dart';
import 'app/repositories/todo_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Snail.initialize(
    repositories: [
      TodoRepository(),
    ],
  );

  runApp(AppWidget());
}
