
import 'package:flutter/material.dart';
///颜色
class AppColors {
  static const String primaryValueString = "#000DFF";
  static const String primaryLightValueString = "#0010FD";
  static const String primaryDarkValueString = "#2E39FF";

  static const int primaryTransparent = 0x00000000;
//  static const int primaryValue = 0xFF24292E;
//  static const int primaryLightValue = 0xFF42464b;
//  static const int primaryDarkValue = 0xFF121917;
  static const int primaryValue = 0xFF000DFF;
  static const int primaryLightValue = 0xFF0010FD;
  static const int primaryDarkValue = 0xFF2E39FF;

  static const int btnColor = 0xFFFFC914;
  static const int textColor = 0xFF464646;
  static const int priceColor = 0xFFFB2289;
  static const int subTextColor = 0xFF959595;
  static const int hintTextColor = 0xFFD0D0D0;
  static const int subLightTextColor = 0xffc4c4c4;
  static const int miWhite = 0xffececec;
  static const int white = 0xFFFFFFFF;
  static const int actionBlue = 0xff267aff;

  static const int mainBackgroundColor = miWhite;

  static const int mainTextColor = primaryDarkValue;
  static const int textColorWhite = white;

  static const MaterialColor primarySwatch = const MaterialColor(
    primaryValue,
    const <int, Color>{
      0: const Color(primaryTransparent),
      50: const Color(primaryLightValue),
      100: const Color(primaryLightValue),
      200: const Color(primaryLightValue),
      300: const Color(primaryLightValue),
      400: const Color(primaryLightValue),
      500: const Color(primaryValue),
      600: const Color(primaryDarkValue),
      700: const Color(primaryDarkValue),
      800: const Color(primaryDarkValue),
      900: const Color(primaryDarkValue),
    },
  );
}

