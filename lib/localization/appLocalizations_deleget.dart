import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'app_localizations.dart';

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations>{

  @override
  bool isSupported(Locale locale) {
    // TODO: implement isSupported
    return ["en","zh","th"].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    // TODO: implement load
    return new SynchronousFuture<AppLocalizations>(new AppLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    // TODO: implement shouldReload
    return false;
  }

  static AppLocalizationDelegate delegate = new AppLocalizationDelegate();

}