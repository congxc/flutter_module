import 'dart:convert';
import 'dart:io';

import 'package:flutter_module/common/bean/destination.dart';
import 'package:flutter_module/common/config.dart';

import 'bean/filterbean.dart';
import 'bean/hotel.dart';
import 'package:flutter_module/common/utils/date_format.dart';

///根据输入关键字text搜索地址
Future<List<Destination>> requestDestination(String text) async{

  HttpClient client = HttpClient();
  String uri = Config.base_url + Config.url_autocomplete + "?text=$text";
  print("url = $uri");
  HttpClientRequest request = await client.getUrl(Uri.parse(uri));
  HttpClientResponse response = await request.close();
  if(response.statusCode == 200){
    String jsonString = await response.transform(utf8.decoder).join();
    DestinationResponseBean responseBean = DestinationResponseBean.fromJson(jsonDecode(jsonString));
    return responseBean?.data;
  }
  return null;
}
//city_ids=-1925268&checkin=2019-07-26&checkout=2019-07-27&language=zh&offset=0&rows=2&room1=A
Future<List<HotelBean>> requestHotelList(FilterBean filterBean) async{
  String checkIn = formatDate(filterBean.startTime, [yyyy,"-",mm,"-",dd]);
  String checkOut = formatDate(filterBean.endTime, [yyyy,"-",mm,"-",dd]);

  HttpClient client = HttpClient();
  String uri = Config.base_url + Config.url_hotel_availability + "?city_ids=${filterBean.destination.id}&"
      "checkin=$checkIn&checkout=$checkOut&language=zh&offset=0&rows=20";
  String adults = "";
  int adultCount = filterBean.people.adultCount;
  for(int i = 0;i < adultCount;i++){
    adults += "A";
    if(i != adultCount -1){
      adults += ",";
    }
  }
  uri += "&room1=$adults";
  List<int> childList = filterBean.people.children;
  if(childList != null && childList.isNotEmpty){
    String children = "(";
    int size = childList.length;
    for(int i = 0;i < size;i++){
      children += "${childList[i]}";
      if(i != size -1){
        children += ",";
      }
    }
    children += ")";
    uri += "$children";
  }
  print("url = $uri");
  HttpClientRequest request = await client.getUrl(Uri.parse(uri));
  HttpClientResponse response = await request.close();
  if(response.statusCode == 200){
    String jsonString = await response.transform(utf8.decoder).join();
    HotelResponseBean responseBean = HotelResponseBean.fromJson(jsonDecode(jsonString));
    return responseBean?.data;
  }

  return null;
}

