import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/common/utils/common_utils.dart';
import 'package:flutter_module/common/utils/flutter_screenutils.dart';
import 'package:flutter_module/res/style/style.dart';
import 'package:flutter_module/widget/clear_text_field.dart';
import 'package:flutter_module/widget/date_picker.dart' as picker;

class HomePage extends StatefulWidget {
  static const sName = "home_page";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _peopleController = TextEditingController();
  bool _btnEnable = false;
  GlobalKey _dateGlobalKey = GlobalKey();
  DateTime _startTime;
  DateTime _endTime;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _destinationController.addListener(() {
      setState(() {
        _btnEnable = _destinationController.value.text.isNotEmpty &&
            _startTime != null &&
            _endTime != null;
      });
    });
    _dateController.addListener(() {
      setState(() {
        _btnEnable = _destinationController.value.text.isNotEmpty &&
            _startTime != null &&
            _endTime != null;
      });
    });
  }

  void displayDate() {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String dateDisplay = "";
    if (_startTime != null) {
      dateDisplay = localizations.formatFullDate(_startTime);
    }
    if (_endTime != null) {
      dateDisplay = dateDisplay + "-" + localizations.formatFullDate(_endTime);
    }
    _dateController.text = dateDisplay;
  }

  void exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 1920, height: 1080)..init(context);
    return Material(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("static/images/bg_main.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                leading: IconButton(
                  onPressed: exitApp,
                  padding: EdgeInsets.only(top: 15),
                  icon: Image.asset(
                    "static/images/icon_back.png",
                    width: ScreenUtil.instance.setWidth(27),
                    height: ScreenUtil.instance.setHeight(52),
                    fit: BoxFit.scaleDown,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              resizeToAvoidBottomPadding: false,
            ),
            buildCenter(context)
          ],
        ),
      ),
    );
  }

  Widget buildCenter(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.setWidth(1360 + 24 + 44),
      height: ScreenUtil.instance.setHeight(768 + 24 + 44),
      decoration: BoxDecoration(
        image:
            DecorationImage(image: AssetImage("static/images/bg_search.png")),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          //阴影padding
          left: ScreenUtil.instance.setWidth(24),
          top: ScreenUtil.instance.setHeight(24),
          right: ScreenUtil.instance.setWidth(44),
          bottom: ScreenUtil.instance.setHeight(44),
        ),
        child: Container(
          padding: EdgeInsets.only(
            left: ScreenUtil.instance.setWidth(40),
            top: ScreenUtil.instance.setHeight(60),
            right: ScreenUtil.instance.setWidth(40),
          ),
          child: buildListView(context),
        ),
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    return ListView(
      children: <Widget>[
        Text(
          CommonUtils.getStrings(context).page_hotel_search,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            decoration: TextDecoration.none,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: ScreenUtil.instance.setWidth(60),
          ),
        ),
        ClearTextField(
          controller: _destinationController,
          prefixIcon: Icons.my_location,
          height: ScreenUtil.instance.setHeight(110),
          hintText: CommonUtils.getStrings(context).hint_input_destination,
        ),
        Padding(
            padding: EdgeInsets.only(top: ScreenUtil.instance.setHeight(20))),
        ClearTextField(
          key: _dateGlobalKey,
          controller: _dateController,
          onTap: () {
            _onTapDateItem();
          },
          enabled: false,
          prefixIcon: Icons.date_range,
          height: ScreenUtil.instance.setHeight(110),
          hintText: CommonUtils.getStrings(context).hint_input_check_in_date,
        ),
        Padding(
            padding: EdgeInsets.only(top: ScreenUtil.instance.setHeight(20))),
        ClearTextField(
          controller: _peopleController,
          // onTap: _onTapPeopleItem,
          enabled: false,
          prefixIcon: Icons.people,
          height: ScreenUtil.instance.setHeight(110),
          hintText: CommonUtils.getStrings(context).hint_input_people,
        ),
        Padding(
            padding: EdgeInsets.only(top: ScreenUtil.instance.setHeight(40))),
        Container(
          constraints: BoxConstraints.expand(
            height: ScreenUtil.instance.setHeight(110),
          ),
          child: RaisedButton(
            onPressed: _btnEnable ? () {} : null,
            colorBrightness: Brightness.dark,
            color: Color(AppColors.btnColor),
            disabledColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            //textColor: Colors.white,
            disabledTextColor: Colors.white,
            child: Text(
              CommonUtils.getStrings(context).action_search,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onTapDateItem() async {
    RenderBox dateBox = _dateGlobalKey.currentContext.findRenderObject();
    Size dateBoxSize = dateBox.size;
    Offset dateBoxOffset = dateBox.localToGlobal(Offset(0, 0));
    //print("dateBoxOffset = $dateBoxOffset");
    Offset offset = Offset(
        dateBoxOffset.dx,
        dateBoxOffset.dy +
            dateBoxSize.height +
            ScreenUtil.instance.setHeight(20));
    DateTime toDay = DateTime.now();
    DateTime firstDay = toDay.subtract(Duration(days: 120));
    DateTime lastDate = toDay.add(Duration(days: 130));
    int firstDayOfWeekIndex = -1;
    if (Localizations.localeOf(context).languageCode == "zh") {
      firstDayOfWeekIndex = 1; //第一列为周一
    }
    DateTime dateTime = await picker.showDatePicker(
        context: context,
        offset: offset,
        width: ScreenUtil.instance.setWidth(1280),
        supportRange: true,
//        height: ScreenUtil.instance.setHeight(476), //590
        firstDayOfWeekIndex: firstDayOfWeekIndex,
//        initialDate: toDay,
        startDate: _startTime,
        endDate: _endTime,
        firstDate: firstDay,
        lastDate: lastDate,
        showBottomButton: false,
        onTapFirst: (DateTime firstTime) {
          print("fistTime = $firstTime");
          _startTime = firstTime;
          displayDate();
        },
        onTapSecond: (DateTime secondTime) {
          print("secondTime = $secondTime");
          print("secondTime = $secondTime");
          _endTime = secondTime;
          displayDate();
        },
        onConfirm: () {
          print("onConfirm");
        });
    print("dateTime = $dateTime");
  }
//
//  void _onTapPeopleItem() {}
}
