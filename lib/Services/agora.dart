import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter_app/Screens/Calling/credential.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraCallingManager {
  AgoraCallingManager._();

  factory AgoraCallingManager() => _instance;
  bool _initialized = false;
  static RtcEngine engine;
  static final _infoStrings = <String>[];

  static final AgoraCallingManager _instance = AgoraCallingManager._();

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.

      initialize();
      _initialized = true;

    }
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      _infoStrings.add(
        'APP_ID missing, please provide your APP_ID in settings.dart',
      );
      _infoStrings.add('Agora Engine is not starting');
      return;
    }
    await [
      Permission.microphone,
    ].request();
    int playbackSignalVolume;
    int recordingSignalVolume;
    int inEarVolume;
    if (Platform.isAndroid) {
      playbackSignalVolume = 400;
      recordingSignalVolume = 100;
      inEarVolume = 100;
    } else {
      playbackSignalVolume = 200;
      recordingSignalVolume = 400;
      inEarVolume = 400;
    }
    await _initAgoraRtcEngine();

    await Future.wait([
      engine.setAudioProfile(
          AudioProfile.Default, AudioScenario.Default),


      // PLAYBACK DEVICE

      // play the audio received on this device at this volume (0 - 400)
      engine.adjustPlaybackSignalVolume(playbackSignalVolume),

      // AUDIO ENGINE

      // do not allow any mixed audio signals when playing audio published from this device
      engine.adjustAudioMixingPublishVolume(0),

      // do not allow any mixed audio signals to be played from this device
      engine.adjustAudioMixingPlayoutVolume(0),

      // RECORDING DEVICE

      // set the recording signal volume of this device
      engine.adjustRecordingSignalVolume(recordingSignalVolume),

      // set the playback volume for listeners with headphones (0 - 100)
      engine.setInEarMonitoringVolume(inEarVolume),

      engine.setChannelProfile(ChannelProfile.Communication),
    ]);

    await engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(1920, 1080);
    await engine.setVideoEncoderConfiguration(configuration);
  }

  Future<void> _initAgoraRtcEngine() async {
    engine = await RtcEngine.create(APP_ID);
    await engine.enableAudio();
    await engine.enableLocalAudio(true);
    await engine.setChannelProfile(ChannelProfile.Communication);
    // await engine.setClientRole(widget.role);
  }

  // Future<void> _addAgoraEventHandlers() async {
  //   engine.setEventHandler(RtcEngineEventHandler(
  //     joinChannelSuccess: (String channel, int uid, int elapsed) {
  //       print('joinChannelSuccess $channel $uid');
  //       callNotificationOnJoined(true, 'connecting', uid);
  //
  //       setState(() {
  //         callingStatus = 'connecting';
  //       });
  //       engine.setDefaultAudioRoutetoSpeakerphone(true);
  //       // engine.setEnableSpeakerphone(true);
  //     },
  //     leaveChannel: (RtcStats stats) {
  //       // _onCallEnd(context);
  //     },
  //     userJoined: (int uid, int elapsed) {
  //       timerForCallDuration();
  //       setState(() {
  //         callingStatus = 'connected';
  //         playEffect = false;
  //       });
  //       print('userJoined $uid');
  //     },
  //     userOffline: (int uid, UserOfflineReason reason) {
  //       switch (reason) {
  //         case UserOfflineReason.Dropped:
  //           _onCallEnd(context);
  //           break;
  //         case UserOfflineReason.Quit:
  //           _onCallEnd(context);
  //           // TODO: Handle this case.
  //           break;
  //         case UserOfflineReason.BecomeAudience:
  //           // TODO: Handle this case.
  //           break;
  //       }
  //
  //       print('userOffline $uid');
  //     },
  //     rtmpStreamingStateChanged: (url, RtmpStreamingState state, errCode) {
  //       if (state.index == 0) {
  //         setState(() {
  //           callingStatus = 'Connecting';
  //         });
  //       }
  //       if (state.index == 4) {
  //         setState(() {
  //           callingStatus = 'failed';
  //         });
  //         _onCallEnd(context);
  //       }
  //     },
  //     apiCallExecuted: (error, api, result) {},
  //     userInfoUpdated: (uid, userInfo) {},
  //     localUserRegistered: (uid, userAccount) {
  //       // callNotificationOnJoined(true, 'connecting', uid);
  //     },
  //     rtcStats: (RtcStats stats) {
  //       if (callingStatus == 'connected') {
  //         setState(() {
  //           callingStatus = stats.totalDuration.toString();
  //         });
  //       }
  //     },
  //   ));
  //   await engine.joinChannel(null, widget.channelName, null, 0);
  // }
}
