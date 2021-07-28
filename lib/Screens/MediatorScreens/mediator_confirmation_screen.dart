import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class MediatorConfirmationScreen extends StatefulWidget {
  @override
  _MediatorConfirmationScreenState createState() =>
      _MediatorConfirmationScreenState();
}

class _MediatorConfirmationScreenState
    extends State<MediatorConfirmationScreen> {
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
                child:
                      Padding(
                        padding: EdgeInsets.only(bottom: 25.0),
                        child: TextWidgets().boldTextWidget(
                          homeButtonTextColor,
                          Strings.userConfirmationText,
                          context,
                          ResponsiveFlutter.of(context).fontSize(3.0),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
