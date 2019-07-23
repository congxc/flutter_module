import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization/appLocalizations_deleget.dart';
import 'page/home_page.dart';
import 'res/style/style.dart';
void main(){
  runApp(MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight]);

  SystemChrome.setSystemUIOverlayStyle(new SystemUiOverlayStyle(statusBarColor: Colors.transparent));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppLocalizationDelegate.delegate,
      ],
      locale: Locale("zh"),
      supportedLocales: [
        const Locale('en'), // English
        const Locale('zh'),
        const Locale('th'),
        // ... other locales the app supports
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
      ),
      home: widgetWithRoute(window.defaultRouteName),
    );
  }

  widgetWithRoute(String defaultRouteName) {
    switch (defaultRouteName) {
      case HomePage.sName:
        return HomePage();
      default:
        break;
    }
    return Container(
      child: Center(
        child: Text("null page"),
      ),
    );
  }
}
