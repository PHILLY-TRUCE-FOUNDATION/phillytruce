import 'dart:async';
import 'dart:io';

import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/Screens/privacypolicy.dart';
import 'package:flutter_app/Screens/terms_condition.dart';
import 'package:flutter_app/Services/firebase.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/error_widget.dart';
import 'package:flutter_app/Widget/homeScreenButton.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'MediatorScreens/mediator_profile_login.dart';
import 'UsersScreens/final_message_screen.dart';
import 'UsersScreens/registration_screen.dart';

enum ExampleAction { RequestAuthorization, GetSettings }

const privacyPolicy = "https://phillytruce.com/Privacy-policy";
const termCondition = "https://phillytruce.com/Terms&Conditions";

extension on ExampleAction {
  String get title {
    switch (this) {
      case ExampleAction.RequestAuthorization:
        return 'Authorize Notifications';
      case ExampleAction.GetSettings:
        return 'Check Settings';
      default:
        return 'Unknown';
    }
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppLifecycleState notificationState = AppLifecycleState.resumed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0.0,
        toolbarOpacity: 0.0,
        toolbarHeight: 0.0,
        backgroundColor: whiteColor,
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
        child: button(context),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    //
    // _performExampleAction(ExampleAction.RequestAuthorization);
    getPushToken();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<bool> onBackPress(BuildContext context) {
    Navigator.of(context).pop(true);
    return Future.value(false);
  }

  Widget button(context) {
    SizeConfig().init(context);
    return Container(
      height: ResponsiveFlutter.of(context).hp(100),
      decoration: homeBackgroundBoxDecoration,
      child: Column(
        children: [
          new Expanded(
              flex: 1,
              child: Center(
                child: Image.asset('assets/images/philly_truce_text_logo.png'),
              )),
          new Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.only(
                        bottom: ResponsiveFlutter.of(context).hp(5.5)),
                    child: Image.asset('assets/images/shake_hand_logo.png')),
                GestureDetector(
                  child: homeScreenButton(Strings.getHelp, context,
                      'assets/images/get_helap_ic.png'),
                  onTap: () => navigateAddUserScreen(context),
                ),
                GestureDetector(
                  child: homeScreenButton(Strings.mediator, context,
                      'assets/images/become_a_mediator_ic.png'),
                  onTap: () => becomeMediatorButtonClick(context),
                ),

                if (Platform.isAndroid)
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                        bottom: ResponsiveFlutter.of(context).hp(1.0),
                        top: ResponsiveFlutter.of(context).hp(1.0),
                        left: ResponsiveFlutter.of(context).hp(2.5),
                        right: ResponsiveFlutter.of(context).hp(2.5)),
                    child: Center(
                        child: Text.rich(TextSpan(
                            text: 'By continuing, you agree to our ',
                            style: TextStyle(
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(2),
                                color: Colors.white),
                            children: <TextSpan>[
                          TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(2),
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  if (await canLaunch(termCondition))
                                    await launch(termCondition);
                                  else
                                    // can't launch url, there is some error
                                    throw "Could not launch";
                                  // code to open / launch terms of service link here
                                }),
                          TextSpan(
                              text: ' and ',
                              style: TextStyle(
                                  fontSize:
                                      ResponsiveFlutter.of(context).fontSize(2),
                                  color: Colors.white),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                        fontSize: ResponsiveFlutter.of(context)
                                            .fontSize(2),
                                        color: Colors.white,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (await canLaunch(privacyPolicy))
                                          await launch(privacyPolicy);
                                        else
                                          // can't launch url, there is some error
                                          throw "Could not launch";
                                        // code to open / launch terms of service link here
                                      }),
                              ])
                        ]))),
                  )
                // Flexible(
                //   child: Row(
                //     mainAxisSize: MainAxisSize.max,
                //     children: [
                //       GestureDetector(
                //         child: Text('ever'),
                //         onTap: () => Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => PrivacyPolicy(),
                //           ),
                //         ),
                //       ),
                //       GestureDetector(
                //         child: Text('ever'),
                //         onTap: () => Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => TermCondition(),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }

  navigateAddUserScreen(context) async {
    String status = await SaveDataLocal.getUserStatus();

    if (status != 'UserCancel')
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserRegistrationScreen(),
          ));
    else
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinalMessageScreen(),
        ),
      );
  }

  becomeMediatorButtonClick(context) async {
    // navigatorMediatorRespondScreen('help_request', 7, 7, context);
    String status = await SaveDataLocal.getUserStatus();

    if (status == 'UserCancel')
      showStaticAlertDialog(context, 'Your Help is still pending.');
    else
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediatorRegistrationScreen(false, false),
          ));
  }

  // Future<void> displayIncomingCallDelayed(String number) async {
  //   Timer(const Duration(seconds: 3), () {
  //     displayIncomingCall(message);
  //   });
  // }

  getPushToken() {
    PushNotificationsManager().pushToken.then((value) {
      print('Flutter Fully Truce' + value.toString());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('[displayIncomingCall] resumedr');

      setState(() {
        notificationState = AppLifecycleState.resumed;
      });

      // callKeep.backToForeground().then((value) {
      //   Navigator.push(context,MaterialPageRoute(
      //     builder: (context) => CallingScreen(
      //       isIncomingCall: true,
      //       role: ClientRole.Audience,
      //       channelName: '123',
      //     ),
      //   ));
      // });
    }
    if (state == AppLifecycleState.inactive) {
      print('[displayIncomingCall] inactive');
      // callKeep.backToForeground().then((value) {
      //   Navigator.push(context,MaterialPageRoute(
      //     builder: (context) => CallingScreen(
      //       isIncomingCall: true,
      //       role: ClientRole.Audience,
      //       channelName: '123',
      //     ),
      //   ));
      // });
      setState(() {
        notificationState = AppLifecycleState.inactive;
      });
    }
    if (state == AppLifecycleState.detached) {
      print('[displayIncomingCall] detached');
      setState(() {
        notificationState = AppLifecycleState.detached;
      });
      // callKeep.backToForeground().then((value) {
      //   Navigator.push(context,MaterialPageRoute(
      //     builder: (context) => CallingScreen(
      //       isIncomingCall: true,
      //       role: ClientRole.Audience,
      //       channelName: '123',
      //     ),
      //   ));
      // });
    }
  }
}

class Call {
  Call(this.number);

  String number;
  bool held = false;
  bool muted = false;
}
