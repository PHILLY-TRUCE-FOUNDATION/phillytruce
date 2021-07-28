import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Main/Bloc/Mediator/get_backup_mediator.dart';
import 'package:flutter_app/Main/Bloc/user/get_user_bloc.dart';
import 'package:flutter_app/Model/back_up_mediator_list.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/cancel_help.dart';
import 'package:flutter_app/Providers/mediator/cancel_help.dart';
import 'package:flutter_app/Providers/mediator/response_mediator_request.dart';
import 'package:flutter_app/Providers/mediator/response_user_request.dart';
import 'package:flutter_app/Screens/Calling/calling_screen.dart';
import 'package:flutter_app/Screens/chat_screen.dart';
import 'package:flutter_app/Services/firebase.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/error_widget.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:flutter_ios_voip_kit/flutter_ios_voip_kit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

import 'map_screen.dart';
import 'mediator_profile_login.dart';

class UserInformation extends StatelessWidget {
  final String notificationType;
  final int helpId;
  final int userUserId;
  final int requestBackupId;
  final bool isFromNotification;

  UserInformation(this.notificationType, this.helpId, this.userUserId,
      this.requestBackupId, this.isFromNotification);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserInformationStat(notificationType, helpId, userUserId,
          requestBackupId, isFromNotification),
    );
  }
}

class UserInformationStat extends StatefulWidget with WidgetsBindingObserver {
  final String notificationType;
  final int helpId;
  final int userUserId;
  final int requestBackupId;
  final bool isFromNotification;

  UserInformationStat(
    this.notificationType,
    this.helpId,
    this.userUserId,
    this.requestBackupId,
    this.isFromNotification,
  );

  @override
  _UserInformationState createState() => _UserInformationState(notificationType,
      helpId, userUserId, requestBackupId, isFromNotification);
}

class _UserInformationState extends State<UserInformationStat>
    with WidgetsBindingObserver {
  Data userData;

  String notificationType;
  int helpId;
  int userUserId;
  int request_backup_id;

  bool isResponded = false;
  bool isFromNotification;

  List<BackUpMediatorListData> backUpMediatorList = List();
  bool _loading = true;

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$error"),
        ],
      ),
    );
  }

  Future<bool> onBackPress() {
    if (isResponded == true)
      SystemNavigator.pop();
    // Navigator.of(context).pop(true);
    else if (isFromNotification) {
      if (Platform.isAndroid)
        PushNotificationsManager.flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails()
            .then((NotificationAppLaunchDetails value) {
          if (value.didNotificationLaunchApp) {
            PushNotificationsManager.navigatorKey.currentState
                .push(MaterialPageRoute(
              builder: (context) => MediatorRegistrationScreen(true, true),
            ));
          }
        });
      else {
        Navigator.pop(context);
      }
    } else
      Navigator.pop(context);

    return Future.value(false);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getUserbloc.getUser(helpId);

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _loading = false;
      });
    });
    request_backup_id =
        request_backup_id.toString().isEmpty ? 0 : request_backup_id;
    getUserData();

    super.initState();
  }

  _UserInformationState(
    this.notificationType,
    this.helpId,
    this.userUserId,
    this.request_backup_id,
    this.isFromNotification,
  );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('Flutter Fully Truce');
        isResponded = SaveDataLocal.getRespondStatus();

        getUserbloc.getUser(helpId);
        this.initState();
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        break;
      case AppLifecycleState.paused:
        // widget is paused

        print('Flutter Fully Truce' + 'paused');
        break;
      case AppLifecycleState.detached:
        // widget is detached
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: isResponded == false
            ? InkResponse(
                onTap: () => onBackPress(),
                child: Image.asset('assets/images/back_ic.png'),
              )
            : Container(),
        shadowColor: Colors.transparent,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: TextWidgets().boldTextWidget(
            homeButtonTextColor,
            Strings.appName,
            context,
            ResponsiveFlutter.of(context).fontSize(3.0)),
      ),
      body:
          /* isResponded
          ? DoubleBackToCloseApp(
              snackBar: const SnackBar(
                content: Text('Tap back again to Exit'),
              ),
              child: Container(
                width: SizeConfig.safeBlockHorizontal * 100,
                height: SizeConfig.safeBlockVertical * 100,
                decoration: backgroundBoxDecoration,
                child: _loading
                    ? Card(
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
                            child: Platform.isAndroid
                                ? CircularProgressIndicator()
                                : CupertinoActivityIndicator(),
                          ),
                        ),
                      )
                    : StreamBuilder<UserInformationModel>(
                        stream: getUserbloc.subject.stream,
                        builder: (context,
                            AsyncSnapshot<UserInformationModel> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.statusCode == 0) {
                              BackgroundLocation.stopLocationService();

                              return Card(
                                margin: EdgeInsets.all(
                                    ResponsiveFlutter.of(context).hp(2.0)),
                                elevation: 1.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.elliptical(
                                            ResponsiveFlutter.of(context)
                                                .hp(2.0),
                                            ResponsiveFlutter.of(context)
                                                .hp(2.0)))),
                                child: dialog(),
                              );
                            } else if (snapshot.data.statusCode == 101) {
                              // Navigator.pushAndRemoveUntil(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => HomeScreen(),
                              //     ),
                              //     (route) => false);
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                  msg: 'Authentication Failed');

                              return Container();
                            } else {
                              return Card(
                                margin: EdgeInsets.all(
                                    ResponsiveFlutter.of(context).hp(2.0)),
                                elevation: 1.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.elliptical(
                                            ResponsiveFlutter.of(context)
                                                .hp(2.0),
                                            ResponsiveFlutter.of(context)
                                                .hp(2.0)))),
                                child: snapshot.data.statusCode == 3
                                    ? userInformation(snapshot.data.data)
                                    : Center(
                                        child: Platform.isAndroid
                                            ? CircularProgressIndicator()
                                            : CupertinoActivityIndicator()),
                              );
                            }
                          } else if (snapshot.hasError) {
                            return _buildErrorWidget(snapshot.error);
                          } else {
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
                              child: Center(
                                  child: Platform.isAndroid
                                      ? CircularProgressIndicator()
                                      : CupertinoActivityIndicator()),
                            );
                          }
                        },
                      ),
              ))
          : */
          WillPopScope(
        child: Container(
          width: SizeConfig.safeBlockHorizontal * 100,
          height: SizeConfig.safeBlockVertical * 100,
          decoration: backgroundBoxDecoration,
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
              : StreamBuilder<UserInformationModel>(
                  stream: getUserbloc.subject.stream,
                  builder:
                      (context, AsyncSnapshot<UserInformationModel> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.statusCode == 0) {
                        BackgroundLocation.stopLocationService();
                        return Card(
                          margin: EdgeInsets.all(
                              ResponsiveFlutter.of(context).hp(2.0)),
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.elliptical(
                                  ResponsiveFlutter.of(context).hp(2.0),
                                  ResponsiveFlutter.of(context).hp(2.0)))),
                          child: dialog(),
                        );
                      } else {
                        return Card(
                          margin: EdgeInsets.all(
                              ResponsiveFlutter.of(context).hp(2.0)),
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.elliptical(
                                  ResponsiveFlutter.of(context).hp(2.0),
                                  ResponsiveFlutter.of(context).hp(2.0)))),
                          child: snapshot.data.statusCode == 3
                              ? userInformation(snapshot.data.data)
                              : Center(
                                  child:
                                      _buildErrorWidget(snapshot.data.message)),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return _buildErrorWidget(snapshot.error);
                    } else {
                      return Card(
                        margin: EdgeInsets.all(
                            ResponsiveFlutter.of(context).hp(2.0)),
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.elliptical(
                                ResponsiveFlutter.of(context).hp(4.0),
                                ResponsiveFlutter.of(context).hp(4.0)))),
                        child: Center(
                            child: Platform.isAndroid == true
                                ? CircularProgressIndicator()
                                : CupertinoActivityIndicator()),
                      );
                    }
                  },
                ),
        ),
        onWillPop: () => onBackPress(),
      ),
    );
  }

  Widget userInformation(Data peerData) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(left: 15.0, right: 15.0),
            child: header(peerData),
          ),
          // isRequestBackUp == true ? notificationType == 'help_request' ?

          notificationType == 'help_request'
              ? Container(child: footer(peerData))
              : Container(child: mediatorList(peerData))
        ],
      ),
    );
  }

  Widget header(Data peerData) {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 20.0),
            child: TextWidgets().boldTextWidget(
                homeButtonTextColor,
                'User Information',
                context,
                ResponsiveFlutter.of(context).fontSize(2.5))),
        Container(
          margin:
              EdgeInsets.only(bottom: ResponsiveFlutter.of(context).hp(3.0)),
          height: 2.5,
          decoration: BoxDecoration(
              color: sendButtonColor,
              borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0))),
          width: ResponsiveFlutter.of(context).hp(8.0),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 3.5),
              child: TextWidgets().simpleTextWidget(labelColor, 'Name', context,
                  ResponsiveFlutter.of(context).fontSize(2.0)),
            ),
            Text(
              peerData.name.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                fontFamily: fontStyle,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(
              bottom: ResponsiveFlutter.of(context).hp(2.0),
              top: ResponsiveFlutter.of(context).hp(1.5)),
          height: 1.5,
          decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0))),
          width: SizeConfig.safeBlockHorizontal * 100,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 3.5),
                child: TextWidgets().simpleTextWidget(
                    labelColor,
                    'Mobile Number',
                    context,
                    ResponsiveFlutter.of(context).fontSize(2.0))),
            Text(
              peerData.phone_no.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                fontFamily: fontStyle,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(
              bottom: ResponsiveFlutter.of(context).hp(1.5),
              top: ResponsiveFlutter.of(context).hp(2.5)),
          height: 1.5,
          decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0))),
          width: SizeConfig.safeBlockHorizontal * 100,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 3.5),
                child: TextWidgets().simpleTextWidget(labelColor, 'Email',
                    context, ResponsiveFlutter.of(context).fontSize(2.0))),
            Text(
              peerData.email.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                fontFamily: fontStyle,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(
              bottom: ResponsiveFlutter.of(context).hp(1.5),
              top: ResponsiveFlutter.of(context).hp(2.5)),
          height: 1.5,
          decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0))),
          width: SizeConfig.safeBlockHorizontal * 100,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 3.5, right: 50.0),
                child: TextWidgets().simpleTextWidget(labelColor, 'Location',
                    context, ResponsiveFlutter.of(context).fontSize(2.0))),
            Flexible(
              //newly added
              child: Text(
                peerData.location_name.toString(),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                  fontFamily: fontStyle,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(
              bottom: ResponsiveFlutter.of(context).hp(1.5),
              top: ResponsiveFlutter.of(context).hp(2.5)),
          height: 1.5,
          decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0))),
          width: SizeConfig.safeBlockHorizontal * 100,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.values[0],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 3.5, right: 50.0),
                child: TextWidgets().simpleTextWidget(labelColor, 'Details',
                    context, ResponsiveFlutter.of(context).fontSize(2.0))),
            Flexible(
              //newly added
              child: Text(
                peerData.user_detail.toString(),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: TextStyle(
                  fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                  fontFamily: fontStyle,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(
              bottom: ResponsiveFlutter.of(context).hp(1.5),
              top: ResponsiveFlutter.of(context).hp(2.5)),
          height: 1.5,
          decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0))),
          width: SizeConfig.safeBlockHorizontal * 100,
        ),
      ],
    );
  }

  Widget footer(Data peerData) {
    return Container(
      margin: EdgeInsets.only(right: 10.0, left: 10.0, top: 5.0),
      child: Column(
        children: [
          notificationType == 'help_request'
              ? Container(
                  margin: EdgeInsets.fromLTRB(
                      ResponsiveFlutter.of(context).hp(3.0),
                      ResponsiveFlutter.of(context).hp(1.0),
                      ResponsiveFlutter.of(context).hp(3.0),
                      0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 3,
                        child: InkResponse(
                          child: Container(
                            padding: EdgeInsets.only(
                                right: 20.0,
                                bottom: 10.0,
                                top: 10.0,
                                left: 20.0),
                            decoration: BoxDecoration(
                                color: trueCallColor,
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(10.0, 10.0))),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage(
                                      'assets/images/phone_call_ic.png'),
                                ),
                                Padding(padding: EdgeInsets.only(right: 10.0)),
                                TextWidgets().boldTextWidget(
                                    Colors.white,
                                    'TRUCE CALL',
                                    context,
                                    ResponsiveFlutter.of(context).fontSize(2.0))
                              ],
                            ),
                          ),
                          onTap: () =>
                              callAPiCalling(peerData.user_id, peerData.name),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                            child: Container(
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
                                      alignment: Alignment.center)),
                            ),
                            onTap: () {
                              if (isResponded) {
                                navigateChatScreen(userData.user_id,
                                    peerData.user_id, peerData.name);
                              } else {
                                getUserbloc
                                    .getUserForHelpStatus(helpId)
                                    .then((UserInformationModel value) {
                                  if (value.data.help_status == 'cancel') {
                                    showStaticAlertDialog(
                                        context, 'help cancelled by user');
                                    // Fluttertoast.showToast(msg: 'help was cancel');
                                    // Navigator.pop(context);
                                  } else {
                                    // Fluttertoast.showToast(
                                    //     msg: value.data.help_status);
                                    navigateChatScreen(userData.user_id,
                                        peerData.user_id, peerData.name);
                                  }
                                });
                              }
                            }),
                      ),
                      isResponded == true
                          ? Flexible(
                              flex: 1,
                              child: GestureDetector(
                                child: Container(
                                    alignment: Alignment.bottomCenter,
                                    width: SizeConfig.safeBlockHorizontal * 12,
                                    height: SizeConfig.safeBlockHorizontal * 12,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.elliptical(10.0, 10.0)),
                                        color: homeScreenBackgroundColor,
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/map_ic1.png'),
                                            alignment: Alignment.center))),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapScreen(
                                          'MainMediator',
                                          userData.user_id,
                                          peerData.user_id,
                                          peerData.help_id,
                                          peerData.name,
                                          peerData.location_name,
                                          peerData.email),
                                    )),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                )
              : Container(),
          Container(
              margin: EdgeInsets.only(top: 10.0),
              width: MediaQuery.of(context).size.width * 100,
              child: getBackUpMediatorList()),
          FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: EdgeInsets.only(top: 10.0, bottom: 0.0),
            child: Container(
              decoration: BoxDecoration(
                  color: sendButtonColor,
                  borderRadius:
                      BorderRadius.all(Radius.elliptical(15.0, 15.0))),
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(
                  ResponsiveFlutter.of(context).hp(2.0),
                  ResponsiveFlutter.of(context).hp(1.0),
                  ResponsiveFlutter.of(context).hp(2.0),
                  0),
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Text(
                isResponded == true ? Strings.responded : Strings.respond,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: fontStyle,
                    fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),
                textAlign: TextAlign.center,
              ),
            ),
            onPressed: () {
              if (isResponded == false) {
                Utils.showProgressBar(context);

                getUserbloc
                    .getUserForHelpStatus(helpId)
                    .then((UserInformationModel value) {
                  print('nof' + value.toJson().toString());
                  print('nof' + value.data.toJson().toString());

                  Future.delayed(Duration(seconds: 3), () {
                    Utils.dismissProgressBar(context);

                    if (value.data.help_status == 'cancel') {
                      showStaticAlertDialog(context, 'help cancelled by user');
                      // Fluttertoast.showToast(msg: 'help was cancel');
                      // Navigator.pop(context);
                    } else {
                      // Fluttertoast.showToast(
                      //     msg: value.data.help_status);
                      responseUserRequest(peerData);
                    }
                  });
                });

                // responseUserRequest(peerData);

              } else
                showStaticAlertDialog(
                    context, 'You have already responded for this help');

              // Fluttertoast.showToast(
              //       msg: 'You already responded for this help ');
            },
          ),
          FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: Container(
              decoration: BoxDecoration(
                  color: sendButtonColor,
                  borderRadius:
                      BorderRadius.all(Radius.elliptical(15.0, 15.0))),
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(
                  ResponsiveFlutter.of(context).hp(2.0),
                  ResponsiveFlutter.of(context).hp(1.0),
                  ResponsiveFlutter.of(context).hp(2.0),
                  0),
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Text(
                Strings.cancelRequest1,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: fontStyle,
                    fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),
                textAlign: TextAlign.center,
              ),
            ),
            onPressed: () {
              Utils.showProgressBar(context);
              if (!isResponded) {
                CancelHelpRequestClient()
                    .cancelHelpRequest(helpId)
                    .then((value) {
                  if (value == 'Help updated successfully.') {
                    // SaveDataLocal.saveUserStatus('done');
                    if (isResponded) SaveDataLocal.removeData();

                    Utils.dismissProgressBar(context);
                    BackgroundLocation.stopLocationService();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MediatorRegistrationScreen(true, true),
                        ),
                        (route) => false);
                  } else {
                    print('ni' + value.toString());
                    Utils.dismissProgressBar(context);
                    showStaticAlertDialog(
                        context, 'Request already cancelled.');
                  }
                });
              }
              if (isResponded) {
                Utils.showProgressBar(context);

                BackgroundLocation.stopLocationService();
                CancelUserRequest()
                    .cancelUserRequest(helpId.toString(), context)
                    .then((value) {
                  if (value) {
                    if (isResponded) SaveDataLocal.removeData();
                    Utils.dismissProgressBar(context);
                    SaveDataLocal.saveUserStatus('done');

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MediatorRegistrationScreen(true, true),
                        ));
                  } else {
                    Utils.dismissProgressBar(context);
                    showStaticAlertDialog(
                        context, 'Already cancelled this help request.');

                    // Fluttertoast.showToast(
                    //     msg: 'You already cancel this user help request.');
                  }
                });

                // responseUserRequest(peerData);

              }
            },
          ),
        ],
      ),
    );
  }

  Widget mediatorList(Data peerData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(
              ResponsiveFlutter.of(context).hp(3.0),
              ResponsiveFlutter.of(context).hp(0.0),
              ResponsiveFlutter.of(context).hp(3.0),
              0),
          child: Row(
            children: [
              /* notificationType != 'help_request'?GestureDetector(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    width: SizeConfig.safeBlockHorizontal * 12,
                    height: SizeConfig.safeBlockHorizontal * 12,
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.elliptical(10.0, 10.0)),
                      color: sendButtonColor,
                      image: DecorationImage(
                          image: AssetImage('assets/images/chat_ic.png'),
                          alignment: Alignment.center),
                    ),
                  ),
                  onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                peerData.user_id,
                                helpId,
                                userData.user_id,
                                false,
                                false,true),
                          ));
                  }):Container(),*/
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextWidgets().boldTextWidget(
                          homeButtonTextColor,
                          'Mediator',
                          context,
                          ResponsiveFlutter.of(context).fontSize(2.5))),
                  Container(
                    margin: EdgeInsets.only(
                        bottom: ResponsiveFlutter.of(context).hp(3.0)),
                    height: 2.5,
                    decoration: BoxDecoration(
                        color: sendButtonColor,
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(10.0, 10.0))),
                    width: ResponsiveFlutter.of(context).hp(8.0),
                  ),
                ],
              )),
              isResponded == true
                  ? GestureDetector(
                      child: Container(
                          width: SizeConfig.safeBlockHorizontal * 12,
                          height: SizeConfig.safeBlockHorizontal * 12,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(10.0, 10.0)),
                              color: homeScreenBackgroundColor,
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/map_ic1.png'),
                                  alignment: Alignment.center))),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                                'BackUpMediator',
                                userData.user_id,
                                peerData.user_id,
                                peerData.help_id,
                                peerData.name,
                                peerData.location_name,
                                peerData.email),
                          )),
                    )
                  : Container(),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: getBackUpMediatorList()),
        FlatButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          padding: EdgeInsets.only(top: 30.0, bottom: 0.0),
          child: Container(
            decoration: BoxDecoration(
                color: sendButtonColor,
                borderRadius: BorderRadius.all(Radius.elliptical(15.0, 15.0))),
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(
                ResponsiveFlutter.of(context).hp(4.0),
                ResponsiveFlutter.of(context).hp(1.0),
                ResponsiveFlutter.of(context).hp(4.0),
                ResponsiveFlutter.of(context).hp(2.0)),
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Text(
              isResponded == false ? Strings.respond : Strings.responded,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: fontStyle,
                  fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),
              textAlign: TextAlign.center,
            ),
          ),
          onPressed: () {
            if (isResponded == false) {
              if (peerData.help_status != 'cancel') {
                responseMediatorRequest(peerData, request_backup_id);
              } else {
                showStaticAlertDialog(context, 'Help cancelled by user');
                // Fluttertoast.showToast(msg: 'Help cancell by user');
              }
            } else
              showStaticAlertDialog(
                  context, 'You have already response for this help');

            // Fluttertoast.showToast(
            //       msg: 'You already response for this help ');
            // if (_formKey.currentState.validate()) dialog();
          },
        )
      ],
    );
  }

  Widget mediatorListItems(BackUpMediatorListData peerData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          height: ResponsiveFlutter.of(context).hp(14.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                width: ResponsiveFlutter.of(context).hp(10.0),
                height: ResponsiveFlutter.of(context).hp(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: peerData.profile_pic.length == 0
                        ? AssetImage(
                            'assets/images/profile_pic_placeholder.png')
                        : NetworkImage(peerData.profile_pic),
                  ),
                ),
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 20, bottom: 20.0),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidgets().semiBoldTextWidget(
                        Colors.black,
                        peerData.name,
                        context,
                        ResponsiveFlutter.of(context).fontSize(2.0)),
                    TextWidgets().semiBoldTextWidget(labelColor, peerData.email,
                        context, ResponsiveFlutter.of(context).fontSize(2.0)),
                    TextWidgets().semiBoldTextWidget(
                        Colors.black,
                        peerData.phone_no,
                        context,
                        ResponsiveFlutter.of(context).fontSize(2.0))
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.only(left: 20.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 5,
                    child: InkResponse(
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0),
                        padding: EdgeInsets.only(
                            right: 20.0, bottom: 10.0, top: 10.0, left: 20.0),
                        decoration: BoxDecoration(
                            color: trueCallColor,
                            borderRadius: BorderRadius.all(
                                Radius.elliptical(10.0, 10.0))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              image:
                                  AssetImage('assets/images/phone_call_ic.png'),
                            ),
                            Padding(padding: EdgeInsets.only(right: 10.0)),
                            TextWidgets().boldTextWidget(
                                Colors.white,
                                'TRUCE CALL',
                                context,
                                ResponsiveFlutter.of(context).fontSize(2.0))
                          ],
                        ),
                      ),
                      onTap: () =>
                          callAPiCalling(peerData.user_id, peerData.name),
                    ),
                  ),
                  Flexible(
                    flex: 6,
                    child: GestureDetector(
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          width: SizeConfig.safeBlockHorizontal * 12,
                          height: SizeConfig.safeBlockHorizontal * 12,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(10.0, 10.0)),
                            color: sendButtonColor,
                            image: DecorationImage(
                                image: AssetImage('assets/images/chat_ic.png'),
                                alignment: Alignment.center),
                          ),
                        ),
                        onTap: () {
                          if (isResponded)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      peerData.user_id,
                                      helpId,
                                      userData.user_id,
                                      false,
                                      false,
                                      true),
                                ));
                          else {}
                        }),
                  ),
                ]))
      ],
    );
  }

  navigateChatScreen(userId, peerId, peerName) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(peerId, helpId, userData.user_id,
              false, isResponded ? false : true, true),
        ));
  }

  getUserData() async {
    userData = await SaveDataLocal.getUserDataFromLocal();
    isResponded = await SaveDataLocal.getRespondStatus();

    getVoiPPushTokeN();

    print('iofew' + userData.toJson().toString());
  }

  getVoiPPushTokeN() {
    FlutterIOSVoIPKit _voipPush = FlutterIOSVoIPKit();

    _voipPush.getVoIPToken().then((value) {
      print('111lutter Fully Truce VoIP Token' + value.toString());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  responseUserRequest(Data peerData) {
    Utils.showProgressBar(context);
    // Utils.dismissProgressBar(context);
    ResponseUserRequestClient()
        .responseUserRequest(
            helpId, userData.user_id, userData.unique_token, context)
        .then((String successfully) {
      print('Flutter Fully Truce' + successfully);
      if (successfully == 'Mediator assign successfully.') {
        print('Flutter Fully Truce' + successfully);

        SaveDataLocal.saveUserStatus('MediatorPending');
        SaveDataLocal.saveRespondStatus(true);
        // Utils.dismissProgressBar(context);
        SaveDataLocal.saveRespondedMediatorType(
            false, userUserId, helpId, null);

        setState(() {
          isResponded = true;
        });

        Future.delayed(Duration(seconds: 2)).then((value) {
          Utils.dismissProgressBar(context);
          // Navigator.pop(context, (route) => false);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MapScreen(
                      'MainMediator',
                      userData.user_id,
                      peerData.user_id,
                      peerData.help_id,
                      peerData.name,
                      peerData.location_name,
                      peerData.email)));
        });

        // Fluttertoast.showToast(msg: successfully);
      } else {
        Utils.dismissProgressBar(context);
        showStaticAlertDialog(context, successfully);

        // Fluttertoast.showToast(msg: successfully);
      }
    });
  }

  getBackUpMediatorList() {
    getBackUpMediatorBloc.getMediatorList(helpId);
    return StreamBuilder<BackUpMediatorList>(
      stream: getBackUpMediatorBloc.getMediatorListStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print('Flutter Fully Truce' + snapshot.data.toString());

          if (snapshot.data.status == true &&
              snapshot.data.statusCode == 3 &&
              snapshot.data.data.length != 0) {
            backUpMediatorList.clear();
            backUpMediatorList.addAll(snapshot.data.data);

            return Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                width: MediaQuery.of(context).size.width * 100,
                height: 200,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: backUpMediatorList.length,
                    itemBuilder: (context, index) {
                      return Container(
                          margin: EdgeInsets.only(left: 4.0, right: 4.0),
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(20.0, 20.0)),
                              border:
                                  Border.all(color: labelColor, width: 1.0)),
                          child: mediatorListItems(backUpMediatorList[index]));
                    }));
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  /*followUp() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FollowUpScreen(),
        ));
  }*/

  responseMediatorRequest(Data peerData, int requestBackupId) {
    Utils.showProgressBar(context);
    // Utils.dismissProgressBar(context);
    ResponseMediatorRequestClient()
        .responseUserRequest(requestBackupId)
        .then((String successfully) {
      if (successfully == 'Mediator responded successfully.') {
        SaveDataLocal.saveRespondStatus(true);
        SaveDataLocal.saveUserStatus('BackUpMediatorPending');
        // SaveDataLocal.saveRespondStatus(true);

        SaveDataLocal.saveRespondedMediatorType(
            true, userUserId, helpId, request_backup_id);
        setState(() {
          isResponded = true;
        });

        Future.delayed(Duration(seconds: 2)).then((value) {
          Utils.dismissProgressBar(context);
          // Navigator.popUntil(context, (route) => false);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MapScreen(
                      'BackUpMediator',
                      userData.user_id,
                      peerData.user_id,
                      peerData.help_id,
                      peerData.name,
                      '',
                      peerData.email)));
        });

        // Fluttertoast.showToast(msg: successfully);
      } else {
        Utils.dismissProgressBar(context);
        // Fluttertoast.showToast(msg: successfully);
        showStaticAlertDialog(context, successfully);
      }
    }).catchError((onError) {
      Utils.dismissProgressBar(context);
      showStaticAlertDialog(context, onError.toString());
      // Fluttertoast.showToast(msg: onError.toString());
    });
  }

  dialog() {
    return AlertDialog(
      contentPadding: EdgeInsets.only(
          top: ResponsiveFlutter.of(context).hp(2.0),
          bottom: ResponsiveFlutter.of(context).hp(1.0)),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      content: Container(
        width: SizeConfig.safeBlockHorizontal * 100,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/send_graphic_ic.png'),
              Padding(
                padding: EdgeInsets.only(
                    right: ResponsiveFlutter.of(context).hp(1.0),
                    left: ResponsiveFlutter.of(context).hp(1.0),
                    top: ResponsiveFlutter.of(context).hp(1.0)),
                child: Text(
                  Strings.helpDone,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                      fontFamily: fontStyle),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: ResponsiveFlutter.of(context).hp(1.0)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              Navigator.pop(context);
                              confirmationClick();
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  fontFamily: fontStyle,
                                  color: Colors.green,
                                  fontSize: ResponsiveFlutter.of(context)
                                      .fontSize(2.0)),
                            )),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  cancelDialog() {
    return AlertDialog(
      contentPadding: EdgeInsets.only(
          top: ResponsiveFlutter.of(context).hp(2.0),
          bottom: ResponsiveFlutter.of(context).hp(1.0)),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      content: Container(
        width: SizeConfig.safeBlockHorizontal * 100,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/send_graphic_ic.png'),
              Padding(
                padding: EdgeInsets.only(
                    right: ResponsiveFlutter.of(context).hp(1.0),
                    left: ResponsiveFlutter.of(context).hp(1.0),
                    top: ResponsiveFlutter.of(context).hp(1.0)),
                child: Text(
                  Strings.cancelHelp,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                      fontFamily: fontStyle),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: ResponsiveFlutter.of(context).hp(1.0)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              Navigator.pop(context);
                              cancelledClick();
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  fontFamily: fontStyle,
                                  color: Colors.green,
                                  fontSize: ResponsiveFlutter.of(context)
                                      .fontSize(2.0)),
                            )),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  cancelledClick() {
    Navigator.pop(context);
  }

  callAPiCalling(peerId, peerName) async {
    print('inop');
    final channel_name = this.helpId.toString() +
        this.userUserId.toString() +
        DateTime.now().millisecond.toString();
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallingScreen(
            channelName: channel_name,
            peerId: peerId.toString(),
            role: ClientRole.Broadcaster,
            isIncomingCall: false,
            peerName: peerName,
          ),
        ));
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  confirmationClick() {
    SaveDataLocal.removeData();
    SaveDataLocal.saveUserStatus('done');

    BackgroundLocation.stopLocationService();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MediatorRegistrationScreen(true, true),
        ),
        (route) => false);
  }

  navigateScreen(message) {
    // Fluttertoast.showToast(msg: 'user information Screen11');

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
      // Fluttertoast.showToast(msg: 'user information Screen12');

      if (json.decode(message)['notification_type'] == 'chat_notification') {
        // Fluttertoast.showToast(msg: 'user information Screen');
        Navigator.push(
            context,
            MaterialPageRoute(
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
}
