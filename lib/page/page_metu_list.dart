import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_module/common/bean/picmodel.dart';
import 'package:flutter_module/widget/load_view.dart';
import 'package:flutter_module/widget/span_sliver_grid_delegate.dart';

class MeituListPage extends StatefulWidget {
  static final String sName = "meitu_list_page";

  @override
  _MeituListPageState createState() => new _MeituListPageState();
}

class _MeituListPageState extends State<MeituListPage> {
  List<PicModel> picList = new List();
  int page = 2;
  bool loadMoreEnable = true; //是否可以加载更多
  bool isRefreshing = false; //是否刷新中
  bool isLoadingMore = false; //是否加载更多中
  GlobalKey<RefreshIndicatorState> refreshGlobalKey =
      GlobalKey<RefreshIndicatorState>();

  ScrollController _scrollController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          print("--------------loadMoreEnable = $loadMoreEnable page = $page");
          if (loadMoreEnable) {
            onLoadMore();
          }
        }
      });
    isRefreshing = true;
    _getPicList().then((success) {
      setState(() {
        isRefreshing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("meitu"),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            buildContentView(),
            isRefreshing ? LoadView() : Container(),
          ],
        ));
  }

  Widget _buildLoadMoreView() {
    return Center(
      child: RefreshProgressIndicator(),
    );
  }

  RefreshIndicator buildContentView() {
    return RefreshIndicator(
      key: refreshGlobalKey,
      onRefresh: onRefresh,
      child: GridView.builder(
        controller: _scrollController,
//        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//          crossAxisCount: 3,
//          mainAxisSpacing: 10,
//          crossAxisSpacing: 10,
//        ),
        gridDelegate: SpanGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          sizeLookup: PhotoSizeLookUp(),
        ),
        itemBuilder: (context, index) {
          if (loadMoreEnable) {
            if (index >= picList.length) {
              return _buildLoadMoreView();
            } else {
              return _buildItem(picList[index]);
            }
          } else {
            return _buildItem(picList[index]);
          }
        },
        itemCount: picList.length == 0
            ? 0
            : (loadMoreEnable ? picList.length + 1 : picList.length),
      ),
    );
  }

  Widget _buildItem(PicModel picModel) {
    //print(picModel.url + picModel.type);
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
      child: Container(
        //color: Colors.greenAccent,
        child: new CachedNetworkImage(
          errorWidget: (context, url, error) =>Image.asset("static/images/defalut_img.jpg"),
          imageUrl: picModel.url,
          fadeInDuration: new Duration(seconds: 3),
          fadeOutDuration: new Duration(seconds: 1),
        ),
      ),
    );
  }

  Future<bool> _getPicList() async {
    String url = 'https://www.apiopen.top/meituApi?page=$page';
    HttpClient client = new HttpClient();
    try {
      HttpClientRequest request = await client.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String jsonString = await response.transform(utf8.decoder).join();
        print(jsonString);
        Map map = jsonDecode(jsonString);
        List list = map["data"];
        List<PicModel> items = new List();
        for (var value in list) {
          PicModel picModel = PicModel.fromJson(value);
          items.add(picModel);
        }
        this.picList.addAll(items);
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> onRefresh() async {
    print("--------------onRefresh");
    if (isRefreshing || isLoadingMore) {
      return null;
    }
    loadMoreEnable = true;
    isRefreshing = true;
    picList?.clear();
    page = 1;
    return await Future.delayed(Duration(milliseconds: 2000), () async {
      return await _getPicList();
    }).then((success) {
      isRefreshing = false;
      setState(() {});
      return success;
    });
  }

  Future<void> onLoadMore() async {
    print("--------------onLoadMore");
    if (isRefreshing || isLoadingMore) {
      return null;
    }
    if (page >= 3) {
      loadMoreEnable = false;
    }
    isLoadingMore = true;
    page++;
    return await Future.delayed(Duration(milliseconds: 2000), () async {
      return await _getPicList();
    }).then((success) {
      print("--------------onLoadMore $success");
      isLoadingMore = false;
      setState(() {});
      return success;
    });
  }
}

class PhotoSizeLookUp extends SpanSizeLookup {
  @override
  int getSpanSize(int position) {
    // TODO: implement getSpanSize
    if (position == 0) {
      return 3;
    }
    if (position % 4 == 0) {
      return 3;
    }
    return 1;
  }
}
