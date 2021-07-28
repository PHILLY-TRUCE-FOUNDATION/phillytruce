import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Main/Bloc/Mediator/get_mediator_user.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/error_widget.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class MediatorDetails extends StatefulWidget {
  @override
  _MediatorDetailsState createState() => _MediatorDetailsState();
}

class _MediatorDetailsState extends State<MediatorDetails> {
  @override
  Widget build(BuildContext context) {
    getMediatorUserBloc.getMediatorDetails();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkResponse(
          onTap: () => onBackPress(),
          child: Image.asset('assets/images/back_ic.png'),
        ),
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
      body: StreamBuilder<UserInformationModel>(
          stream: getMediatorUserBloc.subject.stream,
          builder: (context, AsyncSnapshot<UserInformationModel> snapshot) {
            if (snapshot.hasData) {
              // SaveDataLocal.saveUserData(snapshot.data);
              if (snapshot.data.statusCode == 3) {
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
                        child: Form(
                            child: Center(
                                child: showMediatorData(snapshot.data)))));
              } else {
                return Container(
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
                    child: Form(
                      child: buildErrorWidget(snapshot.data.message),
                    ),
                  ),
                );
              }
            } else if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done)
              return Container(
                width: SizeConfig.safeBlockHorizontal * 100,
                height: SizeConfig.safeBlockVertical * 100,
                decoration: backgroundBoxDecoration,
                child: Card(
                  margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
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
                  margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
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
          }),
    );
  }

  Widget showMediatorData(UserInformationModel snapshot) {

    print(snapshot.data.toJson().toString());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              snapshot.data.profile_pic.toString().length != 0
                  ? Container(
                      clipBehavior: Clip.hardEdge,
                      margin: EdgeInsets.only(bottom: 5),
                      width: ResponsiveFlutter.of(context).hp(20.0),
                      height: ResponsiveFlutter.of(context).hp(20.0),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(30.0, 30.0)),
                        image: DecorationImage(
                            image: NetworkImage(
                              snapshot.data.profile_pic,
                            ),
                            fit: BoxFit.cover),
                        // image: DecorationImage(fit: BoxFit.fill),
                      ),
                    )
                  : Container(
                      clipBehavior: Clip.hardEdge,
                      margin: EdgeInsets.only(bottom: 5),
                      width: ResponsiveFlutter.of(context).hp(20.0),
                      height: ResponsiveFlutter.of(context).hp(20.0),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(30.0, 30.0)),

                        // image: DecorationImage(fit: BoxFit.fill),
                      ),
                      child: Center(
                        child: Platform.isAndroid
                            ? CircularProgressIndicator()
                            : CupertinoActivityIndicator(),
                      ),
                    ),
              Container(
                child: TextWidgets().boldTextWidget(
                    Colors.black,
                    snapshot.data.name,
                    context,
                    ResponsiveFlutter.of(context).fontSize(2.5)),
              )
            ],
          ),
          Container(
            margin:
                EdgeInsets.only(bottom: ResponsiveFlutter.of(context).hp(3.0)),
            height: 2.5,
            decoration: BoxDecoration(
                color: sendButtonColor,
                borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0))),
            width: ResponsiveFlutter.of(context).hp(8.0),
          ),
          Container(
            width: SizeConfig.safeBlockHorizontal * 100,
            margin: EdgeInsets.fromLTRB(
                ResponsiveFlutter.of(context).hp(3.0),
                ResponsiveFlutter.of(context).hp(1.0),
                ResponsiveFlutter.of(context).hp(3.0),
                0),
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                color: labelColor,
                width: 1.5,
              ),
            )),
            child: Column(
              children: [
                TextWidgets().simpleTextWidget(labelColor, 'Mobile Number',
                    context, ResponsiveFlutter.of(context).fontSize(2.0)),
                Padding(
                    padding: EdgeInsets.only(bottom: 13.0, top: 3.0),
                    child: TextWidgets().semiBoldTextWidget(
                        Colors.black,
                        snapshot.data.phone_no,
                        context,
                        ResponsiveFlutter.of(context).fontSize(2.0))),
              ],
            ),
          ),
          Container(
            width: SizeConfig.safeBlockHorizontal * 100,
            margin: EdgeInsets.fromLTRB(
                ResponsiveFlutter.of(context).hp(3.0),
                ResponsiveFlutter.of(context).hp(2.5),
                ResponsiveFlutter.of(context).hp(3.0),
                0),
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                style: BorderStyle.solid,
                color: labelColor,
                width: 1.5,
              ),
            )),
            child: Column(
              children: [
                TextWidgets().simpleTextWidget(labelColor, 'Email', context,
                    ResponsiveFlutter.of(context).fontSize(2.0)),
                Padding(
                    padding: EdgeInsets.only(bottom: 13.0, top: 3.0),
                    child: TextWidgets().semiBoldTextWidget(
                        Colors.black,
                        snapshot.data.email,
                        context,
                        ResponsiveFlutter.of(context).fontSize(2.0))),
              ],
            ),
          ),
          Container(
            width: SizeConfig.safeBlockHorizontal * 100,
            margin: EdgeInsets.fromLTRB(
                ResponsiveFlutter.of(context).hp(3.0),
                ResponsiveFlutter.of(context).hp(2.5),
                ResponsiveFlutter.of(context).hp(3.0),
                0),
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                style: BorderStyle.solid,
                color: labelColor,
                width: 1.5,
              ),
            )),
            child: Column(
              children: [
                TextWidgets().simpleTextWidget(labelColor, 'Location', context,
                    ResponsiveFlutter.of(context).fontSize(2.0)),
                Padding(
                    padding: EdgeInsets.only(bottom: 13.0),
                    child: Text(
                      snapshot.data.location_name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                        fontFamily: fontStyle,
                        color: Colors.black,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);

    return Future.value(false);
  }
}
