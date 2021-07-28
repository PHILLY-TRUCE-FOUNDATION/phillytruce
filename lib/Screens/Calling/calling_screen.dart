import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Providers/call_api.dart';
import 'package:flutter_app/Services/agora.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:flutter_app/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CallingScreen extends StatefulWidget {
  String channelName, peerId, peerName;
  bool isIncomingCall, isUserJoined;

  /// non-modifiable client role of the page
  ClientRole role;

  /// Creates a call page with given channel name.
  CallingScreen(
      {Key key,
      this.channelName,
      this.role,
      this.isIncomingCall,
      this.peerId,
      this.peerName,
      this.isUserJoined})
      : super(key: key);

  @override
  _CallingScreenState createState() => _CallingScreenState(
      this.channelName,
      this.role,
      this.isIncomingCall,
      this.peerId,
      this.peerName,
      this.isUserJoined);
}

class _CallingScreenState extends State<CallingScreen> {
  _CallingScreenState(this.channelName, this.role, this.isIncomingCall,
      this.peerId, this.peerName, this.isUserJoined);

  String notificationData;
  String channelName, peerId, peerName;
  bool isIncomingCall;
  bool isUserJoined = false;

  /// non-modifiable client role of the page
  ClientRole role;

  static final _users = <int>[];
  static final _infoStrings = <String>[];
  static bool muted = false;
  static String callingStatus = 'connecting';
  static Timer timer;
  static bool playEffect;
  int _start = 00;
  int result;
  AudioCache audioCache = AudioCache();
  static const platform =
      const MethodChannel('samples.flutter.dev/VoIPNotification');
  String _VoIPPayLoad;
  AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: Center(
            child: /*isIncomingCall ? incomingCall() :*/ calling(),
          ),
        ),
      ),
    );
  }

  Widget calling() {
    SizeConfig().init(context);
    return Container(
      height: ResponsiveFlutter.of(context).hp(70.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: SizeConfig.safeBlockHorizontal * 30,
            height: SizeConfig.safeBlockVertical * 20,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Card(
                  margin: EdgeInsets.only(top: 8.0, bottom: 6.0),
                  clipBehavior: Clip.hardEdge,
                  child: Container(),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          ResponsiveFlutter.of(context).hp(3.0))),
                ),
                Text(
                  getCharacters(peerName).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: fontStyle,
                      color: Colors.black,
                      fontSize: ResponsiveFlutter.of(context).fontSize(5.5)),
                ),
              ],
            ),
          ),
          TextWidgets().semiBoldTextWidget(Colors.white, peerName, context,
              ResponsiveFlutter.of(context).fontSize(2.0)),
          Container(
            padding: EdgeInsets.only(top: 0.0),
            child: TextWidgets().semiBoldTextWidget(Colors.white, callingStatus,
                context, ResponsiveFlutter.of(context).fontSize(3.0)),
          ),
          // Container(
          //   padding: EdgeInsets.only(top: 15.0),
          //   child: TextWidgets().simpleTextWidget(
          //     labelColor,
          //     '00:00:05',
          //     context,
          //     ResponsiveFlutter.of(context).fontSize(2.0),
          //   ),
          // ),
          Flexible(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: InkResponse(
                child: Image.asset('assets/images/group_reject.png'),
                onTap: () => _onCallEnd(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getCharacters(String peerName) {
    List<String> list = List();
    if (peerName.characters.length > 1) {
      String firstCharacter = peerName.characters.elementAt(0),
          secondCharacter = peerName.characters.elementAt(1);
      if (peerName.contains(' ')) {
        list = peerName.split(' ');

        firstCharacter = list[0].characters.elementAt(0);
        secondCharacter = list[1].characters.isNotEmpty
            ? list[1].characters.elementAt(0)
            : list[0].characters.elementAt(1);
      }
      return firstCharacter + secondCharacter;
    } else {
      list = peerName.split(' ');
      String firstCharacter = peerName.characters.elementAt(0);
      firstCharacter = list[0].characters.elementAt(0);
      return firstCharacter + firstCharacter;
    }
  }

  Widget incomingCall() {
    return Container(
      height: ResponsiveFlutter.of(context).hp(70.0),
      child: Column(
        children: [
          Container(
            width: SizeConfig.safeBlockHorizontal * 30,
            height: SizeConfig.safeBlockVertical * 20,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Card(
                  margin: EdgeInsets.only(top: 8.0, bottom: 6.0),
                  clipBehavior: Clip.hardEdge,
                  child: Container(),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          ResponsiveFlutter.of(context).hp(3.0))),
                ),
                Text(
                  getCharacters(peerName).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: fontStyle,
                      color: Colors.black,
                      fontSize: ResponsiveFlutter.of(context).fontSize(5.5)),
                ),
              ],
            ),
          ),
          TextWidgets().semiBoldTextWidget(Colors.white, peerName, context,
              ResponsiveFlutter.of(context).fontSize(2.0)),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                  left: ResponsiveFlutter.of(context).hp(10.0),
                  right: ResponsiveFlutter.of(context).hp(10.0)),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkResponse(
                      child: Image.asset('assets/images/group.png'),
                      onTap: () => onJoin('12'),
                    ),
                    InkResponse(
                      child: Image.asset('assets/images/group_reject.png'),
                      onTap: () => _onCallEnd(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    stopRingin();

    isUserJoined = false;
    // setState(() {
    MyApp.isCallingScreen = false;
    // });
    // clear users
    _users.clear();
    // destroy sdk
    AgoraCallingManager.engine.leaveChannel();
    // AgoraCallingManager.engine.destroy();
    super.dispose();
  }

  stopRingin() async {
    result = await audioPlayer.pause();
  }

  @override
  void initState() {
    // getData();
    playRing();

    _start = 0;
    super.initState();
    // initialize agora sdk
    initialize();
    if (Platform.isIOS) {
      _getVoIPPayload();
    }
    setState(() {
      MyApp.isCallingScreen = true;
    });
  }

  getData() async {
    SharedPreferences notificationDatasss =
        await SharedPreferences.getInstance();

    notificationData = await notificationDatasss.get('notificationDataStore');
    print('Get Notificaiton Data ' + notificationData.toString());
  }

  Future<void> _getVoIPPayload() async {
    String VoIPPayLoad;
    try {
      final int result = await platform.invokeMethod('getVoIPPayload');
      VoIPPayLoad = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      VoIPPayLoad = "Failed to get battery level: '${e.message}'.";
    }

    // setState(() {
    //   _VoIPPayLoad = VoIPPayLoad;
    // });
  }

  Future<void> initialize() async {
    // if (APP_ID.isEmpty) {
    //   setState(() {
    //     _infoStrings.add(
    //       'APP_ID missing, please provide your APP_ID in settings.dart',
    //     );
    //     _infoStrings.add('Agora Engine is not starting');
    //   });
    //   return;
    // }
    // await [
    //   Permission.microphone,
    // ].request();
    // int playbackSignalVolume;
    // int recordingSignalVolume;
    // int inEarVolume;
    // if (Platform.isAndroid) {
    //   playbackSignalVolume = 400;
    //   recordingSignalVolume = 100;
    //   inEarVolume = 100;
    // } else {
    //   playbackSignalVolume = 100;
    //   recordingSignalVolume = 400;
    //   inEarVolume = 400;
    // }
    // // await _initAgoraRtcEngine();

    if (!widget.isIncomingCall) {
      playLocal();
      _addAgoraEventHandlers();
      await AgoraCallingManager.engine
          .joinChannel(null, widget.channelName, null, 0)
          .then((value) {
        print('connected');
        // callNotificationOnJoined(true, 'connecting', null);
      });
    }

    if (isIncomingCall) {
      // if(Platform.isAndroid) {
      String text;
      try {
        final Directory directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/my_file.txt');
        text = await file.readAsString();
        print('IOS File Testing' + text.toString());
        if (Platform.isAndroid)
          await onJoin(json.decode(text)['data']['room_name'].toString());
        if (Platform.isIOS)
          await onJoin(json.decode(text)['room_name'].toString());
        setState(() {
          if (Platform.isAndroid)
            peerName =
                json.decode(text)['data']['incoming_caller_name'].toString();
          if (Platform.isIOS)
            peerName = json.decode(text)['incoming_caller_name'].toString();
        });
      } catch (e) {
        print("Couldn't read file" + e.toString());
      }
      // }else if(Platform.isIOS){
      //   await onJoin(channelName);
      //
      //
      // }
      // if (Platform.isAndroid) _switchEffect();
    }
  }

  /// Add agora event handlers
  Future<void> _addAgoraEventHandlers() async {
    AgoraCallingManager.engine.enableInEarMonitoring(true);
    AgoraCallingManager.engine.setInEarMonitoringVolume(200);

    // AgoraCallingManager.engine.setAudioProfile(AudioProfile.SpeechStandard, AudioScenario.Default)+

    AgoraCallingManager.engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print('joinChannelSuccess $channel $uid');
          callNotificationOnJoined(true, 'connecting', uid);

          setState(() {
            callingStatus = 'connecting';
          });
          // AgoraCallingManager.engine.setDefaultAudioRoutetoSpeakerphone(false);
          // _engine.setEnableSpeakerphone(true);
        },
        leaveChannel: (RtcStats stats) {
          // _onCallEnd(context);
        },
        userJoined: (int uid, int elapsed) async {
          result = await audioPlayer.pause();

          timerForCallDuration();
          // setState(() {
          //   callingStatus = 'connected';
          //   playEffect = false;
          // });
          print('userJoined $uid');
        },
        userOffline: (int uid, UserOfflineReason reason) {
          switch (reason) {
            case UserOfflineReason.Dropped:
              _onCallEnd(context);
              break;
            case UserOfflineReason.Quit:
              _onCallEnd(context);
              // TODO: Handle this case.
              break;
            case UserOfflineReason.BecomeAudience:
              // TODO: Handle this case.
              break;
          }

          print('userOffline $uid');
        },
        rtmpStreamingStateChanged: (url, RtmpStreamingState state, errCode) {
          if (state.index == 0) {
            setState(() {
              callingStatus = 'Connecting';
            });
          }
          if (state.index == 4) {
            setState(() {
              callingStatus = 'failed';
            });
            _onCallEnd(context);
          }
        },
        apiCallExecuted: (error, api, result) {},
        userInfoUpdated: (uid, userInfo) {},
        localUserRegistered: (uid, userAccount) {
          // callNotificationOnJoined(true, 'connecting', uid);
        },
        rtcStats: (RtcStats stats) {
          if (callingStatus == 'connected') {
            setState(() {
              callingStatus = stats.totalDuration.toString();
            });
          }
        }));
  }

  Future<void> _onCallEnd(BuildContext context) async {
    String callUUID = Uuid().v4().toString();

    result = await audioPlayer.pause();

    // if (!isUserJoined) {
    //   callNotificationOnJoined(false, 'endCall', callUUID);
    // }
    cancelTimer();

    // if (Platform.isAndroid) SplashScreen.callKeep.endAllCalls();

    // callKeep.endCall(event.callUUID);

    // callNotificationOnJoined(false, 'endCall', callUUID);
    // if (Platform.isIOS) {
    callNotificationOnJoined(false, 'endCall', callUUID);
    // VoIPPushManager.iosVoIPKit.endCall();
    // }
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraCallingManager.engine.muteLocalAudioStream(muted);
  }

  callNotificationOnJoined(bool isIncomingCall, String callStatus, callUUID) {
    // print('api call');
    // print('api call' + peerId.toString());
    // print('api call' + widget.peerId.toString());
    // print('api call' + channelName.toString());
    // print('api call' + callStatus.toString());

    final String callUUId = Uuid().v4().toString();

    final Map<String, String> data = new Map<String, String>();
    data['callUUID'] = callUUId;
    data['room_name'] = channelName.toString();
    data['receiver_id'] = peerId.toString();
    data['callstatus'] = callStatus.toString();

    print('Call data' + data.toString());
    CallApiClient().callUser(data, context).then((value) {
      print('miefwopf' + value.body.toString());
      print('miefwopf' + data.toString());
    });
  }

  Future<void> onJoin(roomName) async {
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
    // print('api call' + peerId.toString());
    print('api call' + channelName.toString());
    await AgoraCallingManager.engine.joinChannel(null, roomName, null, 0);
    setState(() {
      playEffect = false;
      _addAgoraEventHandlers();
      isIncomingCall = false;
    });
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  void timerForCallDuration() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.isActive) {
        _start++;
        // if (!mounted)
        setState(() {
          isUserJoined = true;
          callingStatus = timeFormatter(double.parse(_start.toString()));
        });
        // else{
        //   cancelTimer();
        // }
      }
    });
  }

  void cancelTimer() {
    timer?.cancel();
  }

  String timeFormatter(double time) {
    Duration duration = Duration(seconds: time.round());
    return [duration.inHours, duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  _switchEffect(playEffect) async {
    if (!playEffect) {
      AgoraCallingManager.engine
          ?.stopEffect(1)
          ?.then((value) {})
          ?.catchError((err) {
        print('stopEffect $err');
      });
    } else {
      AgoraCallingManager.engine
          ?.playEffect(
              1,
              await RtcEngineExtension.getAssetAbsolutePath(
                  "assets/ringtone.mp3"),
              -1,
              1,
              1,
              100,
              true)
          ?.then((value) {})
          ?.catchError((err) {
        print('playEffect $err');
      });
    }
  }

  playRing() async {
    audioPlayer = AudioPlayer();
    // await audioPlayer.setUrl(
    //   audiofile.path,
    // );
  }

  playLocal() async {
    File audiofile = await audioCache.load('phone_ring.mp3');

    result = await audioPlayer.play(audiofile.path);

    // result= await audioPlayer.earpieceOrSpeakersToggle();
  }
}
