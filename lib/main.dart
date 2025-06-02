import 'package:flutter/material.dart';
import 'package:notification_app/screens/detail_screen.dart';
import 'package:notification_app/screens/home_screen.dart';
import 'package:notification_app/static/my_route.dart';

void main() async {
  String route = MyRoute.home.name;

  runApp(
    MyApp(
      initialRoute: route,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      routes: {
        MyRoute.home.name: (context) => const HomeScreen(),
        MyRoute.detail.name: (context) => const DetailScreen(),
      },
    );
  }
}