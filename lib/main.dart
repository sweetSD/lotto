import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lotto/screens/splash.dart';
import 'package:lotto/utility/notification.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:lotto/const.dart';

FirebaseApp? firebaseApp;
FirebaseMessaging messaging = FirebaseMessaging.instance;
AppOpenAd? _appOpenAd;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();

  await AppOpenAd.load(
    adUnitId: admobAppStartID,
    orientation: AppOpenAd.orientationPortrait,
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        _appOpenAd = ad;
        _appOpenAd?.show();
      },
      onAdFailedToLoad: (error) {
        debugPrint('AppOpenAd failed to load: $error');
        // Handle the error.
      },
    ),
  );

  if (Platform.isAndroid) {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    var build = await deviceInfoPlugin.androidInfo;
    firebaseApp = await Firebase.initializeApp(
      //name: 'life-lotto-db',
      options: FirebaseOptions(
        appId: firebaseAndroidAppID,
        apiKey: firebaseApiKey,
        messagingSenderId: build.androidId,
        projectId: firebaseProjectID,
        databaseURL: firebaseDatabaseURL,
      ),
    );
  } else {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    var build = await deviceInfoPlugin.iosInfo;
    firebaseApp = await Firebase.initializeApp(
        name: 'life-lotto-db',
        options: FirebaseOptions(
          appId: '1:297855924061:ios:c6de2b69b03a5be8',
          apiKey: firebaseApiKey,
          projectId: firebaseProjectID,
          messagingSenderId: build.identifierForVendor,
          databaseURL: firebaseDatabaseURL,
        ));
  }

  tz.initializeTimeZones();
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(initializeSettings);
  scheduleWeeklyNotification();

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  debugPrint('User granted permission: ${settings.authorizationStatus}');

  messaging.getToken().then((token) {
    debugPrint('fcm token : ${token!}');
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '100% 로또 ~ 행운 번호, 당첨 확인, 당첨 통계',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: SplashScreen(),
    );
  }
}
