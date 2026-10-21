import 'dart:async';
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:njangi/Controllers_distant/UserController.dart';
import 'package:njangi/utils/management/storage_manager.dart';

class FirebaseApi {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> Function(Map<String, dynamic>)? _notificationTapHandler;
  static Map<String, dynamic>? _pendingNotificationTap;
  static bool _listenersRegistered = false;

  // static Future<void> initializeFCM() async {
  //   // Permission (iOS & Android 13+)
  //   await _firebaseMessaging.requestPermission();

  //   // Init flutter_local_notifications
  //   const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  //   const settings = InitializationSettings(android: android);
  //   await _localNotificationsPlugin.initialize(settings);

  //   // Récupérer le token
  //   final token = await _firebaseMessaging.getToken();
  //   print('🔥 FCM Token: $token');

  //   // PREMIER PLAN
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('📩 [Foreground] Message: ${message.notification?.title}');
  //     _showNotification(message);
  //   });

  //   // ARRIÈRE-PLAN (quand on clique)
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     print('🟢 [Opened App] Message: ${message.notification?.title}');
  //   });
  // }

  static Future<void> initializeFCM() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Permissions
    await _firebaseMessaging.requestPermission();

    // Création du canal de notification Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channel_id', // id
      'channel_name', // nom visible à l'utilisateur
      description: 'Channel description',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Initialisation flutter_local_notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse:
          (response) => _queueLocalNotificationTap(response.payload),
    );
    final launchDetails =
        await _localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _queueLocalNotificationTap(launchDetails?.notificationResponse?.payload);
    }
    final token = await _firebaseMessaging.getToken();
    if (token != null && token.isNotEmpty) {
      await StorageManager.saveTokenFireBase(token);
    }

    _firebaseMessaging.onTokenRefresh.listen(_saveAndSyncToken);
    // final userData = await StorageManager.loadUserData();
    // final user = userData?['user'] as User?;

    // if (user != null) {
    //   int id = user.id;

    //   await AuthController().updateUser(userId: id, tokenFirebase: token);
    //   print('ID Utilisateur : $id');
    // } else {
    //   // Gérer le cas où l'utilisateur n'est pas connecté ou les données sont manquantes
    //   print(
    //       '❌ Erreur: Utilisateur non trouvé. Impossible de récupérer le token FCM.');
    //   // Vous pouvez également ajouter un retour (return) ici pour stopper l'exécution
    // }
    // int id = user!.id;

    // final token = await _firebaseMessaging.getToken();
    // await AuthController().updateUser(userId: id);
    // print('🔥 FCM Token: $token   ID: $id');

    if (!_listenersRegistered) {
      _listenersRegistered = true;
      FirebaseMessaging.onMessage.listen(_showNotification);
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        unawaited(_dispatchNotificationTap(message.data));
      });
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _pendingNotificationTap = Map<String, dynamic>.from(
          initialMessage.data,
        );
      }
    }
  }

  static void setNotificationTapHandler(
    Future<void> Function(Map<String, dynamic>)? handler,
  ) {
    _notificationTapHandler = handler;
    final pending = _pendingNotificationTap;
    if (handler == null || pending == null) return;
    _pendingNotificationTap = null;
    unawaited(handler(pending));
  }

  static Future<void> _dispatchNotificationTap(
    Map<String, dynamic> data,
  ) async {
    final handler = _notificationTapHandler;
    if (handler == null) {
      _pendingNotificationTap = Map<String, dynamic>.from(data);
      return;
    }
    await handler(Map<String, dynamic>.from(data));
  }

  static void _queueLocalNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        unawaited(_dispatchNotificationTap(Map<String, dynamic>.from(decoded)));
      }
    } on FormatException catch (error) {
      log('Payload de notification locale invalide: $error');
    }
  }

  static Future<void> syncTokenOnHomeEntry() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null || token.isEmpty) {
        log('Aucun token FCM disponible à l’ouverture de l’accueil.');
        return;
      }
      await _saveAndSyncToken(token);
    } catch (error) {
      log(
        'Impossible de récupérer le token FCM à l’ouverture de l’accueil: $error',
      );
    }
  }

  static Future<void> _saveAndSyncToken(String token) async {
    if (token.isEmpty) return;
    await StorageManager.saveTokenFireBase(token);
    await _syncTokenWithUser(token);
  }

  static Future<void> _syncTokenWithUser(String token) async {
    try {
      final user = await StorageManager.getUser();
      if (user == null) {
        log('Utilisateur non connecté; synchronisation FCM reportée.');
        return;
      }

      final result = await UserController.updateFirebaseToken(
        userId: user.id,
        firebaseToken: token,
      );
      if (result['success'] != true) {
        log(
          'Échec de la synchronisation du token FCM: '
          '${result['message'] ?? 'réponse serveur en échec'}',
        );
      }
    } catch (error) {
      log('Échec de la synchronisation du token FCM: $error');
    }
  }

  // Application tuée => isolé
  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    print('🔵 [Background] Message: ${message.notification?.title}');
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notifDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'Titre',
      message.notification?.body ?? 'Contenu',
      notifDetails,
      payload: jsonEncode(message.data),
    );
  }

  Future<AccessCredentials> _getAccessToken() async {
    final serviceAccountPath = dotenv.env['PATH_TO_SECRET'];

    String serviceAccountJson = await rootBundle.loadString(
      serviceAccountPath!,
    );

    // log("json: $serviceAccountJson");
    final serviceAccount = ServiceAccountCredentials.fromJson(
      serviceAccountJson,
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(serviceAccount, scopes);
    return client.credentials;
  }

  Future<bool> sendPushNotification({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (deviceToken.isEmpty) return false;

    final credentials = await _getAccessToken();
    final accessToken = credentials.accessToken.data;
    final projectId = dotenv.env['PROJECT_ID'];

    log("accessToken: $dotenv.env['PROJECT_ID']");

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    final message = {
      'message': {
        'token': deviceToken,
        'notification': {'title': title, 'body': body},
        'data': data ?? {},
      },
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully.');
      return true;
    } else {
      print('Failed to send notification: ${response.body}');
      return false;
    }
  }
}

// Nécessaire pour recevoir des messages en arrière-plan ou si l'app est fermée
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('💤 [Background Handler] ${message.notification?.title}');
}
