import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_module/common/bean/picmodel.dart';

class MeituListPage extends StatefulWidget {
  static final String sName = "meitu_list_page";

  @override
  _MeituListPageState createState() => new _MeituListPageState();
}

class _MeituListPageState extends State<MeituListPage> {
  List<PicModel> picList = new List();
  int page = 2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPicList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("meitu"),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemBuilder: (context, index) {
          if (index == picList.length - 1) {
            _getPicList();
          }
          return _buildItem(picList[index]);
        },
        itemCount: picList.length,
      ),
    );
  }

  Widget _buildItem(PicModel picModel) {
    print(picModel.url + picModel.type);
    return new GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new Scaffold(
                      appBar: new AppBar(
                        title: new Text('图片详情'),
                      ),
                      body: new Center(
                          child: new Container(
                        width: 300.0,
                        child: new CachedNetworkImage(
                          imageUrl: picModel.url,
                          fit: BoxFit.fitWidth,
                        ),
                      )),
                    )));
      },
      child: new CachedNetworkImage(
        errorWidget: (context, url, error) => new Icon(Icons.error),
        imageUrl: picModel.url,
        fadeInDuration: new Duration(seconds: 3),
        fadeOutDuration: new Duration(seconds: 1),
      ),
    );
  }

  _getPicList() async {
    String url = 'https://www.apiopen.top/meituApi?page=$page';
    HttpClient client = new HttpClient();
    try {
      HttpClientRequest request = await client.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String jsonString = await response.transform(utf8.decoder).join();
        print(jsonString);
        Map map = jsonDecode(jsonString);
        print(map);
        List list = map["data"];
        List<PicModel> items = new List();
        for (var value in list) {
          PicModel picModel = PicModel.fromJson(value);
          items.add(picModel);
        }
        setState(() {
          this.picList.addAll(items);
          this.page++;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _onBackPressed() {
    Navigator.pop(context);
  }
}
