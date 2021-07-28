import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildErrorWidget(String error) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("$error"),
      ],
    ),
  );
}

showStaticAlertDialog(BuildContext context, String message) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  if (Platform.isAndroid) {
    AlertDialog alert = AlertDialog(
      // title: Text("My title"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  if (Platform.isIOS) {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      content: Text(message),
      actions: [
        okButton,
      ],
    );
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }
}
