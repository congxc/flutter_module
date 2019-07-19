import 'package:flutter/material.dart';
import 'package:flutter_module/localization/app_localizations.dart';
import 'package:flutter_module/res/values/base_string.dart';

class CommonUtils{

  static Strings getStrings(BuildContext context){
    return AppLocalizations.of(context).currentLocalized;
  }
}