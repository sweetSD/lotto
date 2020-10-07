import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lotto/Screens/main.dart';
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