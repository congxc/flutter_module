import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/common/bean/destination.dart';
import 'package:flutter_module/common/bean/filterbean.dart';
import 'package:flutter_module/common/bean/people.dart';
import 'package:flutter_module/common/utils/common_utils.dart';
import 'package:flutter_module/common/utils/flutter_screenutils.dart';
import 'package:flutter_module/res/style/style.dart';
import 'package:flutter_module/widget/clear_text_field.dart';
import 'package:flutter_module/widget/date_picker.dart' as picker;
import 'package:flutter_module/widget/destination_dialog.dart';
import 'package:flutter_module/widget/people_picker.dart';
import 'package:flutter_module/common/utils/date_format.dart';
import 'package:flutter_module/common/http.dart';

import 'base_page.dart';
import 'hotel_list_page.dart';

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
  GlobalKey _destinationGlobalKey = GlobalKey();
  GlobalKey _dateGlobalKey = GlobalKey();
  GlobalKey _peopleGlobalKey = GlobalKey();
  DateTime _startTime;
  DateTime _endTime;
  People _people;
  List<Destination> _destinationList;
  Destination _destination;
  Timer _timer;
  bool _canRequestDestination = true; //是否可以执行所搜目的地

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _destinationController.addListener(() {
      updateEnable();
      String text = _destinationController.value.text;
      if (text.isNotEmpty && text.length >= 2) {
        if (_canRequestDestination) {
          startRequestDestination(text);
        }
      }
    });
    _dateController.addListener(() {
      updateEnable();
    });
    _peopleController.addListener(() {
      updateEnable();
    });
  }

  void updateEnable() {
    bool btnEnable = _destinationController.value.text.isNotEmpty &&
        _startTime != null &&
        _endTime != null &&
        _peopleController.value.text.isNotEmpty &&
        (!_peopleController.value.text.contains("\_"));
    if (_btnEnable != btnEnable) {
      setState(() {
        _btnEnable = btnEnable;
      });
    }
  }

  void startRequestDestination(String text) async {
    if (_destination != null &&
        _destinationController.value.text.isNotEmpty &&
        _destinationController.value.text.toLowerCase() ==
            _destination.name.toLowerCase()) {
      return;
    }
    _timer?.cancel();
    _timer = new Timer(Duration(milliseconds: 1000), () async {
      List<Destination> list = await requestDestination(text);
      print("list = $list");
      if (list.isNotEmpty) {
        _destination = list.first;
        _destinationList = list;
        showDestinationListDialog();
      }
    });
  }

  void displayDate() {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String dateDisplay = "";
    if (_startTime != null) {
      dateDisplay = localizations.formatMediumDate(_startTime);
    }
    if (_endTime != null) {
      dateDisplay =
          dateDisplay + "-" + localizations.formatMediumDate(_endTime);
    }
    _dateController.text = dateDisplay;
  }

  void displayPeople() {
    String display = "";
    if (_people != null) {
      display =
          "${_people.adultCount}" + CommonUtils.getStrings(context).adults;
      if (_people.childCount > 0) {
        display +=
            "${_people.childCount}" + CommonUtils.getStrings(context).children;
      }
      if (_people.children != null) {
        display += _people.children
            .toString()
            .replaceAll("\[", "(")
            .replaceAll("\]", ")")
            .replaceAll("-1", "_");
      }
    }
    _peopleController.text = display;
  }



  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 1920, height: 1080)..init(context);
    return Material(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode()); //隐藏软键盘
        },
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
                    onPressed: (){
                      exitApp(context);
                    },
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
          onTap: () {
            showDestinationListDialog();
          },
          onTapClearIcon: () {
            _destination = null;
            _destinationList = null;
          },
          key: _destinationGlobalKey,
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
          supportClear: false,
          enabled: false,
          prefixIcon: Icons.date_range,
          height: ScreenUtil.instance.setHeight(110),
          hintText: CommonUtils.getStrings(context).hint_input_check_in_date,
        ),
        Padding(
            padding: EdgeInsets.only(top: ScreenUtil.instance.setHeight(20))),
        ClearTextField(
          key: _peopleGlobalKey,
          controller: _peopleController,
          onTap: _onTapPeopleItem,
          enabled: false,
          supportClear: false,
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
            onPressed: _btnEnable
                ? () {
                    FilterBean filterBean =
                        FilterBean(_startTime, _endTime, _destination, _people);
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return HotelListPage(filterBean);
                    }));
                  }
                : null,
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

  Offset getOffset(GlobalKey globalKey) {
    RenderBox dateBox = globalKey.currentContext.findRenderObject();
    Size dateBoxSize = dateBox.size;
    Offset dateBoxOffset = dateBox.localToGlobal(Offset(0, 0));
    Offset offset = Offset(
        dateBoxOffset.dx,
        dateBoxOffset.dy +
            dateBoxSize.height +
            ScreenUtil.instance.setHeight(20));
    return offset;
  }

  void _onTapDateItem() async {
    Offset offset = getOffset(_dateGlobalKey);
    DateTime toDay = DateTime.now();
    DateTime firstDay = toDay.subtract(Duration(days: 1));
    DateTime lastDate = toDay.add(Duration(days: 30));
    int firstDayOfWeekIndex = -1;
    if (Localizations.localeOf(context).languageCode == "zh") {
      firstDayOfWeekIndex = 1; //第一列为周一
    }
    double width;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      width = ScreenUtil.instance.setWidth(1280);
    }
    DateTime dateTime = await picker.showDatePicker(
        context: context,
        offset: offset,
        width: width,
        supportRange: true,
        firstDayOfWeekIndex: firstDayOfWeekIndex,
//        initialDate: toDay,
        startDate: _startTime,
        endDate: _endTime,
        firstDate: firstDay,
        lastDate: lastDate,
        showBottomButton: false,
        onTapFirst: (DateTime firstTime) {
          print("fistTime = $firstTime,${formatDate(firstTime, [
            yyyy,
            "-",
            mm,
            "-",
            dd
          ])}");
          _startTime = firstTime;
          displayDate();
        },
        onTapSecond: (DateTime secondTime) {
          print("secondTime = $secondTime,${formatDate(secondTime, [
            yyyy,
            "-",
            mm,
            "-",
            dd
          ])}");
          _endTime = secondTime;
          displayDate();
        },
        onConfirm: () {
          print("onConfirm");
        });
    print("dateTime = $dateTime");
  }

  void _onTapPeopleItem() async {
    People people = await showPeoplePicker(
        context: context,
        people: _people,
        offset: getOffset(_peopleGlobalKey),
        width: ScreenUtil.instance.setWidth(1280),
        onConfirm: (People people) {
          print('people = $people');
        });
    _people = people;
    displayPeople();
  }

  void showDestinationListDialog() async {
    if (_destinationList == null || _destinationList.isEmpty) {
      return;
    }
    Destination destination = await showDestinationDialog(
      context: context,
      destination: _destination,
      data: _destinationList,
      width: ScreenUtil.instance.setWidth(1280),
      offset: getOffset(_destinationGlobalKey),
    );
    if (destination != null) {
      _canRequestDestination = false;
      _destination = destination;
      _destinationController.text = _destination.name;
      _canRequestDestination = true;
    }
  }
}
