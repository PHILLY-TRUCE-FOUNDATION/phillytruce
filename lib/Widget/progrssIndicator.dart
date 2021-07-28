import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Utils {
  static bool disable;
  static ProgressDialog pr;

  static progressBar(context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal,
        isDismissible: false,
        showLogs: true,
        textDirection: TextDirection.ltr);
    pr.style(
        message: 'Loading...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: Container(
          padding:
              EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0, left: 10.0),
          child: CircularProgressIndicator(),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
  }

  static showProgressBar(context) async {
    progressBar(context);
    Platform.isAndroid
        ? await pr.show()
        : EasyLoading.show(status: 'loading...');
  }

  static configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = false;
  }

  static dismissAndroid(context) {
    progressBar(context);
    bool isProgressDialogShowing = pr.isShowing();
    print(isProgressDialogShowing);
    if (isProgressDialogShowing) {
      pr.hide();
    }
  }

  static dismissIOS() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss(animation: true);
    }
  }

  static dismissProgressBar(context) {
    progressBar(context);

    Platform.isAndroid ? dismissAndroid(context) : dismissIOS();

    /*  bool isProgressDialogShowing = pr.isShowing();
    print(isProgressDialogShowing);
    if (isProgressDialogShowing) {
      pr.hide();
    }*/
  }
}
