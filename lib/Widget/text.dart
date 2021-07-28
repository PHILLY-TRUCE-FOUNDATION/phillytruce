import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/const.dart';

class TextWidgets {


  TextWidgets();

  Widget boldTextWidget(color, text, context, fontSize) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.bold,
        fontFamily: fontStyle,
      ),
    );
  }

  Widget semiBoldTextWidget(color, text, context, fontSize) {
    return Text(
      text,
      maxLines: 1,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w600,
        fontFamily: fontStyle,
      ),
    );
  }
  Widget simpleTextWidget(color, text, context, fontSize) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontFamily: fontStyle,
      ),
    );
  }

}
