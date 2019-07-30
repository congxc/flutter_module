import 'package:flutter/material.dart';

class LoadView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      child: Container(
        width: 100,
        height: 100,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RefreshProgressIndicator(
              strokeWidth: 1.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
            ),
            Text("loading..."),
          ],
        ),
      ),
    );
    ;
  }
}
