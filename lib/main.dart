import 'package:flutter/material.dart';
import 'package:notification_app/providers/local_notification_provider.dart';
import 'package:notification_app/providers/payload_provider.dart';
import 'package:notification_app/screens/detail_screen.dart';
import 'package:notification_app/screens/home_screen.dart';
import 'package:notification_app/services/http_service.dart';
import 'package:notification_app/services/local_notification_service.dart';
import 'package:notification_app/static/my_route.dart';
import 'package:notification_app/static/workmanager_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationAppLaunchDetails = await flutterLocalNotificationPlugin
      .getNotificationAppLaunchDetails();

  String route = MyRoute.home.name;
  String? payload;

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final notificationResponse =
        notificationAppLaunchDetails!.notificationResponse;
    route = MyRoute.detail.name;
    payload = notificationResponse?.payload;
  }
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => HttpService()),
        Provider(create: (context) => LocalNotificationService(
          context.read<HttpService>(),
        )..init()..configureLocalTimeZone()),
        ChangeNotifierProvider(
          create: (context) => LocalNotificationProvider(
            context.read<LocalNotificationService>(),
          )..requestPermissions(),
        ),
        ChangeNotifierProvider(
          create: (context) => PayloadProvider(payload: payload),
        ),
        Provider(create: (context) => WorkmanagerService()..init()),
      ],
      child: MyApp(initialRoute: route),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

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
