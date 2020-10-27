import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lotto/Screens/main.dart';
import 'package:timezone/timezone.dart';
import 'package:lotto/const.dart';

FirebaseApp firebaseApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid) {
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
      )
    );
  }

  var androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
  var iosSetting = IOSInitializationSettings();
  var initializeSettings = InitializationSettings(android: androidSetting, iOS: iosSetting);

  var localNotiPlugin = FlutterLocalNotificationsPlugin();
  localNotiPlugin.initialize(initializeSettings); 

  var androidNoti = AndroidNotificationDetails(
    '주간 알림', '인생로또 주간 알림', '매주 토요일 로또 알림을 보냅니다.'
  );
  var platformNoti = NotificationDetails(android: androidNoti);

  localNotiPlugin.showWeeklyAtDayAndTime(
    1, 
    '아직 로또 구매 안하셨나요?', 
    '오늘은 토요일, 8시 45분에 로또 추첨이 진행됩니다. 오늘도 대박을 노려봅시다. 모두 화이팅!', 
    Day.saturday, 
    Time(12, 0, 0),
    platformNoti
  );

  localNotiPlugin.showWeeklyAtDayAndTime(
    1, 
    '로또가 추첨되었습니다. 결과를 확인해보세요.', 
    '행운의 주인공이 될 수 있으면 좋겠습니다.', 
    Day.saturday, 
    Time(20, 50, 0),
    platformNoti
  );

  var utc = DateTime(2020, 10, 19, 17, 12, 0).toUtc();
  print(utc);
  localNotiPlugin.showWeeklyAtDayAndTime(
    1, 
    '로또가 추첨되었습니다. 결과를 확인해보세요.', 
    '행운의 주인공이 될 수 있기를 바랍니다.', 
    Day.monday, 
    Time(utc.hour, utc.minute, utc.second),
    platformNoti
  );

  localNotiPlugin.show(
    1, 
    '로또가 추첨되었습니다. 결과를 확인해보세요.', 
    '행운의 주인공이 될 수 있기를 바랍니다.', 
    platformNoti
  );

  print(1);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '인생 로또 - 로또 추첨기, 당첨 확인',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}