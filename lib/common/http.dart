import 'dart:convert';
import 'dart:io';

import 'package:flutter_module/common/bean/destination.dart';
import 'package:flutter_module/common/config.dart';

Future<List<Destination>> requestDestination(String text) async{

  HttpClient client = HttpClient();
  String uri = Config.base_url + Config.url_autocomplete + "?text=$text";
  HttpClientRequest request = await client.getUrl(Uri.parse(uri));
  HttpClientResponse response = await request.close();
  if(response.statusCode == 200){
    String jsonString = await response.transform(utf8.decoder).join();
    ResponseBean responseBean = ResponseBean.fromJson(jsonDecode(jsonString));
    return responseBean?.data;
  }
  return null;
}