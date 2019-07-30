import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_module/common/bean/filterbean.dart';
import 'package:flutter_module/common/bean/hotel.dart';
import 'package:flutter_module/common/utils/common_utils.dart';
import 'package:flutter_module/common/utils/flutter_screenutils.dart';
import 'package:flutter_module/common/http.dart' as http;

import 'base_page.dart';
import 'page_metu_list.dart';

class HotelListPage extends StatefulWidget {
  static const String sName = "hotel_list_page";
  final FilterBean filterBean;

  HotelListPage(this.filterBean);

  @override
  _HotelListPageState createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  FilterBean _filterBean;

  List<HotelBean> _hotelList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _filterBean = widget.filterBean;
    print("filterBean = $_filterBean");
    if (_filterBean != null) {
      requestHotelData();
    }
  }

  void requestHotelData() async {
    List<HotelBean> hotelList = await http.requestHotelList(_filterBean);
    if (hotelList != null && hotelList.isNotEmpty) {
      setState(() {
        _hotelList = hotelList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            CommonUtils.getStrings(context).page_hotel_list,
            style: kToolBarTitleStyle,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          padding: EdgeInsets.only(top: 15),
          icon: Image.asset(
            "static/images/icon_back.png",
            width: ScreenUtil.instance.setWidth(27),
            height: ScreenUtil.instance.setHeight(52),
            fit: BoxFit.scaleDown,
            color: themeData.primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return GridView.builder(
              padding:
                  EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 15),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: orientation == Orientation.landscape ? 3 : 2,
                  mainAxisSpacing: 17.5,
                  crossAxisSpacing: 17.5),

//              gridDelegate: HotelGridDelegate(orientation),
              itemBuilder: (context, index) {
                return buildHotelItem(_hotelList[index]);
              },
              itemCount: _hotelList == null ? 0 : _hotelList.length,
            );
          },
        ),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget buildHotelItem(HotelBean hotel) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MeituListPage(),
        ));
      },
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 391,
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: Image.network(
                    hotel.photo,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Flexible(
                flex: 191,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          hotel.hotelName,
                          style: kTitleMaxStyle,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                      ),
                      Flexible(
                        child: Row(
                          children: <Widget>[
                            InkWell(
                              child: Icon(
                                Icons.location_on,
                                color: Theme.of(context).primaryColor,
                              ),
                              onTap: () {
                                ///前往地图
                              },
                            ),
                            Expanded(
                                child: Text(
                              hotel.address,
                              style: kTitleStyle,
                              maxLines: 1,
                            )),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(),
                          ),
                          Text(
                            "￥${hotel.price}",
                            style: kTitlePriceStyle,
                            textAlign: TextAlign.end,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HotelGridDelegate extends SliverGridDelegate {
  final Orientation orientation;
  final double childAspectRatio;
  final double mainAxisSpacing;

  final double crossAxisSpacing;

  HotelGridDelegate(this.orientation,
      {this.childAspectRatio = 1,
      this.crossAxisSpacing = 17.5,
      this.mainAxisSpacing = 17.5});

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // TODO: implement getLayout
    int crossAxisCount;
    if (orientation == Orientation.portrait) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    double childWidth = usableCrossAxisExtent / crossAxisCount;
    double childHeight = childWidth * childAspectRatio;
    return SliverGridRegularTileLayout(
        crossAxisCount: crossAxisCount,
        mainAxisStride: childHeight + mainAxisSpacing,
        crossAxisStride: childWidth + crossAxisSpacing,
        childMainAxisExtent: childHeight,
        childCrossAxisExtent: childWidth,
        reverseCrossAxis:
            axisDirectionIsReversed(constraints.crossAxisDirection));
  }

  @override
  bool shouldRelayout(HotelGridDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    return this.orientation != oldDelegate.orientation;
  }
}
