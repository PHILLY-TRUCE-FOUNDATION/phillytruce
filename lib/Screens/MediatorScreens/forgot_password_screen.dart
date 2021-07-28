import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Providers/mediator/forgot_password_provider.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/error_widget.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey1 = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      ),
      body: Container(
          width: SizeConfig.safeBlockHorizontal * 100,
          height: SizeConfig.safeBlockVertical * 100,
          decoration: backgroundBoxDecoration,
          child: forgotPassword()),
    );
  }

  Future<bool> onBackPress() {
    // Navigator.pop(context);

    // Navigator.pushAndRemoveUntil(
    //     context, MaterialPageRoute(builder: (context) => HomeScreen(),), (
    //     route) => false);

    Navigator.pop(context);

    return Future.value(false);
  }

  Widget forgotPassword() {
    return Container(
      width: SizeConfig.safeBlockHorizontal * 100,
      height: SizeConfig.safeBlockVertical * 100,
      child: Column(children: [
        new Flexible(
          flex: 2,
          child: Center(
            child: Image.asset('assets/images/send_mail_ic.png'),
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
                      child: Text(
                        'Forgot Your Password?',
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ResponsiveFlutter.of(context).fontSize(2.5),
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontStyle,
                        ),
                      ),
                    ),
                    new Flexible(
                      child: Container(
                        margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Text(
                          'Enter your registered email below to receive password reset instruction',
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:
                                ResponsiveFlutter.of(context).fontSize(2.0),
                            color: labelColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: fontStyle,
                          ),
                        ),
                      ),
                    ),
                    new Flexible(
                      child: Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(
                            ResponsiveFlutter.of(context).hp(2.0),
                            ResponsiveFlutter.of(context).hp(0.0),
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
                          controller: emailController,
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
                    FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      padding: EdgeInsets.only(top: 30.0, bottom: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: sendButtonColor,
                            borderRadius: BorderRadius.all(
                                Radius.elliptical(10.0, 10.0))),
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(
                            ResponsiveFlutter.of(context).hp(2.0),
                            ResponsiveFlutter.of(context).hp(0.0),
                            ResponsiveFlutter.of(context).hp(2.0),
                            0),
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Text(
                          Strings.send,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontStyle,
                              fontSize:
                                  ResponsiveFlutter.of(context).fontSize(2.5)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onPressed: () {
                        if (emailController.text.isNotEmpty)
                          forgotPasswordAPiCalling();
                        else{
                          showStaticAlertDialog(context,'Please Enter Email');
                        }
                      },
                    ),
                    new Flexible(
                      child: InkResponse(
                          child: Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                'Back to Login',
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: ResponsiveFlutter.of(context)
                                      .fontSize(3.0),
                                  color: homeScreenBackgroundColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: fontStyle,
                                ),
                              ),
                            ),
                          ),
                          onTap: () => Navigator.pop(context)),
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

  forgotPasswordAPiCalling() {
    print('bniufen' + emailController.text.trim().toString());
    Utils.showProgressBar(context);
    MediatorForgotPasswordClient()
        .mediatorForgotPassword(emailController.text.trim().toString(), context)
        .then((value) async {
      if (value) {
        Utils.dismissProgressBar(context);
        Navigator.pop(context);
      } else {
        Utils.dismissProgressBar(context);
        Fluttertoast.showToast(msg: 'Email not found');
      }
    });
  }
}
