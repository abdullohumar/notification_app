import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_app/services/http_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

class LocalNotificationService {
  final HttpService httpService;
  LocalNotificationService(this.httpService);

  Future<void> init() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );

    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        final payload = notificationResponse.payload;
        if (payload != null && payload.isNotEmpty) {
          selectNotificationStream.add(payload);
        }
      },
    );
  }

  Future<bool> _isAndroidPermissionGranted() async {
    return await flutterLocalNotificationPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
  }

  Future<bool> _requestAndroidNotificationsPermission() async {
    return await flutterLocalNotificationPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  Future<bool?> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iOSImplementation = flutterLocalNotificationPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await iOSImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final notificationEnable = await _isAndroidPermissionGranted();
      if (!notificationEnable) {
        final requestNotificationsPermission =
            await _requestAndroidNotificationsPermission();
        return requestNotificationsPermission;
      }
      return notificationEnable;
    } else {
      return false;
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    String channelId = '1',
    String channelName = 'Simple Notification',
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('slow_spring_board'),
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      sound: 'slow_spring_board.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    String channelId = '2',
    String channelName = 'Big Picture Notification',
  }) async {
    final String largeIconPath = await httpService.downloadAndSaveFile(
      'https://dummyimage.com/48x48',
      'largeIcon',
    );
    final String bigPicturePath = await httpService.downloadAndSaveFile(
      'https://dummyimage.com/600x200',
      'bigPicture.jpg',
    );

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicturePath),
          largeIcon: FilePathAndroidBitmap(largeIconPath),
          contentTitle: 'overridden <b>big</b> content title',
          htmlFormatContentTitle: true,
          summaryText: 'Summary <i>text</i>',
          htmlFormatSummaryText: true,
        );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
    );
    final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      attachments: [
        DarwinNotificationAttachment(bigPicturePath, hideThumbnail: false),
      ],
    );
    final notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationPlugin.show(id, title, body, notificationDetails, payload: payload);
  }
}
