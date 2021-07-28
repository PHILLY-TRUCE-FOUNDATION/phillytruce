import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

import '../home_screen.dart';

class MediatorFinalMessageScreen extends StatefulWidget {
  @override
  _MediatorFinalMessageScreenState createState() =>
      _MediatorFinalMessageScreenState();
}

class _MediatorFinalMessageScreenState
    extends State<MediatorFinalMessageScreen> {
  int helpId = 1;
  int userId = 1;

  Data userData;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Container(
          width: SizeConfig.safeBlockHorizontal * 100,
          height: SizeConfig.safeBlockVertical * 100,
          decoration: backgroundBoxDecoration,
          child: messageScreen()),
    );
  }

  @override
  void initState() {
    getUserData();
    super.initState();
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
                      ResponsiveFlutter.of(context).hp(4.0),
                      ResponsiveFlutter.of(context).hp(4.0)))),
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
                          ResponsiveFlutter.of(context).fontSize(3.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 25.0),
                        child: TextWidgets().boldTextWidget(
                          homeButtonTextColor,
                          Strings.secondLine,
                          context,
                          ResponsiveFlutter.of(context).fontSize(3.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30.0),
                        child: TextWidgets().boldTextWidget(
                          homeButtonTextColor,
                          Strings.thirdLine,
                          context,
                          ResponsiveFlutter.of(context).fontSize(3.0),
                        ),
                      ),
                      footer(),
                    ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget footer() {
    return FlatButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
            color: sendButtonColor,
            borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0))),
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
              fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),
          textAlign: TextAlign.center,
        ),
      ),
      onPressed: () {
        helpDone();
      },
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

  getUserData() async {
    userData = await SaveDataLocal.getUserDataFromLocal();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
