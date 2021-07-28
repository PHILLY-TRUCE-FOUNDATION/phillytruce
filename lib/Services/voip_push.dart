import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Providers/call_api.dart';
import 'package:flutter_app/Screens/Calling/calling_screen.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_ios_voip_kit/flutter_ios_voip_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'agora.dart';
import 'firebase.dart';

class VoIPPushManager {
  VoIPPushManager._();

  factory VoIPPushManager() => _instance;

  static final VoIPPushManager _instance = VoIPPushManager._();

  static final FlutterIOSVoIPKit iosVoIPKit = FlutterIOSVoIPKit();

  bool _initialized = false;
  bool isTalking = false;
  Timer timeOutTimer;
  static Map<String, dynamic> staticPayload = new Map<String, dynamic>();

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _initialized = true;

      print('initi of VOIP');
      await iosVoIPKit.requestAuthLocalNotification();
      print('fewf');
      iosVoIPKit.onDidReceiveIncomingPush = (
        Map<String, dynamic> payload,
      ) async {
        staticPayload.addAll(payload);
        //
        // if (payload['callstatus'] == 'endCall') {
        //   iosVoIPKit.endCall();
        // } else {
        _write(json.encode(payload));

        //   _timeOut();
        // }
        // // Fluttertoast.showToast(msg: 'IOS VOIP PushKit' );
        //
        // _write(json.encode(payload));

        /// Notifies device of VoIP notifications(PushKit) with curl or your server(See README.md).
        /// [onDidReceiveIncomingPush] is not called when the app is not running, because app is not yet running when didReceiveIncomingPushWith is called.
        print('🎈 example: onDidReceiveIncomingPush $payload');
      };
      iosVoIPKit.onDidAcceptIncomingCall = (
        String uuid,
        String callerId,
      ) {
        MyApp.isAnswered = true;
        iosVoIPKit.endCall();
        // Future.delayed(Duration(seconds: 3), () {
        PushNotificationsManager.navigatorKey.currentState
            .push(MaterialPageRoute(
              builder: (context) => CallingScreen(
                role: ClientRole.Audience,
                isIncomingCall: true,
                channelName: '12',
                peerName: 'Calling',
                peerId: '12',
              ),
            ))
            .whenComplete(() => iosVoIPKit.endCall());
        // });
        // iosVoIPKit.endCall();

        if (isTalking) {
          return;
        }
        // await AgoraCallingManager.engine
        //     .joinChannel(null, payload['room_name'], null, 0)
        //     .then((value) {
        //   print('connected');
        //   // callNotificationOnJoined(true, 'connecting', null);
        // });
        print(' example: onDidAcceptIncomingCall $uuid, $callerId');
        print(' example: onDidAcceptIncomingCall ');
        print(' example: onDidAcceptIncomingCall ' + staticPayload.toString());
        // onJoin(staticPayload);

        // iosVoIPKit.acceptIncomingCall(callerState: CallStateType.idle);

        // iosVoIPKit.callConnected();
        timeOutTimer?.cancel();

        isTalking = true;
      };
      iosVoIPKit.onDidRejectIncomingCall = (
        String uuid,
        String callerId,
      ) async {
        String text;
        try {
          final Directory directory = await getApplicationDocumentsDirectory();
          final File file = File('${directory.path}/my_file.txt');
          text = await file.readAsString();
          print('IOS File Testing' + text.toString());

          if (!MyApp.isAnswered) {
            if (Platform.isAndroid)
              endCallAPI(json.decode(text)['data']['room_name'].toString(),
                  json.decode(text)['data']['sender_id'].toString());
            // await onJoin(json.decode(text)['data'][
            // 'room_name'].toString());
            if (Platform.isIOS)
              endCallAPI(json.decode(text)['room_name'].toString(),
                  json.decode(text)['sender_id'].toString());
          }
          MyApp.isAnswered = false;

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
        // callNotificationOnJoined(false, 'endCall', uuid);
      };
    }
  }

  endCallAPI(channelName, peerId) {
    final String callUUId = Uuid().v4().toString();

    final Map<String, String> data = new Map<String, String>();
    data['callUUID'] = callUUId;
    data['room_name'] = channelName.toString();
    data['receiver_id'] = peerId.toString();
    data['callstatus'] = 'endCall';

    CallApiClient()
        .callUser(data, PushNotificationsManager.navigatorKey.currentContext)
        .then((value) {
      print('miefwopf' + value.body.toString());
      print('miefwopf' + data.toString());
    });
  }

  static _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    await file.writeAsString(text);
  }

  Future<void> onJoin(payload) async {
    // await for camera and mic permissions before pushing video page
    // await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
    // print('api call' + peerId.toString());
    print('api call' + payload['room_name'].toString());
    // print('api call' + payload['receiver_id'].toString());
    await AgoraCallingManager.engine
        .joinChannel(null, payload['room_name'], null, 0);
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  void _timeOut({
    int seconds = 15,
  }) async {
    timeOutTimer = Timer(Duration(seconds: seconds), () async {
      print('🎈 example: timeOut');

      iosVoIPKit.endCall();
    });
  }
}
