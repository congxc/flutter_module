import 'package:flutter/material.dart';
import 'package:flutter_module/res/values/base_string.dart';
import 'package:flutter_module/res/values/strings.dart' as StringsEn;
import 'package:flutter_module/res/values-th/strings.dart' as StringsTh;
import 'package:flutter_module/res/values-zh/strings.dart' as StringsZh;
///自定义多语言实现
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  ///根据不同 locale.languageCode 加载不同语言对应
  static Map<String, Strings> _localizedValues = {
    'en': new StringsEn.Strings(),
    'zh': new StringsZh.Strings(),
    'th': new StringsTh.Strings(),
  };

  Strings get currentLocalized {
    return _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of(context, AppLocalizations);
  }
}
