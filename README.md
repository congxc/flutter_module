#原生APP项目集成flutter混合开发 （https://www.jianshu.com/p/1397936bbf9b、https://github.com/flutter/flutter/wiki/Add-Flutter-to-existing-apps）
# flutter_module

A new Flutter module.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.dev/).


1,进入Android项目，git submodule add https://github.com/congxc/flutter_module.git
  git update
  
2,编辑settings.gradle 
  // MyApp/settings.gradle
include ':app'
setBinding(new Binding([gradle: this]))                                 // new
evaluate(new File(                                             // new
        'flutter_module/.android/include_flutter.groovy'                          // new
))
3，app的build.gradle 添加依赖implementation project(':flutter')
4，在Android项目中直接创建Activity，通过Flutter.createView创建对应的flutter视图，
public class MyFlutterActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_flutter);
        final FlutterView flutterView = Flutter.createView(
                this,
                getLifecycle(),
                "route1"
        );
        final FrameLayout layout = findViewById(R.id.flutter_container);
        layout.addView(flutterView);
        final FlutterView.FirstFrameListener[] listeners = new FlutterView.FirstFrameListener[1];
        listeners[0] = new FlutterView.FirstFrameListener() {
            @Override
            public void onFirstFrame() {
                layout.setVisibility(View.VISIBLE);
            }
        };
        flutterView.addFirstFrameListener(listeners[0]);
    }
}
5.对应修改flutter的lib的main.dart
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(_widgetForRoute(window.defaultRouteName));

Widget _widgetForRoute(String route) {
  switch (route) {
    case 'route1':
      return SomeWidget(...);
    case 'route2':
      return SomeOtherWidget(...);
    default:
      return Center(
        child: Text('Unknown route: $route', textDirection: TextDirection.ltr),
      );
  }
}，
6通过普通activity跳转方式跳转到MyFlutterActivity就是天道flutter的页面了
