import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:callkeep/callkeep.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/Main/Bloc/Mediator/get_backup_mediator.dart';
import 'package:flutter_app/Main/Bloc/Mediator/get_locations.dart';
import 'package:flutter_app/Main/Bloc/user/get_mediator_status.dart';
import 'package:flutter_app/Main/Bloc/user/get_user_bloc.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Screens/Calling/calling_screen.dart';
import 'package:flutter_app/Screens/MediatorScreens/user_informaiton_Screen.dart';
import 'package:flutter_app/Screens/chat_screen.dart';
import 'package:flutter_app/Services/voip_push.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

import '../Screens/splash_screen.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  static final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  bool _initialized = false;
  BuildContext context;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  Data data;
  static GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");

  static bool notificationReceived = false;

  Future<void> init() async {
    if (!_initialized) {
      // await CallKeep.askForPermissionsIfNeeded(context);

      // callKeep.on(CallKeepDidDisplayIncomingCall(), didDisplayIncomingCall);

      // For iOS request permission first.
      firebaseMessaging.requestNotificationPermissions();
      firebaseMessaging.configure();

      _initialized = true;
      firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
      firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
      this.pushToken.then((value) {
        print("Firebase Notification Initialized" + '/' + value);
      });

      print("Firebase Notification Initialized");
      var pendingNotificationRequests =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      var initializationSettingsAndroid =
          new AndroidInitializationSettings('@mipmap/notification_ic');

      var initializationSettingsIOS = new IOSInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: false,
          requestSoundPermission: true,
          defaultPresentAlert: true,
          defaultPresentSound: true,
          onDidReceiveLocalNotification: onDidRecieveLocalNotification);

      var initializationSettings = new InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);

      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: onSelectNotification);

      firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          // Fluttertoast.showToast(msg: 'message');

          // print('on message' + message['data']['notification_type'].toString());

          // await displayIncomingCall(message);
          if (Platform.isAndroid) {
            if ('mediator_assign' ==
                message['data']['notification_type'].toString()) {
              updateMediatorStatusData();
            } else if ('help_status' == message['data']['notification_type']) {
              data = await SaveDataLocal.getUserDataFromLocal();
              if (data.user_type == 'user')
                updateMediatorStatusData();
              else {
                int helpId = int.parse(message['data']['help_id'].toString());
                updateUserHelpInformation(helpId);
              }
            } else if ('new_backup_mediator' ==
                message['data']['notification_type']) {
              int helpId = int.parse(message['data']['help_id'].toString());
              getMediatorList(helpId);
            } else if ('mediator_cancel' ==
                message['data']['notification_type']) {
              updateMediatorStatusData();
            } else if ('location_update' ==
                message['data']['notification_type']) {
              int helpId = int.parse(message['data']['help_id'].toString());
              locationUpdate(helpId);
            } else if (message['data']['notification_type'] == 'help_request') {
              displayNotification(message);
              // _handleNotification(message);
            } else if (message['data']['notification_type'] ==
                'help_backup_request') {
              displayNotification(message);
              // _handleNotification(message);
            } else if (message['data']['notification_type'] ==
                'chat_notification') {
              displayNotification(message);
              // _handleNotification(message);
            } else if ('phone_call' ==
                message['data']['notification_type'].toString()) {
              print('mipewf' + message['data']['notification_type'].toString());
              print('mipewf' + message['data']['room_name'].toString());
              String Uuid = UuidUtil.cryptoRNG().toString();

              // getIt<AppModel>().incrementCounter(message);
              if (message['data']['callstatus'] == 'connecting') {
                _write(json.encode(message));

                // FlutterCallkeep().displayIncomingCall('12', '12');
                print('mipewf inside conition');
                await SplashScreen.callKeep
                    .displayIncomingCall(
                        message['data']['incoming_caller_name'],
                        message['data']['incoming_caller_name'],
                        localizedCallerName: 'Philly Truce',
                        hasVideo: true,
                        handleType: 'generic')
                    .catchError((onError) {
                  print('mipewf insincoming_caller_idide conition' +
                      onError.toString());
                });
              } else {
                print('mipewf insincoming_caller_idide conition');

                SplashScreen.callKeep.endAllCalls();
                if (MyApp.isCallingScreen == true)
                  navigatorKey.currentState.pop();
                /* }*/
                // SplashScreen.callKeep.endAllCalls();
                // navigatorKey.currentState.pop();
              }
            } else {
              displayNotification(message);
            }
          } else if (Platform.isIOS) {
            print('on message 11  ${message['notification_type'].toString()}');
            if ('mediator_assign' == message['notification_type'].toString()) {
              updateMediatorStatusData();
            } else if ('help_status' == message['notification_type']) {
              if (data.user_type == 'user')
                updateMediatorStatusData();
              else {
                int helpId = int.parse(message['help_id'].toString());
                updateUserHelpInformation(helpId);
              }
            } else if ('new_backup_mediator' == message['notification_type']) {
              int helpId = int.parse(message['help_id'].toString());

              getMediatorList(helpId);
            } else if ('location_update' == message['notification_type']) {
              int helpId = int.parse(message['help_id'].toString());

              locationUpdate(helpId);
            } else if ('mediator_cancel' == message['notification_type']) {
              updateMediatorStatusData();
            } else if ('help_request' == message['notification_type']) {
              displayNotification(message);
              // _handleNotification(message);
            } else if ('help_backup_request' == message['notification_type']) {
              displayNotification(message);
              // _handleNotification(message);
            } else if ('phone_call' == message['notification_type']) {
              // navigatorKey.currentState.push(
              //     MaterialPageRoute(builder: (context) =>
              //         CallingScreen(
              //             channelName: message['room_name'],
              //             isIncomingCall: true,
              //             role: ClientRole.Audience),));
              if (message['callstatus'] == 'endCall') {
                VoIPPushManager.iosVoIPKit.endCall();

                if (MyApp.isCallingScreen == true)
                  navigatorKey.currentState.pop();
              }
            } else if ('chat_notification' == message['notification_type']) {
              displayNotification(message);
            } else {
              var androidPlatformChannelSpecifics;

              androidPlatformChannelSpecifics = new AndroidNotificationDetails(
                  '0', 'fcm', 'FirebasePush',
                  icon: '@mipmap/notification_ic',
                  color: Colors.transparent,
                  importance: Importance.max,
                  enableLights: true,
                  playSound: true,
                  channelAction:
                      AndroidNotificationChannelAction.createIfNotExists,
                  autoCancel: true,
                  priority: Priority.high);

              var iOSPlatformChannelSpecifics = new IOSNotificationDetails(
                  presentSound: true, presentAlert: true);
              var platformChannelSpecifics = new NotificationDetails(
                  android: androidPlatformChannelSpecifics,
                  iOS: iOSPlatformChannelSpecifics);

              flutterLocalNotificationsPlugin.show(
                0,
                Platform.isAndroid
                    ? message['data']['message']
                    : message['message'],
                Platform.isAndroid
                    ? message['data']['message']
                    : message['message'],
                platformChannelSpecifics,
                payload: json.encode(message),
              );
              // _handleNotification(message);
            }
          }
        },
        onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
          await flutterLocalNotificationsPlugin.cancelAll();
          // Fluttertoast.showToast(msg: 'resume');
          if (Platform.isAndroid) {
            if (message['data']['notification_type'] == 'chat_notification') {
              navigatorKey.currentState
                  .push(MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          message['data']['sender_id'] != null
                              ? int.parse(message['data']['sender_id'])
                              : 0,
                          message['data']['help_id'] != null
                              ? int.parse(message['data']['help_id'])
                              : 0,
                          message['data']['receiver_id'] != null
                              ? int.parse(message['data']['receiver_id'])
                              : 0,
                          false,
                          false,
                          false)))
                  .whenComplete(() {
                pendingNotificationRequests.clear();
              });
            } else if (message['data']['notification_type'] != 'phone_call' &&
                message['data']['notification_type'] != 'chat_notification') {
              navigatorKey.currentState
                  .push(MaterialPageRoute(
                builder: (_) => UserInformation(
                    json.decode(json.encode(message))['data']['notification_type'] !=
                            null
                        ? json.decode(json.encode(message))['data']
                            ['notification_type']
                        : 'help_request',
                    json.decode(json.encode(message))['data']['help_id'] != null
                        ? int.parse(json
                            .decode(json.encode(message))['data']['help_id']
                            .toString())
                        : 0,
                    json.decode(json.encode(message))['data']['user_id'] != null
                        ? int.parse(json
                            .decode(json.encode(message))['data']['user_id']
                            .toString())
                        : 0,
                    json.decode(json.encode(message))['data']
                                ['request_backup_id'] !=
                            null
                        ? int.parse(json.decode(json.encode(message))['data']['request_backup_id'].toString())
                        : 0,
                    true),
              ))
                  .whenComplete(() {
                pendingNotificationRequests.clear();
              });
            } else {
              navigatorKey.currentState
                  .push(MaterialPageRoute(
                builder: (context) => CallingScreen(
                    channelName: message['data']['room_name'],
                    isIncomingCall: true,
                    role: ClientRole.Audience),
              ))
                  .whenComplete(() {
                pendingNotificationRequests.clear();
              });
            }
          }
          if (Platform.isIOS) {
            if (message['notification_type'] == 'chat_notification') {
              navigatorKey.currentState
                  .push(MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          message['sender_id'] != null
                              ? int.parse(message['sender_id'])
                              : 0,
                          message['help_id'] != null
                              ? int.parse(message['help_id'])
                              : 0,
                          message['receiver_id'] != null
                              ? int.parse(message['receiver_id'])
                              : 0,
                          false,
                          false,
                          false)))
                  .whenComplete(() {
                pendingNotificationRequests.clear();
              });
            } else if (message['notification_type'] != 'phone_call' &&
                message['notification_type'] != 'chat_notification')
              navigatorKey.currentState
                  .push(MaterialPageRoute(
                builder: (context) => UserInformation(
                    json.decode(json.encode(message))['notification_type'] !=
                            null
                        ? json.decode(json.encode(message))['notification_type']
                        : 'help_request',
                    json.decode(json.encode(message))['help_id'] != null
                        ? int.parse(
                            json.decode(json.encode(message))['help_id'])
                        : 0,
                    json.decode(json.encode(message))['user_id'] != null
                        ? int.parse(
                            json.decode(json.encode(message))['user_id'])
                        : 0,
                    json.decode(json.encode(message))['request_backup_id'] !=
                            null
                        ? int.parse(json
                            .decode(json.encode(message))['request_backup_id'])
                        : 0,
                    true),
              ))
                  .whenComplete(() {
                pendingNotificationRequests.clear();
              });
          }
          return;
        },
        onLaunch: (message) async {
          // Fluttertoast.showToast(msg: 'launch');
          print('on launch $message');
          print(' Philly Truce Launch1');

          // var pendingNotificationRequests =
          //     await flutterLocalNotificationsPlugin
          //         .pendingNotificationRequests();
          if (Platform.isAndroid) {
            if (message['data']['notification_type'] == 'chat_notification') {
              await Future.delayed(Duration(seconds: 4), () {
                print('Time Testing');
                Navigator.push(
                    navigatorKey.currentContext,
                    MaterialPageRoute(
                        builder: (_) => ChatScreen(
                            message['data']['sender_id'] != null
                                ? int.parse(message['data']['sender_id'])
                                : 0,
                            message['data']['help_id'] != null
                                ? int.parse(message['data']['help_id'])
                                : 0,
                            message['data']['receiver_id'] != null
                                ? int.parse(message['data']['receiver_id'])
                                : 0,
                            true,
                            false,
                            false))).whenComplete(() {
                  pendingNotificationRequests.clear();
                });
              });
            } else if (message['data']['notification_type'] != 'phone_call' &&
                message['data']['notification_type'] != 'chat_notification') {
              await Future.delayed(Duration(seconds: 4), () {
                Navigator.push(
                    navigatorKey.currentContext,
                    MaterialPageRoute(
                      builder: (_) => UserInformation(
                          message['data']['notification_type'] != null
                              ? message['data']['notification_type']
                              : 'help_request',
                          message['data']['help_id'] != null
                              ? message['data']['help_id'].toString()
                              : 0,
                          message['data']['user_id'] != null
                              ? int.parse(message['data']['user_id'].toString())
                              : 0,
                          message['data']['request_backup_id'] != null
                              ? message['data']['request_backup_id'].toString()
                              : 0,
                          true),
                    )).whenComplete(() {
                  pendingNotificationRequests.clear();
                });
              });
            }
            //else {
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => CallingScreen(
            //             channelName: message['data']['room_name'],
            //             isIncomingCall: true,
            //             role: ClientRole.Audience),
            //       )).whenComplete(() {
            //     pendingNotificationRequests.clear();
            //   });
            // }
          }
          if (Platform.isIOS) {
            // Fluttertoast.showToast(msg: 'From launch');
            if (message['notification_type'] == 'chat_notification') {
              // Fluttertoast.showToast(msg: 'From launch1' + message['notification_type'].toString());
              await Future.delayed(Duration(seconds: 4), () {
                Navigator.push(
                    navigatorKey.currentContext,
                    MaterialPageRoute(
                        builder: (_) => ChatScreen(
                            message['sender_id'] != null
                                ? int.parse(message['sender_id'].toString())
                                : 0,
                            message['help_id'] != null
                                ? int.parse(message['help_id'].toString())
                                : 0,
                            message['receiver_id'] != null
                                ? int.parse(message['receiver_id'].toString())
                                : 0,
                            false,
                            false,
                            false)));
              });
            } else if (message['notification_type'] != 'chat_notification') {
              await Future.delayed(Duration(seconds: 4), () {
                Navigator.push(
                    navigatorKey.currentContext,
                    MaterialPageRoute(
                      builder: (_) => UserInformation(
                          message['notification_type'] != null
                              ? message['notification_type']
                              : 'help_request',
                          message['help_id'] != null
                              ? int.parse(message['help_id'].toString())
                              : 0,
                          message['user_id'] != null
                              ? int.parse(message['user_id'].toString())
                              : 0,
                          message['request_backup_id'] != null
                              ? message['request_backup_id'].toString()
                              : 0,
                          true),
                    )).whenComplete(() {
                  pendingNotificationRequests.clear();
                });
              });
            }
          }
          return;
        },
        onBackgroundMessage:
            Platform.isIOS ? null : Fcm.myBackgroundMessageHandler,
      );
    }
  }

  _write(String text) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/my_file.txt');
      await file.writeAsString(text);
    } catch (e) {
      print('mop' + e.toString());
    }
  }

  Future onSelectNotification(message) async {
    print('message encode' + message.toString());
    print('message decode' + json.decode(message).toString());

    if (Platform.isAndroid) {
      if (json.decode(message)['data']['notification_type'] ==
          'chat_notification') {
        // await Future.delayed(Duration(seconds: 3), () {
        navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => ChatScreen(
              json.decode(message)['data']['sender_id'] != null
                  ? int.parse(
                      json.decode(message)['data']['sender_id'].toString())
                  : 0,
              json.decode(message)['data']['help_id'] != null
                  ? int.parse(
                      json.decode(message)['data']['help_id'].toString())
                  : 0,
              json.decode(message)['data']['receiver_id'] != null
                  ? int.parse(
                      json.decode(message)['data']['receiver_id'].toString())
                  : 0,
              false,
              false,
              false),
        ));
        // });
      } else {
        // await Future.delayed(Duration(seconds: 3), () {
        navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => UserInformation(
              json.decode(message)['data']['notification_type'] != null
                  ? json.decode(message)['data']['notification_type']
                  : 'help_request',
              json.decode(message)['data']['help_id'] != null
                  ? int.parse(
                      json.decode(message)['data']['help_id'].toString())
                  : 0,
              json.decode(message)['data']['user_id'] != null
                  ? int.parse(
                      json.decode(message)['data']['user_id'].toString())
                  : 0,
              json.decode(message)['data']['request_backup_id'] != null
                  ? int.parse(json
                      .decode(message)['data']['request_backup_id']
                      .toString())
                  : 0,
              true),
        ));
        // });
      }
    } else {
      if (json.decode(message)['notification_type'] == 'phone_call') {
        // navigatorKey.currentState.push(
        //     MaterialPageRoute(builder: (context) =>
        //         CallingScreen(
        //             channelName: '154', isIncomingCall: true,
        //             role: ClientRole.Audience),));
      } else if (json.decode(message)['notification_type'] ==
          'chat_notification') {
        // await Future.delayed(Duration(seconds: 3), () {
        navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => ChatScreen(
              json.decode(message)['sender_id'] != null
                  ? int.parse(json.decode(message)['sender_id'].toString())
                  : 0,
              json.decode(message)['help_id'] != null
                  ? int.parse(json.decode(message)['help_id'].toString())
                  : 0,
              json.decode(message)['receiver_id'] != null
                  ? int.parse(json.decode(message)['receiver_id'].toString())
                  : 0,
              false,
              false,
              false),
        ));
        // });
      } else
        // await Future.delayed(Duration(seconds: 3), () {
        navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => UserInformation(
              json.decode(message)['notification_type'] != null
                  ? json.decode(message)['notification_type']
                  : 'help_request',
              json.decode(message)['help_id'] != null
                  ? int.parse(json.decode(message)['help_id'].toString())
                  : 0,
              json.decode(message)['user_id'] != null
                  ? int.parse(json.decode(message)['user_id'].toString())
                  : 0,
              json.decode(message)['request_backup_id'] != null
                  ? int.parse(
                      json.decode(message)['request_backup_id'].toString())
                  : 0,
              true),
        ));
      // });
    }
  }

  static Future displayNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics;

    androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '0', 'fcm', 'FirebasePush',
        icon: '@mipmap/notification_ic',
        color: Colors.transparent,
        importance: Importance.max,
        enableLights: true,
        playSound: true,
        channelAction: AndroidNotificationChannelAction.createIfNotExists,
        autoCancel: true,
        priority: Priority.high);

    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(presentSound: true, presentAlert: true);
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
      0,
      'Philly Truce',
      Platform.isAndroid ? message['data']['message'] : message['body'],
      platformChannelSpecifics,
      payload: json.encode(message),
    );
  }

  Future onDidRecieveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              // On select iOS notification
            },
          ),
        ],
      ),
    );
  }

  void updateMediatorStatusData() {
    getMediatorStatusBloc.getMediatorStatus();
  }

  void getMediatorList(helpId) {
    getBackUpMediatorBloc.getMediatorList(helpId);
  }

  void updateUserHelpInformation(helpId) {
    getUserbloc.getUser(helpId);
    getMediatorStatusBloc.getMediatorStatus();
  }

  void locationUpdate(helpId) {
    getMediatorsLocationBloc.getMediatorLocationsDetails(helpId);
  }

  Future<String> pushToken = firebaseMessaging.getToken();
}

class Fcm {
  static Map<String, dynamic> message;

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    print('in background');

    print(message);
    // Fluttertoast.showToast(msg: 'background');
    print(message['data']['notification_type']);
    final FlutterCallkeep _callKeep = FlutterCallkeep();
    bool _callKeepInited = false;
    var pendingNotificationRequests = await PushNotificationsManager
        .flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    Fcm.message = message;
    if (Platform.isAndroid) {
      if (message['data']['notification_type'] == 'help_backup_request') {
        PushNotificationsManager.displayNotification(message);
        pendingNotificationRequests.clear();
        // _handleNotification(message);
      } else if ('mediator_cancel' == message['data']['notification_type']) {
      } else if (message['data']['notification_type'] == 'chat_notification') {
        // PushNotificationsManager.displayNotification(message);
        // _handleNotification(message);

        PushNotificationsManager.displayNotification(message);
        pendingNotificationRequests.clear();
      } else if ('phone_call' ==
          message['data']['notification_type'].toString()) {
        // displayNotification(message);
        // _handleNotification(message);
        print('in background' + 'Phone Call');
        print('mipewf' + message['data']['notification_type'].toString());
        print('mipewf' + message['data']['room_name'].toString());
        print('mipewf' + json.encode(message.toString()));

        if (!_callKeepInited) {
          _callKeep.setup(<String, dynamic>{
            'ios': {
              'appName': 'CallKeepDemo',
            },
            'android': {
              'alertTitle': 'Permissions required',
              'alertDescription':
                  'This application needs to access your phone accounts',
              'cancelButton': 'Cancel',
              'okButton': 'ok',
            },
          });
          _callKeepInited = true;
        }
        String uuid = Uuid().v4().toString();

        FlutterCallkeep().backToForeground().whenComplete(() async {
          if (message['data']['callstatus'] == 'connecting') {
            _write(json.encode(message));

            Future.delayed(Duration(seconds: 3), () {
              FlutterCallkeep().displayIncomingCall(
                  uuid, message['data']['incoming_caller_name'],
                  localizedCallerName: 'Philly Truce',
                  hasVideo: true,
                  handleType: 'generic');
            });
            pendingNotificationRequests.clear();

            // await SplashScreen.callKeep
            //     .displayIncomingCall(
            //     message['data']['incoming_caller_name'],
            //     message['data']['incoming_caller_name'],
            //     localizedCallerName: 'Philly Truce',
            //     hasVideo: true,
            //     handleType: 'generic');

            // print('Notification Data' +
            //     message['data']['notification_type'].toString());
            print(
                'Notification Data' + message['data']['room_name'].toString());
          } else {
            pendingNotificationRequests.clear();

            SplashScreen.callKeep.endAllCalls();
            if (MyApp.isCallingScreen == true)
              PushNotificationsManager.navigatorKey.currentState.pop();
          }
          // await SaveDataLocal.saveCallData(message);

          // print('nmionfoew' + SplashScreen.getIt<AppModel>().message.toString());
        });
      } else if ('mediator_assign' == message['notification_type'].toString()) {
        PushNotificationsManager.displayNotification(message);
        pendingNotificationRequests.clear();
      } else if ('help_status' == message['notification_type']) {
      } else if ('new_backup_mediator' == message['notification_type']) {
      } else if ('location_update' == message['notification_type']) {
      } else if ('help_request' == message['notification_type']) {
        // _handleNotification(message);
      } else {
        PushNotificationsManager.displayNotification(message);
      }

      return Future.value();
      // Or do other work.
    }
    if (Platform.isIOS) {
      print('mipewf' + message.toString());
      if ('help_request' == message['notification_type']) {
        PushNotificationsManager.displayNotification(message);

        // _handleNotification(message);
      } else if ('help_backup_request' == message['notification_type']) {
        PushNotificationsManager.displayNotification(message);

        // _handleNotification(message);
      } else if ('phone_call' == message['notification_type']) {
      } else if ('chat_notification' == message['notification_type']) {
        PushNotificationsManager.displayNotification(message);
      }
    }
  }

  static Future _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    await file.writeAsString(text);
  }
}
