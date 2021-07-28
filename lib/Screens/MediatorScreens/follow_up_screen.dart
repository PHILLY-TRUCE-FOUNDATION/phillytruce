import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Providers/mediator/give_follow_up_provider.dart';
import 'package:flutter_app/Screens/MediatorScreens/mediator_profile_login.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/error_widget.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class FollowUpScreen extends StatefulWidget {
  final int helpId;

  @override
  _FollowUpScreenState createState() => _FollowUpScreenState(helpId);

  FollowUpScreen(this.helpId);
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  TextEditingController suggestionsController = TextEditingController();

  _FollowUpScreenState(this.helpId);

  int helpId;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: InkResponse(
          onTap: () => onBackPress(),
          child: Image.asset('assets/images/back_ic.png'),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: TextWidgets().boldTextWidget(
            homeButtonTextColor,
            Strings.appName,
            context,
            ResponsiveFlutter.of(context).fontSize(3.0)),
      ),
      body: WillPopScope(
        child: Container(
          padding: EdgeInsets.only(top: ResponsiveFlutter.of(context).hp(10.0)),
          width: SizeConfig.safeBlockHorizontal * 100,
          height: SizeConfig.safeBlockVertical * 100,
          decoration: backgroundBoxDecoration,
          child: followUpMessage(),
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Future<bool> onBackPress() {
    // Utils.showProgressBar(context);

    Navigator.pop(context);

    return Future.value(false);
  }

  Widget followUpMessage() {
    return Card(
      margin: EdgeInsets.only(
          top: ResponsiveFlutter.of(context).hp(2.0),
          bottom: ResponsiveFlutter.of(context).hp(2.0),
          right: ResponsiveFlutter.of(context).hp(2.0),
          left: ResponsiveFlutter.of(context).hp(2.0)),
      elevation: 1.0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.elliptical(
              ResponsiveFlutter.of(context).hp(4.0),
              ResponsiveFlutter.of(context).hp(4.0)))),
      child: Container(
        margin: EdgeInsets.only(
            top: ResponsiveFlutter.of(context).hp(5.0),
            left: ResponsiveFlutter.of(context).hp(2.0),
            right: ResponsiveFlutter.of(context).hp(2.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: ResponsiveFlutter.of(context).hp(2.0),
                  bottom: ResponsiveFlutter.of(context).hp(9.0)),
              child: TextWidgets().semiBoldTextWidget(
                  followUpColor,
                  'Status Report',
                  context,
                  ResponsiveFlutter.of(context).fontSize(3.0)),
              alignment: Alignment.center,
            ),
            TextWidgets().simpleTextWidget(
                labelColor,
                Strings.whatStillNeedToHappen1,
                context,
                ResponsiveFlutter.of(context).fontSize(2.0)),
            TextWidgets().simpleTextWidget(
                labelColor,
                Strings.whatStillNeedToHappen,
                context,
                ResponsiveFlutter.of(context).fontSize(2.0)),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.fromLTRB(
                  ResponsiveFlutter.of(context).hp(0.0),
                  ResponsiveFlutter.of(context).hp(1.0),
                  ResponsiveFlutter.of(context).hp(0.0),
                  0),
              child: TextFormField(
                keyboardType: TextInputType.text,
                maxLines: 5,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                controller: suggestionsController,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter FOLLOW UP';
                  }
                  return null;
                },
                style: TextStyle(
                    fontFamily: fontStyle, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(
                      top: 45.0, bottom: 45.0, left: 15.0, right: 15.0),
                  hintText: Strings.whatStillNeedToHappenHint,
                  isDense: false,
                  alignLabelWithHint: true,
                  hintStyle: TextStyle(
                      fontFamily: fontStyle,
                      color: labelColor,
                      fontWeight: FontWeight.w400),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: labelColor)),
                  border: new OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.0,
                      color: labelColor,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Container(
                decoration: BoxDecoration(
                    color: sendButtonColor,
                    borderRadius:
                        BorderRadius.all(Radius.elliptical(10.0, 10.0))),
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(0.0),
                    ResponsiveFlutter.of(context).hp(5.0),
                    ResponsiveFlutter.of(context).hp(0.0),
                    0),
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Text(
                  Strings.submit,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: fontStyle,
                      fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () {
                if (suggestionsController.text.trim().toString().length != 0)
                  giveFollowUp(helpId);
                else
                  Fluttertoast.showToast(msg: 'Please enter FOLLOW UP');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  giveFollowUp(helpId) {
    Utils.showProgressBar(context);

    GiveFollowUpToUserClient()
        .giveUserFollowUp(helpId, suggestionsController.text.trim().toString())
        .then((value) {
      if (value) {
        BackgroundLocation.stopLocationService();

        Utils.dismissProgressBar(context);
        SaveDataLocal.removeData();

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediatorRegistrationScreen(true, true),
            ));
      } else {
        Utils.dismissProgressBar(context);
        showStaticAlertDialog(context, 'Something went wrong');
        // Fluttertoast.showToast(msg: 'Something wen
        // t wrong');
      }
    });
  }
}
