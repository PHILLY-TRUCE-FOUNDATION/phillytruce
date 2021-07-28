import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/Providers/cancel_help.dart';
import 'package:flutter_app/Screens/UsersScreens/chatList.dart';
import 'package:flutter_app/Screens/chat_screen.dart';
import 'package:flutter_app/Services/firebase.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:flutter_ios_voip_kit/flutter_ios_voip_kit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Main/Bloc/user/get_mediator_status.dart';
import 'package:flutter_app/Model/mediator_status.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/update_user_location.dart';
import 'package:flutter_app/Screens/Calling/calling_screen.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

import '../home_screen.dart';

class FinalMessageScreen extends StatefulWidget {
  @override
  _FinalMessageScreenState createState() => _FinalMessageScreenState();
}

class _FinalMessageScreenState extends State<FinalMessageScreen>
    with WidgetsBindingObserver {
  Data userData;
  AppLifecycleState _notification;
  bool _loading = true;

  // Position currentPosition;
  Location previousPosition1;
  Location currentPosition1;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String previousAddress;
  String currentAddress;
  http.Client httpClient = http.Client();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: WillPopScope(
        child: Container(
            width: SizeConfig.safeBlockHorizontal * 100,
            height: SizeConfig.safeBlockVertical * 100,
            decoration: backgroundBoxDecoration,
            child: messageScreen()),
        onWillPop: onBackPress,
      ),
    );
  }

  Future<bool> onBackPress() async {
    String status = await SaveDataLocal.getUserStatus();

    if (status != 'UserCancel')
      SystemNavigator.pop();
    else
      Navigator.pop(context);

    return Future.value(false);
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("$error"),
      ],
    ));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration(seconds: 2), () {
      location();
    });
    getMediatorStatusBloc.getMediatorStatus();
    getUserData();
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
  }

  navigateScreen(message) {
    print('fkw[' + message.toString());
    if (Platform.isAndroid) {
      if (json.decode(message)['data']['notification_type'] ==
          'chat_notification') {
        PushNotificationsManager.navigatorKey.currentState
            .push(MaterialPageRoute(
          builder: (context) => ChatScreen(
              json.decode(message)['data']['sender_id'] != null
                  ? int.parse(json.decode(message)['data']['sender_id'])
                  : 0,
              json.decode(message)['data']['help_id'] != null
                  ? int.parse(json.decode(message)['data']['help_id'])
                  : 0,
              json.decode(message)['data']['receiver_id'] != null
                  ? int.parse(json.decode(message)['data']['receiver_id'])
                  : 0,
              false,
              false,
              true),
        ));
      }
    } else {
      if (json.decode(message)['notification_type'] == 'chat_notification') {
        PushNotificationsManager.navigatorKey.currentState
            .push(MaterialPageRoute(
          builder: (context) => ChatScreen(
              json.decode(message)['sender_id'] != null
                  ? int.parse(json.decode(message)['sender_id'])
                  : 0,
              json.decode(message)['help_id'] != null
                  ? int.parse(json.decode(message)['help_id'])
                  : 0,
              json.decode(message)['receiver_id'] != null
                  ? int.parse(json.decode(message)['receiver_id'])
                  : 0,
              false,
              false,
              true),
        ));
      }
    }
  }

  Widget messageScreen() {
    SizeConfig().init(context);
    return Container(
      width: SizeConfig.safeBlockHorizontal * 100,
      height: SizeConfig.safeBlockVertical * 100,
      child: Column(children: [
        new Flexible(
          flex: 2,
          child: Center(
            child: Image.asset('assets/images/philly_truce_text_logo.png'),
          ),
        ),
        new Flexible(
          flex: 6,
          child: _loading
              ? Card(
                  margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.elliptical(
                          ResponsiveFlutter.of(context).hp(2.0),
                          ResponsiveFlutter.of(context).hp(2.0)))),
                  child: Container(
                    margin: EdgeInsets.all(0.0),
                    width: SizeConfig.safeBlockHorizontal * 100,
                    height: SizeConfig.safeBlockVertical * 100,
                    child: Center(
                      child: Platform.isAndroid
                          ? CircularProgressIndicator()
                          : CupertinoActivityIndicator(),
                    ),
                  ))
              : StreamBuilder<MediatorStatus>(
                  stream: getMediatorStatusBloc.subject.stream,
                  builder: (context, AsyncSnapshot<MediatorStatus> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.statusCode != 101)
                        return Container(
                          margin: EdgeInsets.all(0.0),
                          width: SizeConfig.safeBlockHorizontal * 100,
                          child: Card(
                            margin: EdgeInsets.all(
                                ResponsiveFlutter.of(context).hp(2.0)),
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(
                                        ResponsiveFlutter.of(context).hp(2.0),
                                        ResponsiveFlutter.of(context)
                                            .hp(2.0)))),
                            child: Container(
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 25.0),
                                      child: TextWidgets().boldTextWidget(
                                        homeButtonTextColor,
                                        Strings.firstLine,
                                        context,
                                        ResponsiveFlutter.of(context)
                                            .fontSize(3.0),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 25.0),
                                      child: TextWidgets().boldTextWidget(
                                        homeButtonTextColor,
                                        Strings.secondLine,
                                        context,
                                        ResponsiveFlutter.of(context)
                                            .fontSize(3.0),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 30.0),
                                      child: TextWidgets().boldTextWidget(
                                        homeButtonTextColor,
                                        Strings.thirdLine,
                                        context,
                                        ResponsiveFlutter.of(context)
                                            .fontSize(3.0),
                                      ),
                                    ),
                                    footer(snapshot)
                                  ]),
                            ),
                          ),
                        );
                      else
                        return Card(
                            margin: EdgeInsets.all(
                                ResponsiveFlutter.of(context).hp(2.0)),
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(
                                        ResponsiveFlutter.of(context).hp(2.0),
                                        ResponsiveFlutter.of(context)
                                            .hp(2.0)))),
                            child: _buildErrorWidget(
                                snapshot.data.message.toString()));
                    } else if (snapshot.hasError) {
                      return Card(
                          margin: EdgeInsets.all(
                              ResponsiveFlutter.of(context).hp(2.0)),
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.elliptical(
                                  ResponsiveFlutter.of(context).hp(2.0),
                                  ResponsiveFlutter.of(context).hp(2.0)))),
                          child: _buildErrorWidget(snapshot.error));
                    } else {
                      return Card(
                        margin: EdgeInsets.all(
                            ResponsiveFlutter.of(context).hp(2.0)),
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.elliptical(
                                ResponsiveFlutter.of(context).hp(2.0),
                                ResponsiveFlutter.of(context).hp(2.0)))),
                        child: Container(
                          margin: EdgeInsets.all(0.0),
                          width: SizeConfig.safeBlockHorizontal * 100,
                          height: SizeConfig.safeBlockVertical * 100,
                          child: Center(
                            child: _buildErrorWidget(snapshot.error.toString()),
                          ),
                        ),
                      );
                    }
                  },
                ),
        ),
      ]),
    );
  }

  Widget footer(AsyncSnapshot<MediatorStatus> snapshot) {
    return snapshot.data.status == false
        ? Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Padding(
                  //     padding: EdgeInsets.only(right: 10.0),
                  //     child: Image.asset('assets/images/pending_ic.png')),
                  // TextWidgets().semiBoldTextWidget(
                  //     sendButtonColor,
                  //     Strings.statusPending,
                  //     context,
                  //     ResponsiveFlutter.of(context).fontSize(3.0)),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: FlatButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: homeScreenBackgroundColor,
                            borderRadius: BorderRadius.all(
                                Radius.elliptical(10.0, 10.0))),
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(
                            ResponsiveFlutter.of(context).hp(3.0),
                            ResponsiveFlutter.of(context).hp(1.0),
                            ResponsiveFlutter.of(context).hp(0.0),
                            0),
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Text(
                          Strings.cancelRequest,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontStyle,
                              fontSize:
                                  ResponsiveFlutter.of(context).fontSize(2.5)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onPressed: () async {
                        await SaveDataLocal.saveUserStatus('UserCancel');
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                            (route) => false);
                      },
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: FlatButton(
                      onPressed: () {
                        print('Flutter Fully Truce' +
                            userData.help_id.toString());
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatList(
                                    userData.help_id, userData.user_id)));
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Container(
                          width: SizeConfig.safeBlockHorizontal * 14,
                          height: SizeConfig.safeBlockHorizontal * 14,
                          decoration: BoxDecoration(
                              color: sendButtonColor,
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(10.0, 10.0))),
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(
                              ResponsiveFlutter.of(context).hp(0.0),
                              ResponsiveFlutter.of(context).hp(1.0),
                              ResponsiveFlutter.of(context).hp(0.0),
                              0),
                          child: Image.asset('assets/images/chat_ic.png')),
                    ),
                  ),
                  // GestureDetector(
                  //     child: Container(
                  //         margin: EdgeInsets.only(
                  //             top: ResponsiveFlutter.of(context).hp(5.0)),
                  //         alignment: Alignment.bottomCenter,
                  //         width: SizeConfig.safeBlockHorizontal * 1,
                  //         height: SizeConfig.safeBlockHorizontal * 12,
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.all(
                  //                 Radius.elliptical(10.0, 10.0)),
                  //             color: sendButtonColor,
                  //             image: DecorationImage(
                  //                 image:
                  //                     AssetImage('assets/images/chat_ic.png'),
                  //                 alignment: Alignment.center))),
                  //     onTap: () {
                  //       /* onJoin(
                  //                 context)*/
                  //       print('Flutter Fully Truce' +
                  //           snapshot.data.data.help_id.toString());
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) =>
                  //                   ChatList(snapshot.data.data.help_id)));
                  //     })
                ],
              )
            ],
          )
        : snapshot.data.status == true
            ? snapshot.data.statusCode == 3
                ? snapshot.data.data.follow_up_status == 'pending'
                    ? Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Padding(
                              //     padding: EdgeInsets.only(right: 10.0),
                              //     child: Image.asset(
                              //         'assets/images/pending_ic.png')),
                              // TextWidgets().semiBoldTextWidget(
                              //     sendButtonColor,
                              //     Strings.statusPending,
                              //     context,
                              //     ResponsiveFlutter.of(context).fontSize(3.0)),
                            ],
                          ),
                          GestureDetector(
                              child: Container(
                                  margin: EdgeInsets.only(
                                      top: ResponsiveFlutter.of(context)
                                          .hp(5.0)),
                                  alignment: Alignment.bottomCenter,
                                  width: SizeConfig.safeBlockHorizontal * 12,
                                  height: SizeConfig.safeBlockHorizontal * 12,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.elliptical(10.0, 10.0)),
                                      color: sendButtonColor,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/chat_ic.png'),
                                          alignment: Alignment.center))),
                              onTap: () {
                                /* onJoin(
                                  context)*/
                                print('Flutter Fully Truce' +
                                    snapshot.data.data.help_id.toString());
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            snapshot.data.data.user_id,
                                            snapshot.data.data.help_id,
                                            userData.user_id,
                                            false,
                                            false,
                                            true)));
                              })
                        ],
                      )
                    : FlatButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: sendButtonColor,
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(10.0, 10.0))),
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(
                              ResponsiveFlutter.of(context).hp(2.0),
                              ResponsiveFlutter.of(context).hp(1.0),
                              ResponsiveFlutter.of(context).hp(2.0),
                              0),
                          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Text(
                            Strings.done,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: fontStyle,
                                fontSize: ResponsiveFlutter.of(context)
                                    .fontSize(2.5)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onPressed: () {
                          helpDone();
                        },
                      )
                : snapshot.data.toJson()['data']['help_status'] == 'cancel'
                    ? FlatButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: sendButtonColor,
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(10.0, 10.0))),
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(
                              ResponsiveFlutter.of(context).hp(2.0),
                              ResponsiveFlutter.of(context).hp(1.0),
                              ResponsiveFlutter.of(context).hp(2.0),
                              0),
                          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Text(
                            Strings.done,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: fontStyle,
                                fontSize: ResponsiveFlutter.of(context)
                                    .fontSize(2.5)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onPressed: () {
                          SaveDataLocal.saveUserStatus('done');
                          BackgroundLocation.stopLocationService();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                              (route) => false);
                        },
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Padding(
                          //     padding: EdgeInsets.only(right: 10.0),
                          //     child: Image.asset('assets/images/pending_ic.png')),
                          // TextWidgets().semiBoldTextWidget(
                          //     sendButtonColor,
                          //     Strings.statusPending,
                          //     context,
                          //     ResponsiveFlutter.of(context).fontSize(3.0)),
                        ],
                      )
            : Container();
  }

  static Future<void> onJoin(context) async {
    // update input validation

    // await for camera and mic permissions before pushing video page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallingScreen(
          channelName: '2',
          role: ClientRole.Broadcaster,
        ),
      ),
    );
  }

  helpDone() {
    SaveDataLocal.saveUserStatus('done');
    BackgroundLocation.stopLocationService();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
        (route) => false);
  }

  cancelRequest() {
    Utils.showProgressBar(context);
    CancelHelpRequestClient().cancelHelpRequest(userData.help_id).then((value) {
      if (value == 'Help updated successfully.') {
        SaveDataLocal.saveUserStatus('done');
        BackgroundLocation.stopLocationService();
        Utils.dismissProgressBar(context);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
            (route) => false);
      } else {
        print('ni' + value.toString());
        Utils.dismissProgressBar(context);
        Fluttertoast.showToast(msg: 'Something went wrong');
      }
    });
  }

  getUserData() async {
    userData = await SaveDataLocal.getUserDataFromLocal();

    print('Flutter Fully Truce' + userData.device_token.toString());

    FlutterIOSVoIPKit _voipPush = FlutterIOSVoIPKit();
    _voipPush.getVoIPToken().then((value) {
      print('Flutter Fully Truce VoIP Token' + value.toString());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
    print('Last notification: $_notification');

    switch (state) {
      case AppLifecycleState.resumed:
        // widget is resumed
        getMediatorStatusBloc.getMediatorStatus();

        print('dimi' + 'resumed');

        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        print('dimi' + 'inactive');

        break;
      case AppLifecycleState.paused:
        // widget is paused
        print('dimi' + 'paused');
        break;
      case AppLifecycleState.detached:
        print('dimi' + 'detached');

        // widget is detached
        break;
    }
  }

  // Future<void> displayIncomingCall(message) async {
  //   print('mfiopwe' + message.toString());
  //
  //   await CallKeep.askForPermissionsIfNeeded(context);
  //
  //   final callUUID = '0783a8e5-8353-4802-9448-c6211109af52';
  //   final number = '+91 123456';
  //   final roomName = '2';
  //   final callstatus = 'calling';
  //   await CallKeep.isCurrentDeviceSupported.then((value){
  //     print('nfow' + value.toString());
  //   });
  //   // await CallKeep.askForPermissionsIfNeeded(context);
  //   await CallKeep.displayIncomingCall(
  //       callUUID, number, number, HandleType.number, false);
  //
  //
  // }

  location() async {
    bool hasBackgroundPermission = await BackgroundLocation.checkPermissions().isGranted;
    if (hasBackgroundPermission) {
      BackgroundLocation.startLocationService();
      BackgroundLocation.setAndroidConfiguration(1000);

      BackgroundLocation.getLocationUpdates((location) {
        // Fluttertoast.showToast(msg: 'Location Changed' + location.toString());
        currentPosition1 = location;
        updateLocation(userData.help_id, location);
      });
    }
  }

  updateLocation(helpId, Location location) {
    // Fluttertoast.showToast(msg: 'Update Location');
    if (previousPosition1 == null) {
      // _getCurrentLocation(helpId);
      // _getAddressFromLatLng(helpId);
      _getLocation(helpId);
      previousPosition1 = location;
      // Fluttertoast.showToast(msg: 'Call API');
    } else {
      geolocator
          .distanceBetween(
              previousPosition1.latitude,
              previousPosition1.longitude,
              currentPosition1.latitude,
              currentPosition1.longitude)
          .then((double distance) {
        // Fluttertoast.showToast(msg: distance.toString());

        if (distance >= 100) {
          // _getCurrentLocation(helpId);
          _getLocation(helpId);
          previousPosition1 = currentPosition1;
          // Fluttertoast.showToast(msg: 'Call API');
        }
      });
    }
  }

  _getLocation(helpId) async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position.latitude}');
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    currentAddress = first.addressLine;
    print("Adrees Lcoation New : - " +
        "${first.featureName} : ${first.addressLine}");
    UpdateUserLocationClient(httpClient: httpClient).updateUserLocation(
        LatLng(currentPosition1.latitude, currentPosition1.longitude),
        helpId,
        currentAddress);
  }
}
