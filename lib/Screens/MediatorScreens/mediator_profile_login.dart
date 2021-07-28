import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Main/Bloc/Mediator/get_mediator_user.dart';
import 'package:flutter_app/Main/Bloc/Mediator/get_pending_request.dart';
import 'package:flutter_app/Model/pendig_requests_model.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/mediator/logout_provider.dart';
import 'package:flutter_app/Providers/mediator/mediator_login_provider.dart';
import 'package:flutter_app/Screens/MediatorScreens/forgot_password_screen.dart';
import 'package:flutter_app/Screens/MediatorScreens/mediator_details.dart';
import 'package:flutter_app/Screens/MediatorScreens/registran_mediator.dart';
import 'package:flutter_app/Screens/MediatorScreens/user_informaiton_Screen.dart';
import 'package:flutter_app/Services/firebase.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/checkConnection.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/error_widget.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:flutter_ios_voip_kit/flutter_ios_voip_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

import '../home_screen.dart';

class MediatorRegistrationScreen extends StatefulWidget {
  final bool isFromOtherScreen, isFromLastScreen;

  MediatorRegistrationScreen(this.isFromOtherScreen, this.isFromLastScreen);

  @override
  _MediatorRegistrationScreenState createState() =>
      _MediatorRegistrationScreenState(isFromOtherScreen, isFromLastScreen);
}

class _MediatorRegistrationScreenState extends State<MediatorRegistrationScreen>
    with WidgetsBindingObserver {
  _MediatorRegistrationScreenState(
      this.isFromOtherScreen, this.isFromLastScreen);

  bool isFromOtherScreen;
  bool isFromLastScreen;
  bool _loading = false;
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();

  // bool showAppBar = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Data dd;
  String pushDeviceToken;
  String voIPPushDeviceToken;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: WillPopScope(
        child: registrationForm(),
        onWillPop: onBackPress,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // widget is resumed

        getPendingRequestBloc.getRequestDetails();

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

  appBar() {
    return AppBar(
      leading: isFromLastScreen == false
          ? InkResponse(
              onTap: () => onBackPress(),
              child: Image.asset('assets/images/back_ic.png'),
            )
          : dd != null
              ? StreamBuilder(
                  stream: getMediatorUserBloc.subject.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.statusCode == 3) if (snapshot
                              .data.data.is_approve_mediator ==
                          'approve') {
                        return Container(
                          margin: EdgeInsets.only(left: 20.0),
                          child: Row(
                            children: [
                              InkResponse(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MediatorDetails(),
                                    )),
                                child:
                                    Image.asset('assets/images/profile_ic.png'),
                              ),
                            ],
                          ),
                        );
                      } else
                        return Container();
                      else
                        return Container();
                    } else {
                      return Container();
                    }
                  },
                )
              : Container(),
      shadowColor: Colors.transparent,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: dd != null
          ? StreamBuilder<UserInformationModel>(
              stream: getMediatorUserBloc.subject.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.statusCode == 3)
                    return snapshot.data.data.is_approve_mediator == 'approve'
                        ? TextWidgets().boldTextWidget(
                            homeButtonTextColor,
                            Strings.appName,
                            context,
                            ResponsiveFlutter.of(context).fontSize(3.0))
                        : Container();
                  else
                    return buildErrorWidget(snapshot.data.message.toString());
                } else {
                  return Container();
                }
              },
            )
          : Container(),
      actions: [
        if (dd != null)
          StreamBuilder(
            stream: getMediatorUserBloc.subject.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.statusCode == 3) if (snapshot
                        .data.data.is_approve_mediator ==
                    'approve') {
                  return Container(
                    margin:
                        EdgeInsets.only(right: 15.0, top: 10.0, bottom: 10.0),
                    decoration: BoxDecoration(
                        color: sendButtonColor,
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(10.0, 10.0))),
                    child: Row(
                      children: [
                        FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(5.0, 5.0))),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          color: sendButtonColor,
                          onPressed: () => mediatorLogOut(),
                          child: Text(
                            'Logout',
                            style: TextStyle(
                                color: Colors.black, fontFamily: fontStyle),
                          ),
                        ),
                      ],
                    ),
                  );
                } else
                  return Container();
                else
                  return Container();
              } else {
                return Container();
              }
            },
          )
      ],
    );
  }

  Future<bool> onBackPress() {
    // Navigator.pop(context);

    // Navigator.pushAndRemoveUntil(
    //     context, MaterialPageRoute(builder: (context) => HomeScreen(),), (
    //     route) => false);

    if (isFromLastScreen) {
      SystemNavigator.pop();
    } else if (isFromOtherScreen) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
          (route) => false);
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    getPushToken();
    if (Platform.isIOS) getVoiPPushTokeN();

    SaveDataLocal.getUserDataFromLocal().then((value) {
      setState(() {
        if (value != false) {
          if (value.user_type == 'mediator') dd = value;
        }
      });
    });

    _loading = false;

    super.initState();
  }

  getPushToken() {
    PushNotificationsManager().pushToken.then((value) {
      print('Flutter Fully Truce' + value.toString());
      setState(() {
        pushDeviceToken = value;
      });
    });
  }

  getVoiPPushTokeN() {
    FlutterIOSVoIPKit _voipPush = FlutterIOSVoIPKit();

    _voipPush.getVoIPToken().then((value) {
      print('Flutter Fully Truce VoIP Token' + value.toString());
      setState(() {
        voIPPushDeviceToken = value;
      });
    });
  }

  Widget registrationForm() {
    if (dd != null) {
      if (dd.user_id != null) getMediatorUserBloc.getMediatorDetails();
    }

    return dd != null
        ? _loading
            ? Container(
                width: SizeConfig.safeBlockHorizontal * 100,
                height: SizeConfig.safeBlockVertical * 100,
                decoration: backgroundBoxDecoration,
                child: Card(
                    margin:
                        EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
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
                    )))
            : StreamBuilder<UserInformationModel>(
                stream: getMediatorUserBloc.subject.stream,
                builder:
                    (context, AsyncSnapshot<UserInformationModel> snapshot) {
                  if (snapshot.hasData) {
                    SaveDataLocal.saveUserData(snapshot.data);
                    print('ewfiwf' + 'ogregni');
                    // print(snapshot.data.toJson().toString());
                    if (snapshot.data.statusCode == 3) {
                      return snapshot.data.data.is_approve_mediator == 'pending'
                          ? Container(
                              width: SizeConfig.safeBlockHorizontal * 100,
                              height: SizeConfig.safeBlockVertical * 100,
                              decoration: backgroundBoxDecoration,
                              child: messageScreen())
                          : snapshot.data.data.is_approve_mediator == 'approve'
                              ? Container(
                                  width: SizeConfig.safeBlockHorizontal * 100,
                                  height: SizeConfig.safeBlockVertical * 100,
                                  decoration: backgroundBoxDecoration,
                                  child: Card(
                                      margin: EdgeInsets.all(
                                          ResponsiveFlutter.of(context)
                                              .hp(2.0)),
                                      elevation: 1.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.elliptical(
                                                  ResponsiveFlutter.of(context)
                                                      .hp(2.0),
                                                  ResponsiveFlutter.of(context)
                                                      .hp(2.0)))),
                                      child: Form(
                                          child: Center(
                                              child: pendingRequestList()))))
                              : Platform.isAndroid
                                  ? Center(child: CircularProgressIndicator())
                                  : Center(child: CupertinoActivityIndicator());
                    } else if (snapshot.data.statusCode == 101) {
                      // Fluttertoast.showToast(msg: 'Authentication Failed');
                      SaveDataLocal.removeUserData();
                      SaveDataLocal.removeData();
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.pop(context);
                      });
                      return Container(
                          width: SizeConfig.safeBlockHorizontal * 100,
                          height: SizeConfig.safeBlockVertical * 100,
                          decoration: backgroundBoxDecoration,
                          child: loginForm());
                    } else {
                      return Container(
                        width: SizeConfig.safeBlockHorizontal * 100,
                        height: SizeConfig.safeBlockVertical * 100,
                        decoration: backgroundBoxDecoration,
                        child: Card(
                          margin: EdgeInsets.all(
                              ResponsiveFlutter.of(context).hp(2.0)),
                          elevation: 1.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.elliptical(
                                  ResponsiveFlutter.of(context).hp(2.0),
                                  ResponsiveFlutter.of(context).hp(2.0)))),
                          child: buildErrorWidget(
                              snapshot.data.message.trim().toString()),
                        ),
                      );
                    }
                  } else if (snapshot.hasError &&
                      snapshot.connectionState == ConnectionState.done)
                    return Container(
                      width: SizeConfig.safeBlockHorizontal * 100,
                      height: SizeConfig.safeBlockVertical * 100,
                      decoration: backgroundBoxDecoration,
                      child: Card(
                        margin: EdgeInsets.all(
                            ResponsiveFlutter.of(context).hp(2.0)),
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(
                              ResponsiveFlutter.of(context).hp(2.0),
                              ResponsiveFlutter.of(context).hp(2.0),
                            ),
                          ),
                        ),
                        child: Center(
                          child: TextWidgets().semiBoldTextWidget(
                              Colors.black,
                              'Something went wrong',
                              context,
                              ResponsiveFlutter.of(context).fontSize(2.0)),
                        ),
                      ),
                    );
                  else
                    return Container(
                      width: SizeConfig.safeBlockHorizontal * 100,
                      height: SizeConfig.safeBlockVertical * 100,
                      decoration: backgroundBoxDecoration,
                      child: Card(
                        margin: EdgeInsets.all(
                            ResponsiveFlutter.of(context).hp(2.0)),
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(
                              ResponsiveFlutter.of(context).hp(2.0),
                              ResponsiveFlutter.of(context).hp(2.0),
                            ),
                          ),
                        ),
                        child: Platform.isAndroid
                            ? Center(child: CircularProgressIndicator())
                            : Center(
                                child: Container(
                                  child: CupertinoActivityIndicator(),
                                ),
                              ),
                      ),
                    );
                  /*if (snapshot.hasData)
                  return Center(child: showMediatorData(snapshot.data));
                  else
                  return Platform.isAndroid
                  ? Center(child: CircularProgressIndicator())
                      : Center(child: CupertinoActivityIndicator()
                  );*/
                })
        : loginForm();
    // return FutureBuilder(
    //   future: SaveDataLocal.getUserDataFromLocal(),
    //   builder: (context, AsyncSnapshot snapshot) {
    //     print('snapshotdata ' + snapshot.data.toString());
    //     if (!snapshot.hasData || snapshot.data.user_type == 'user') {
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => MediatorLogIn(),
    //             ));
    //       });
    //       return Container(
    //           width: SizeConfig.safeBlockHorizontal * 100,
    //           height: SizeConfig.safeBlockVertical * 100,
    //           decoration: backgroundBoxDecoration,
    //           child: Container());
    //     } else if (snapshot.hasError) {
    //       return Container(
    //         width: SizeConfig.safeBlockHorizontal * 100,
    //         height: SizeConfig.safeBlockVertical * 100,
    //         decoration: backgroundBoxDecoration,
    //         child: Card(
    //           margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
    //           elevation: 1.0,
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(
    //               Radius.elliptical(
    //                 ResponsiveFlutter.of(context).hp(2.0),
    //                 ResponsiveFlutter.of(context).hp(2.0),
    //               ),
    //             ),
    //           ),
    //           child: Platform.isAndroid
    //               ? Center(child: CircularProgressIndicator())
    //               : Center(
    //             child: Container(
    //               child: CupertinoActivityIndicator(),
    //             ),
    //           ),
    //         ),
    //       );
    //     } else {
    //       getMediatorUserBloc.getMediatorDetails();
    //       return _loading
    //           ? Container(
    //           width: SizeConfig.safeBlockHorizontal * 100,
    //           height: SizeConfig.safeBlockVertical * 100,
    //           decoration: backgroundBoxDecoration,
    //           child: Card(
    //               margin:
    //               EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
    //               elevation: 1.0,
    //               shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.all(Radius.elliptical(
    //                       ResponsiveFlutter.of(context).hp(2.0),
    //                       ResponsiveFlutter.of(context).hp(2.0)))),
    //               child: Container(
    //                 margin: EdgeInsets.all(0.0),
    //                 width: SizeConfig.safeBlockHorizontal * 100,
    //                 height: SizeConfig.safeBlockVertical * 100,
    //                 child: Center(
    //                   child: Platform.isAndroid
    //                       ? CircularProgressIndicator()
    //                       : CupertinoActivityIndicator(),
    //                 ),
    //               )))
    //           : StreamBuilder<UserInformationModel>(
    //           stream: getMediatorUserBloc.subject.stream,
    //           builder:
    //               (context, AsyncSnapshot<UserInformationModel> snapshot) {
    //             if (snapshot.hasData) {
    //               SaveDataLocal.saveUserData(snapshot.data);
    //               // print(snapshot.data.toJson().toString());
    //               if (snapshot.data.statusCode == 3) {
    //                 return snapshot.data.data.is_approve_mediator ==
    //                     'pending'
    //                     ? Container(
    //                     width: SizeConfig.safeBlockHorizontal * 100,
    //                     height: SizeConfig.safeBlockVertical * 100,
    //                     decoration: backgroundBoxDecoration,
    //                     child: messageScreen())
    //                     : snapshot.data.data.is_approve_mediator ==
    //                     'approve'
    //                     ? Container(
    //                     width: SizeConfig.safeBlockHorizontal * 100,
    //                     height: SizeConfig.safeBlockVertical * 100,
    //                     decoration: backgroundBoxDecoration,
    //                     child: Card(
    //                         margin: EdgeInsets.all(
    //                             ResponsiveFlutter.of(context)
    //                                 .hp(2.0)),
    //                         elevation: 1.0,
    //                         shape: RoundedRectangleBorder(
    //                             borderRadius: BorderRadius.all(
    //                                 Radius.elliptical(
    //                                     ResponsiveFlutter.of(context)
    //                                         .hp(2.0),
    //                                     ResponsiveFlutter.of(context)
    //                                         .hp(2.0)))),
    //                         child: Form(
    //                             child: Center(
    //                                 child: pendingRequestList()))))
    //                     : Platform.isAndroid
    //                     ? Center(child: CircularProgressIndicator())
    //                     : Center(child: CupertinoActivityIndicator());
    //               } else if (snapshot.data.statusCode == 101) {
    //                 // Fluttertoast.showToast(msg: 'Authentication Failed');
    //                 return Container(
    //                     width: SizeConfig.safeBlockHorizontal * 100,
    //                     height: SizeConfig.safeBlockVertical * 100,
    //                     decoration: backgroundBoxDecoration,
    //                     child: Container());
    //               } else {
    //                 return Container(
    //                   width: SizeConfig.safeBlockHorizontal * 100,
    //                   height: SizeConfig.safeBlockVertical * 100,
    //                   decoration: backgroundBoxDecoration,
    //                   child: Card(
    //                     margin: EdgeInsets.all(
    //                         ResponsiveFlutter.of(context).hp(2.0)),
    //                     elevation: 1.0,
    //                     shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.all(
    //                             Radius.elliptical(
    //                                 ResponsiveFlutter.of(context).hp(2.0),
    //                                 ResponsiveFlutter.of(context)
    //                                     .hp(2.0)))),
    //                     child: buildErrorWidget(
    //                         snapshot.data.message.trim().toString()),
    //                   ),
    //                 );
    //               }
    //             } else if (snapshot.hasError &&
    //                 snapshot.connectionState == ConnectionState.done)
    //               return Container(
    //                 width: SizeConfig.safeBlockHorizontal * 100,
    //                 height: SizeConfig.safeBlockVertical * 100,
    //                 decoration: backgroundBoxDecoration,
    //                 child: Card(
    //                   margin: EdgeInsets.all(
    //                       ResponsiveFlutter.of(context).hp(2.0)),
    //                   elevation: 1.0,
    //                   shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.all(
    //                       Radius.elliptical(
    //                         ResponsiveFlutter.of(context).hp(2.0),
    //                         ResponsiveFlutter.of(context).hp(2.0),
    //                       ),
    //                     ),
    //                   ),
    //                   child: Center(
    //                     child: TextWidgets().semiBoldTextWidget(
    //                         Colors.black,
    //                         'Something went wrong',
    //                         context,
    //                         ResponsiveFlutter.of(context).fontSize(2.0)),
    //                   ),
    //                 ),
    //               );
    //             else
    //               return Container(
    //                 width: SizeConfig.safeBlockHorizontal * 100,
    //                 height: SizeConfig.safeBlockVertical * 100,
    //                 decoration: backgroundBoxDecoration,
    //                 child: Card(
    //                   margin: EdgeInsets.all(
    //                       ResponsiveFlutter.of(context).hp(2.0)),
    //                   elevation: 1.0,
    //                   shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.all(
    //                       Radius.elliptical(
    //                         ResponsiveFlutter.of(context).hp(2.0),
    //                         ResponsiveFlutter.of(context).hp(2.0),
    //                       ),
    //                     ),
    //                   ),
    //                   child: Platform.isAndroid
    //                       ? Center(child: CircularProgressIndicator())
    //                       : Center(
    //                     child: Container(
    //                       child: CupertinoActivityIndicator(),
    //                     ),
    //                   ),
    //                 ),
    //               );
    //             /*if (snapshot.hasData)
    //               return Center(child: showMediatorData(snapshot.data));
    //               else
    //               return Platform.isAndroid
    //               ? Center(child: CircularProgressIndicator())
    //                   : Center(child: CupertinoActivityIndicator()
    //               );*/
    //           });
    //       /* return Container(
    //           width: SizeConfig.safeBlockHorizontal * 100,
    //           height: SizeConfig.safeBlockVertical * 100,
    //           decoration: backgroundBoxDecoration,
    //           child: Card(
    //           margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
    //     elevation: 1.0,
    //     shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.all(Radius.elliptical(
    //     ResponsiveFlutter.of(context).hp(2.0),
    //     ResponsiveFlutter.of(context).hp(2.0)))),
    //     child:pendingRequestList(),),);*/
    //     }
    //   },
    // );
  }

  Widget loginForm() {
    return Container(
      decoration: backgroundBoxDecoration,
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
          child: Container(
            margin: EdgeInsets.all(0.0),
            width: SizeConfig.safeBlockHorizontal * 100,
            child: Card(
              margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.elliptical(
                      ResponsiveFlutter.of(context).hp(2.0),
                      ResponsiveFlutter.of(context).hp(2.0)))),
              child: Form(
                key: _formKey1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new Flexible(
                      child: Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(
                            ResponsiveFlutter.of(context).hp(2.0),
                            ResponsiveFlutter.of(context).hp(1.0),
                            ResponsiveFlutter.of(context).hp(2.0),
                            0),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter your email address';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.sentences,
                          controller: loginEmailController,
                          style: TextStyle(
                              fontFamily: fontStyle,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: Strings.email,
                            hintText: Strings.enterEmail,
                            hintStyle: TextStyle(
                                fontFamily: fontStyle,
                                color: labelColor,
                                fontWeight: FontWeight.w400),
                            labelStyle: TextStyle(
                                fontFamily: fontStyle,
                                color: labelColor,
                                fontWeight: FontWeight.w400),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: labelColor)),
                            border: new UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: labelColor,
                                style: BorderStyle.solid,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ),
                    new Flexible(
                      child: Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(
                            ResponsiveFlutter.of(context).hp(2.0),
                            ResponsiveFlutter.of(context).hp(1.0),
                            ResponsiveFlutter.of(context).hp(2.0),
                            0),
                        child: TextFormField(
                          obscureText: true,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter your password';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.sentences,
                          controller: loginPasswordController,
                          style: TextStyle(
                              fontFamily: fontStyle,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: Strings.password,
                            labelStyle: TextStyle(
                                fontFamily: fontStyle,
                                color: labelColor,
                                fontWeight: FontWeight.w400),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: labelColor)),
                            border: new UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: labelColor,
                                style: BorderStyle.solid,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ),
                    ),
                    new Flexible(
                      child: FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
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
                            Strings.logIn,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: fontStyle,
                                fontSize: ResponsiveFlutter.of(context)
                                    .fontSize(2.5)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onPressed: () {
                          if (loginEmailController.text.isEmpty) {
                            showStaticAlertDialog(
                                context, 'Please Enter Email');
                          } else if (loginPasswordController.text.isEmpty) {
                            showStaticAlertDialog(
                                context, 'Please Enter Password');
                          } else {
                            connectivityCheck().then((intenet) => {
                                  if (intenet != null && intenet)
                                    {mediatorLogIn()}
                                  else
                                    {
                                      showStaticAlertDialog(context,
                                          'Internet not available, check your internet connectivity and try again')
                                    }
                                });
                          }
                        },
                      ),
                    ),
                    new Flexible(
                      child: InkResponse(
                        child: Text(
                          'Forgot Password?',
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize:
                                ResponsiveFlutter.of(context).fontSize(2.0),
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: fontStyle,
                          ),
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPassword(),
                            )),
                      ),
                    ),
                    new Flexible(
                      child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          child: InkResponse(
                            child: Text(
                              'Become a Mediator',
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(3.0),
                                color: homeScreenBackgroundColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: fontStyle,
                              ),
                            ),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MediatorRegistration(),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  mediatorLogIn() {
    MediatorLogInClient()
        .mediatorLogIn(
            'mediator',
            loginEmailController.text.trim().toString(),
            loginPasswordController.text.trim().toString(),
            Platform.isAndroid ? 'android' : 'ios',
            pushDeviceToken,
            Platform.isAndroid ? "" : voIPPushDeviceToken,
            context)
        .then((UserInformationModel value) async {
      if (value.statusCode == 3) {
        Utils.dismissProgressBar(context);
        SaveDataLocal.saveUserData(value);

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediatorRegistrationScreen(true, true),
            ));
      } else {
        Utils.dismissProgressBar(context);
        Fluttertoast.showToast(msg: value.message.trim().toString());
      }
    });
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
            child: Container(
              margin: EdgeInsets.all(0.0),
              width: SizeConfig.safeBlockHorizontal * 100,
              child: Card(
                  margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.elliptical(
                          ResponsiveFlutter.of(context).hp(2.0),
                          ResponsiveFlutter.of(context).hp(2.0)))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(25.0),
                            child: Text(
                              Strings.userConfirmationText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: fontStyle,
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(3.0),
                                color: homeButtonTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FlatButton(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          clipBehavior: Clip.hardEdge,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                                color: sendButtonColor,
                                borderRadius: BorderRadius.all(
                                    Radius.elliptical(15.0, 15.0))),
                            alignment: Alignment.bottomCenter,
                            margin: EdgeInsets.fromLTRB(
                                ResponsiveFlutter.of(context).hp(2.0),
                                ResponsiveFlutter.of(context).hp(1.0),
                                ResponsiveFlutter.of(context).hp(2.0),
                                0),
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            child: Text(
                              Strings.goBackToHome,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: fontStyle,
                                  fontSize: ResponsiveFlutter.of(context)
                                      .fontSize(2.0)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onPressed: () {
                            // Navigator.pushAndRemoveUntil(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => HomeScreen(),
                            //     ),
                            //         (route) => false);
                            Navigator.pop(context);
                            // if (_formKey.currentState.validate()) dialog();
                          },
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ]));
  }

  // _getAddressFromLatLng() async {
  //   try {
  //     List<Placemark> p = await geolocator.placemarkFromCoordinates(
  //         currentPosition.latitude, currentPosition.longitude);
  //     Placemark place = p[0];
  //     location.text =
  //         "${place.name},${place.subThoroughfare},${place.subLocality},${place.locality}, ${place.postalCode}, ${place.country} ";
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Widget pendingRequestList() {
    // showAppBar = true;
    SizeConfig().init(context);
    getPendingRequestBloc.getRequestDetails();

    isFromLastScreen = true;

    return Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0),
        child: StreamBuilder<GetPendingRequestsModel>(
          stream: getPendingRequestBloc.subject.stream,
          builder: (context, AsyncSnapshot<GetPendingRequestsModel> snapshot) {
            if (snapshot.hasData && snapshot.data.status == true) {
              if (snapshot.data.statusCode == 3) {
                if (snapshot.data.data.isEmpty)
                  return noRequestFound();
                else
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TextWidgets().semiBoldTextWidget(labelColor, Strings.pendingRequest,
                      //     context, ResponsiveFlutter.of(context).fontSize(2.0)),
                      Container(
                        padding: EdgeInsets.all(13.0),
                        width: SizeConfig.safeBlockHorizontal * 100,
                        child: TextWidgets().semiBoldTextWidget(
                            labelColor,
                            Strings.pendingRequest,
                            context,
                            ResponsiveFlutter.of(context).fontSize(2.0)),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  style: BorderStyle.solid,
                                  color: Color(0xffA5A5A5),
                                  width: 0.5)),
                        ),
                      ),
                      Flexible(
                          child: ListView.builder(
                        itemCount: snapshot.data.data.length,
                        itemBuilder: (context, index) {
                          return requestPendingListItems(
                              snapshot.data.data[index]);
                        },
                      )),
                    ],
                  );
              } else {
                return Container(
                  child: Center(
                    child: buildErrorWidget(
                        snapshot.data.message.trim().toString()),
                  ),
                );
              }
            } else {
              return Container(
                child: Center(
                  child: Platform.isAndroid
                      ? CircularProgressIndicator()
                      : CupertinoActivityIndicator(),
                ),
              );
            }
          },
        ));
  }

  Widget noRequestFound() {
    return Container(
      margin: EdgeInsets.only(left: 35.0, right: 35.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/not_request_graphic.png'),
            Text(
              'Nothing to see here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: fontStyle,
                  fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),
            ),
            Text(
              'There are no requests right now.',
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: labelColor,
                  fontFamily: fontStyle,
                  fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),
            ),
          ],
        ),
      ),
    );
  }

  String getCharacters(String peerName) {
    List<String> list = List();
    print('niufw' + peerName);

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

  Widget requestPendingListItems(PendingRequestData getPendingRequests) {
    return InkResponse(
        child: Container(
          alignment: Alignment.topLeft,
          height: ResponsiveFlutter.of(context).hp(14.0),
          child: Row(
            children: [
              Container(
                width: SizeConfig.safeBlockHorizontal * 16,
                height: SizeConfig.safeBlockVertical * 11,
                margin: EdgeInsets.only(right: 10.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Card(
                      margin: EdgeInsets.only(top: 8.0, bottom: 6.0),
                      child: Container(),
                      color: sendButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.elliptical(
                              ResponsiveFlutter.of(context).hp(3.0),
                              ResponsiveFlutter.of(context).hp(3.0)))),
                    ),
                    Text(
                      getCharacters(getPendingRequests.name).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: fontStyle,
                          color: Colors.white,
                          fontSize:
                              ResponsiveFlutter.of(context).fontSize(3.5)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        getPendingRequests.name.trim().toString().length != 0
                            ? TextWidgets().semiBoldTextWidget(
                                Colors.black,
                                getPendingRequests.name,
                                context,
                                ResponsiveFlutter.of(context).fontSize(2.0))
                            : Container(),
                        getPendingRequests.request_type == 'help_request'
                            ? TextWidgets().semiBoldTextWidget(
                                needHelp,
                                ' Need help',
                                context,
                                ResponsiveFlutter.of(context).fontSize(2.0))
                            : TextWidgets().semiBoldTextWidget(
                                wantHelp,
                                ' Wants help',
                                context,
                                ResponsiveFlutter.of(context).fontSize(2.0)),
                      ],
                    ),
                    getPendingRequests.email.trim().toString().length != 0
                        ? TextWidgets().semiBoldTextWidget(
                            labelColor,
                            getPendingRequests.email,
                            context,
                            ResponsiveFlutter.of(context).fontSize(2.0))
                        : Container(),
                    getPendingRequests.phone_no.trim().toString().length != 0
                        ? TextWidgets().semiBoldTextWidget(
                            Colors.black,
                            getPendingRequests.phone_no,
                            context,
                            ResponsiveFlutter.of(context).fontSize(2.0))
                        : Container()
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Align(
                    child: Image.asset('assets/images/right_arrow_ic.png'),
                    alignment: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    style: BorderStyle.solid, color: labelColor, width: 0.5)),
          ),
        ),
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserInformation(
                    getPendingRequests.request_type,
                    getPendingRequests.help_id,
                    getPendingRequests.user_id,
                    getPendingRequests.request_type == 'help_request'
                        ? 0
                        : int.parse(
                            getPendingRequests.request_backup_id.toString()),
                    false),
              ),
            ));
  }

  mediatorLogOut() {
    Utils.showProgressBar(context);
    MediatorLogOutClient().mediatorLogOut().then((bool value) async {
      if (value) {
        Utils.dismissProgressBar(context);
        SaveDataLocal.removeUserData();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
            (route) => false);
      } else {
        Utils.dismissProgressBar(context);
        Fluttertoast.showToast(msg: 'Something went wrong Please Try again');
      }
    });
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
