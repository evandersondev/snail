import 'package:flutter/material.dart';

import 'pages/home_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snail Example',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
