import 'package:example_snail_package/app/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:snail/snail.dart';

import 'app/models/product_model.dart';
import 'app/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Snail.initialize(databaseName: 'example', models: [
    UserModel,
    ProductModel,
  ]);

  runApp(AppWidget());
}
