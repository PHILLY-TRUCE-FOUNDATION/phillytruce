import 'package:flutter/material.dart';
import 'package:flutter_app/Utils/const.dart';

BoxDecoration homeBackgroundBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
  colors: [whiteColor, homeScreenBackgroundColor],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  stops: const <double>[0.2, 1],
));

BoxDecoration backgroundBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
  colors: [whiteColor, homeScreenBackgroundColor],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  stops: const <double>[0.0, 1],
));
