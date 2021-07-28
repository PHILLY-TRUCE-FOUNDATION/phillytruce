import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

Widget homeScreenButton(buttonText, context, image) {
  return Container(
    margin: EdgeInsets.only(
      bottom:ResponsiveFlutter.of(context).hp(1.0) ,
        top: ResponsiveFlutter.of(context).hp(1.0),
        left: ResponsiveFlutter.of(context).hp(2.5),
        right: ResponsiveFlutter.of(context).hp(2.5)),
    height: ResponsiveFlutter.of(context).hp(10.0),
    decoration: BoxDecoration(
        color: whiteColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.elliptical(10.0, 10.0))),
    child: Row(
      children: [
        Padding(
            padding: EdgeInsets.only(
                left: ResponsiveFlutter.of(context).hp(4),
                right: ResponsiveFlutter.of(context).hp(1)),
            child: Image.asset(image)),
        TextWidgets().boldTextWidget(homeButtonTextColor, buttonText, context,
            ResponsiveFlutter.of(context).fontSize(3)),
        Expanded(
            child: Padding(
                padding:
                    EdgeInsets.only(right: ResponsiveFlutter.of(context).hp(3)),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset('assets/images/arrow_right_ic.png'))))
      ],
    ),
  );


}
