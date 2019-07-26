import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/res/style/style.dart';

Future exitApp(BuildContext context) async {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
  } else {
    Navigator.pop(context);
  }
}

const TextStyle kToolBarTitleStyle = TextStyle(
  color: Color(AppColors.primaryValue),
  fontWeight: FontWeight.bold,
  fontSize: 22,
);


const TextStyle kTitleMaxStyle = TextStyle(color: Color(AppColors.textColor),fontSize: 18);

const TextStyle kTitlePriceStyle = TextStyle(color: Color(AppColors.priceColor),fontSize: 18);

const TextStyle kTitleStyle = TextStyle(color: Color(AppColors.textColor),fontSize: 16);

const TextStyle kSubTitleStyle = TextStyle(color: Color(AppColors.textColor),fontSize: 16);
