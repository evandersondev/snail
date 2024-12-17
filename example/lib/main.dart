import 'package:flutter/material.dart';
import 'package:snail/snail.dart';

import './app/app_widget.dart';
import './app/repositories/product_repository.dart';
import './app/repositories/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Snail.initialize(
    repositories: [
      UserRepository(),
      ProductRepository(),
    ],
  );

  runApp(AppWidget());
}
