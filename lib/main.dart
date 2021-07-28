import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Services/voip_push.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'Screens/splash_screen.dart';
import 'Services/agora.dart';
import 'Services/firebase.dart';
import 'Widget/progrssIndicator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (Platform.isIOS) await VoIPPushManager().init();
  await AgoraCallingManager().init();
  // await CallKeep.setup();
  await PushNotificationsManager().init();
  Utils.configLoading();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static  bool isCallingScreen = false;
  static  bool isAnswered = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: PushNotificationsManager.navigatorKey,
        builder: EasyLoading.init(),
        home: SplashScreen());
  }

}
