import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/api/config/api_config.dart';
import 'package:sona/main.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.max,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if(message == null) return;

    final targetScreen = message.data['screen'];
    final bookingDataRaw = message.data['booking_data'];

    if (targetScreen == 'review_page' && bookingDataRaw != null) {
      try {
        final Map<String, dynamic> bookingMap = jsonDecode(bookingDataRaw);
        navigatorKey.currentState?.pushNamed(
          '/review-page',
          arguments: bookingMap,
        );
      } catch (e) {
        print("Error parsing active state notification booking data: $e");
      }
    }
  }

  Future<String?> getFcmToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/sona_logo');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final data = jsonDecode(response.payload ?? '{}');

        final message = RemoteMessage(
          notification: RemoteNotification(
            title: data['title'],
            body: data['body'],
          ),
          data: Map<String, dynamic>.from(data['data'] ?? {}),
        );

        handleMessage(message);
      }
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    
    
    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;

      if(notification == null) return;

      await _localNotifications.show(
        id: message.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/sona_logo',
          ),
        ),
        payload: jsonEncode({
          "title": notification.title,
          "body": notification.body,
          "data": message.data,
        }),
      );
    });
  }

  Future<void> sendTokenToBackend(String fcmToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/save-fcm-token');

    final prefs = await SharedPreferences.getInstance();
    final String? loginToken = prefs.getString('token');

    if (loginToken == null) {
      print("DEBUG: User belum login, token FCM tidak disetor ke DB.");
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(token: loginToken),
        body: jsonEncode({
          'fcm_token': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        print('DEBUG: Token FCM berhasil disimpan ke database backend!');
      } else {
        print('DEBUG GAGAL: Backend merespon dengan status ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG ERROR: Gagal mengirim token ke backend -> $e');
    }
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
    if (fCMToken != null) {
      await sendTokenToBackend(fCMToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      sendTokenToBackend(newToken);
    });
    await initPushNotifications();
    await initLocalNotifications();
  }
}