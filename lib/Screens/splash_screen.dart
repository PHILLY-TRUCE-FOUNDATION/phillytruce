import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:background_location/background_location.dart';
import 'package:callkeep/callkeep.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/call_api.dart';
import 'package:flutter_app/Screens/MediatorScreens/mediator_profile_login.dart';
import 'package:flutter_app/Screens/MediatorScreens/user_informaiton_Screen.dart';
import 'package:flutter_app/Screens/UsersScreens/final_message_screen.dart';
import 'package:flutter_app/Screens/home_screen.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/firebase.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'Calling/calling_screen.dart';

class SplashScreen extends StatefulWidget {
  static final FlutterCallkeep callKeep = FlutterCallkeep();

  // static bool isCall;

  @override
  _SplashScreenState createState() => _SplashScreenState(callKeep);
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  _SplashScreenState(this.callKeep);

  final FlutterCallkeep callKeep;
  Map<String, dynamic> message;

  String value;

  // final bool isCall;

  Map<String, Call> calls = {};
  AppLifecycleState notificationState = AppLifecycleState.resumed;

  String status;
  Map<String, dynamic> mediatorData = new Map<String, dynamic>();
  SharedPreferences notificationDataStore;

  Data model;

  // static BuildContext con;
  static var scaffoldKey = new GlobalKey<ScaffoldState>();
  Map<String, dynamic> map;

  // bool isAnswered;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    getUserStatus();


    if (Platform.isAndroid) getPermission();

    print(' Philly Truce Launch ++');
    if (Platform.isAndroid) {
      callKeep.on(CallKeepPerformAnswerCallAction(), answerCall);
      callKeep.on(CallKeepDidPerformDTMFAction(), didPerformDTMFAction);
      callKeep.on(
          CallKeepDidReceiveStartCallAction(), didReceiveStartCallAction);
      callKeep.on(CallKeepDidToggleHoldAction(), didToggleHoldCallAction);
      callKeep.on(
          CallKeepDidPerformSetMutedCallAction(), didPerformSetMutedCallAction);
      callKeep.on(CallKeepPerformEndCallAction(), endCall);
      // callKeep.on(CallKeepPushKitToken(), onPushKitToken);
      callKeep.on(CallKeepDidDisplayIncomingCall(), didDisplayIncomingCall);
      callKeep.setup(<String, dynamic>{
        'ios': {
          'appName': 'Philly Truce',
        },
        'android': {
          'alertTitle': 'Permissions required',
          'alertDescription':
              'This application needs to access your phone accounts',
          'cancelButton': 'Cancel',
          'okButton': 'ok',
        },
      }).catchError((onError) {
        print('Error on Initilization Callkeep' + onError.toString());
      });
    } else {
      // PushNotificationsManager.flutterLocalNotificationsPlugin
      //     .getNotificationAppLaunchDetails()
      //     .then((NotificationAppLaunchDetails value) {
      //       if(value.didNotificationLaunchApp){
      //
      //       }else{
      startTimer();
      //       }
      // });
    }

    super.initState();
  }

  getPermission() async {
    // if (!callKeep.hasPhoneAccount())

    final bool hasPhoneAccount = await callKeep.hasPhoneAccount();
    if (!hasPhoneAccount)
      callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
        'ios': {
          'appName': 'Philly Truce',
        },
        'android': {
          'alertTitle': 'Permissions required',
          'alertDescription':
              'This application needs to access your phone accounts',
          'cancelButton': 'Cancel',
          'okButton': 'ok',
        },
      }).whenComplete(() {
        PushNotificationsManager.flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails()
            .then((NotificationAppLaunchDetails value) {
          if (!value.didNotificationLaunchApp) {
            startTimer();
          }
        });
      });
    else {
      PushNotificationsManager.flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails()
          .then((NotificationAppLaunchDetails value) {
        if (!value.didNotificationLaunchApp) {
          startTimer();
        }
      });
    }
  }

  void onPushKitToken(CallKeepPushKitToken event) {
    print('[onPushKitToken] token => ${event.token}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // getIt<AppModel>().removeListener(update);
    super.dispose();
  }

  void update() => setState(() => {});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        print('App paused');
        break;
      case AppLifecycleState.detached:
        print('App Killed');
        // Fluttertoast.showToast(msg: 'Killed');
        break;
      case AppLifecycleState.resumed:
        print('App resume');

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: whiteColor,
        appBar: AppBar(
          elevation: 0.0,
          toolbarOpacity: 0.0,
          toolbarHeight: 0.0,
          backgroundColor: whiteColor,
        ),
        body: splashScreen());
  }

  Future<void> startTimer() async {
    // await PushNotificationsManager().init(context);
    Timer(Duration(seconds: 3), () {
      navigateToOtherScreen(); //It will redirect  after 3 seconds
    });
  }

  Future<void> displayIncomingCall(String number, message) async {
    print('Display incoming call now');
    String callUUID = Uuid().v4();

    final bool hasPhoneAccount = await callKeep.hasPhoneAccount();
    if (!hasPhoneAccount) {
      await callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      });
    }
    print('Display incoming call now' + notificationState.toString());

    if (notificationState == AppLifecycleState.resumed) {
      print('[displayIncomingCall] paused inactive backToForeground');
      callKeep.backToForeground().then((value) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CallingScreen(
                isIncomingCall: true,
                role: ClientRole.Audience,
                channelName: '123',
              ),
            ));
      });
    }

    callKeep.displayIncomingCall('12', '123');
    PushNotificationsManager.navigatorKey.currentState.push(MaterialPageRoute(
      builder: (context) => CallingScreen(
        isIncomingCall: false,
        role: ClientRole.Audience,
        channelName: '123',
      ),
    ));
    print('[displayIncomingCall] $callUUID number: $number');
    print('[displayIncomingCall] ' + message.toString());
  }

  navigateToOtherScreen() {
    print('Flutter Philly status' + status.toString());

    // Once complete, show your application
    if (status == 'UserPending')
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FinalMessageScreen(),
        ),
      );
    else if (status == 'MediatorPending') {
      print('Flutter Philly' + mediatorData['helpId'].toString());
      return Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserInformation(
                  mediatorData['isBackUpMediator'] == false
                      ? 'help_request'
                      : 'help_backup_request',
                  mediatorData['helpId'],
                  mediatorData['userId'],
                  0,
                  false)));
    } else if (status == 'BackUpMediatorPending') {
      print('Flutter Philly' + mediatorData['helpId'].toString());
      return Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserInformation(
                  mediatorData['isBackUpMediator'] == false
                      ? 'help_request'
                      : 'help_backup_request',
                  mediatorData['helpId'],
                  mediatorData['userId'],
                  0,
                  false)));
    } else if (model != null) {
      if (model.user_type == 'mediator')
        return Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MediatorRegistrationScreen(true, true),
            ));
      else {
        return Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      }
    } else
      return Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
    // Otherwise, show something whilst waiting for initialization to complete
  }

  Widget splashScreen() {
    return Container(
      height: ResponsiveFlutter.of(context).hp(100),
      decoration: homeBackgroundBoxDecoration,
      child: Image.asset('assets/images/shake_hand_logo.png'),
    );
  }

  getUserStatus() async {

    model = await SaveDataLocal.getUserDataFromLocal();
    status = await SaveDataLocal.getUserStatus();
    if (status == 'MediatorPending')
      mediatorData = await SaveDataLocal.getRespondedMediatorType();
    if (status == 'BackUpMediatorPending')
      mediatorData = await SaveDataLocal.getRespondedMediatorType();
  }

  navigateCallingscreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CallingScreen(
                  isIncomingCall: true,
                  role: ClientRole.Broadcaster,
                  channelName: '123',
                )));
  }

  Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
    print('Get Notificaiton Data in Splash Screen');

    // setState(() {
    MyApp.isAnswered = true;
    // });

    callKeep.backToForeground().then((value) {
      PushNotificationsManager.navigatorKey.currentState.push(MaterialPageRoute(
        builder: (context) => CallingScreen(
          role: ClientRole.Audience,
          isIncomingCall: true,
          channelName: '12',
          peerName: '123',
          peerId: '12',
        ),
      ));
    }).whenComplete(() {
      callKeep.endAllCalls();
    });

    print('fwef' + notificationState.toString());
  }

  void removeCall(String callUUID) {
    // setState(() {
    calls.remove(callUUID);
    // });
  }

  Future<void> endCall(CallKeepPerformEndCallAction event) async {
    print('End Call');
    removeCall(event.callUUID);

    // print('api call');
    // print('api call' + peerId.toString());
    // print('api call' + widget.peerId.toString());
    // print('api call' + channelName.toString());
    // print('api call' + callStatus.toString());

    if (!MyApp.isAnswered) {
      String text;
      try {
        final Directory directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/my_file.txt');
        text = await file.readAsString();
        print('IOS File Testing' + text.toString());
        if (Platform.isAndroid)
          endCallAPI(json.decode(text)['data']['room_name'].toString(),
              json.decode(text)['data']['sender_id'].toString());
        // await onJoin(json.decode(text)['data'][
        // 'room_name'].toString());
        if (Platform.isIOS)
          endCallAPI(json.decode(text)['room_name'].toString(),
              json.decode(text)['sender_id'].toString());

        // setState(() {
        //   if (Platform.isAndroid)
        //     peerName =
        //         json.decode(text)['data']['incoming_caller_name'].toString();
        //   if (Platform.isIOS)
        //     peerName = json.decode(text)['incoming_caller_name'].toString();
        // });
      } catch (e) {
        print("Couldn't read file" + e.toString());
      }
    }

    MyApp.isAnswered = false;
  }

  endCallAPI(channelName, peerId) {
    final String callUUId = Uuid().v4().toString();

    final Map<String, String> data = new Map<String, String>();
    data['callUUID'] = callUUId;
    data['room_name'] = channelName.toString();
    data['receiver_id'] = peerId.toString();
    data['callstatus'] = 'endCall';

    CallApiClient().callUser(data, context).then((value) {
      print('miefwopf' + value.body.toString());
      print('miefwopf' + data.toString());
    });
  }

  Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
    print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
  }

  Future<void> didReceiveStartCallAction(
      CallKeepDidReceiveStartCallAction event) async {
    if (event.handle == null) {
      // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
      return;
    }
    String callUUID = Uuid().v4();
    callKeep.startCall(callUUID, event.handle, event.handle);

    Timer(const Duration(seconds: 1), () {
      print('[setCurrentCallActive] $callUUID, number: ${event.handle}');
      callKeep.setCurrentCallActive(callUUID);
    });
  }

  Future<void> didPerformSetMutedCallAction(
      CallKeepDidPerformSetMutedCallAction event) async {
    print('[setCurrentCallActive]1 $CallKeepDidPerformSetMutedCallAction');

    // final String number = calls[event.callUUID].number;
    // print(
    //     '[didPerformSetMutedCallAction] ${event.callUUID}, number: $number (${event.muted})');
    //
    // setCallMuted(event.callUUID, event.muted);
  }

  Future<void> didToggleHoldCallAction(
      CallKeepDidToggleHoldAction event) async {
    // final String number = calls[event.callUUID].number;
    // print(
    //     '[didToggleHoldCallAction] ${event.callUUID}, number: $number (${event.hold})');
    //
    // setCallHeld(event.callUUID, event.hold);
  }

  Future<void> hangup(String callUUID) async {
    callKeep // removeCall(callUUID);
        .endCall(callUUID);
    // removeCall(callUUID);
  }

  Future<void> setOnHold(String callUUID, bool held) async {
    callKeep // removeCall(callUUID);
        .setOnHold(callUUID, held);
    // final String handle = calls[callUUID].number;
    // print('[setOnHold: $held] $callUUID, number: $handle');
    // setCallHeld(callUUID, held);
  }

  Future<void> setMutedCall(String callUUID, bool muted) async {
    callKeep.setMutedCall(callUUID, muted);
    // final String handle = calls[callUUID].number;
    // print('[setMutedCall: $muted] $callUUID, number: $handle');
    // setCallMuted(callUUID, muted);
  }

  Future<void> updateDisplay(String callUUID) async {}

  Future<void> didDisplayIncomingCall(
      CallKeepDidDisplayIncomingCall event) async {}
}
