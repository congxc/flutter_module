import 'package:flutter/material.dart';
import 'package:flutter_module/common/bean/people.dart';
import 'package:flutter_module/common/utils/common_utils.dart';
import 'package:flutter_module/widget/dialog.dart' as app_dialog;
import 'package:flutter/rendering.dart';

const int _kRowHeight = 50;

const int _kRowCount = 2; //行数

const int _kColumnCount = 15; //列数

const Color _kSelectdColor = Color(0xFFFB2289);

class PeopleGridDelegate extends SliverGridDelegate {
  const PeopleGridDelegate();
  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    double titleWidth = constraints.crossAxisExtent / _kColumnCount;
    double titleHeight = constraints.viewportMainAxisExtent / _kRowCount;
    // TODO: implement getLayout
    return SliverGridRegularTileLayout(
        crossAxisCount: _kColumnCount,
        mainAxisStride: titleHeight,
        crossAxisStride: titleWidth,
        childMainAxisExtent: titleHeight,
        childCrossAxisExtent: titleWidth,
        reverseCrossAxis:
            axisDirectionIsReversed(constraints.crossAxisDirection));
  }

  @override
  bool shouldRelayout(SliverGridDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    return false;
  }
}

const PeopleGridDelegate _kPeopleGridDelegate = PeopleGridDelegate();

class _PeoplePicker extends StatefulWidget {
  final People people;
  final ValueChanged<People> onChanged;

  _PeoplePicker({Key key, this.people, this.onChanged}) : super(key: key);

  @override
  _PeoplePickerState createState() => _PeoplePickerState();
}

class TabTitle {
  String title;
  int id; //0成人 1儿童  2
  int count; //标签个数 ，成人 1个 儿童 1  儿童年龄 为儿童数量个数
  TabTitle({this.id, this.count, this.title});
}

class PageData {
  int id; //  -1成人 0 儿童   儿童1,2,3...年龄
  int count; //标签数

  PageData({this.id, this.count});
}

class _PeoplePickerState extends State<_PeoplePicker>
    with TickerProviderStateMixin {
  PageController _pageController;
  TabController _tabController;
  List<TabTitle> _tabList = [];
  List<PageData> _pageList = [];
  People _people;
  int _currentPageIndex = 0;
  GlobalKey pageViewKey = GlobalKey();
  bool _canChangeTabBar = true;//TabBar切换导致PageView切换时，TabBar不可以切换

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("initState");
    _people = widget.people ?? People(adultCount: -1, childCount: -1);
    updateTabList();
    updatePageList();
    pageIndexDelta();
  }

  @override
  void didUpdateWidget(_PeoplePicker oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget");
    pageIndexDelta();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print("didUpdateWidget");
  }

  int pageIndexDelta() {
    _currentPageIndex = 0;
    if (_people.adultCount > 0 && _people.childCount < 1) {
      _currentPageIndex = 1;
    } else if (_people.childCount > 0) {
      List<int> children = _people.children;
      for (int i = 0; i < children.length; i++) {
        int age = children[i];
        if (age == -1) {
          _currentPageIndex = 2 + i;
          break;
        }
      }
    }
    return _currentPageIndex;
  }

  void bindController(int tabSize) {
    _pageController?.dispose();
    _tabController?.dispose();
    _pageController = PageController(
        initialPage: _currentPageIndex, keepPage: true, viewportFraction: 1);
    _tabController = TabController(
        initialIndex: _currentPageIndex, length: tabSize, vsync: this)
      ..addListener(() {
        //判断TabBar是否切换
        _currentPageIndex = _tabController.index;
        if (_tabController.indexIsChanging) {
          print("onTabPageChange index = $_currentPageIndex");
          onPageChange(_currentPageIndex, p: _pageController);
        }
      });
  }

  int updateTabList() {
    _tabList.clear();
    TabTitle tabAdult = TabTitle(id: 0, count: 1);
    _tabList.add(tabAdult);
    if (_people.adultCount < 1) {
      return 1;
    }
    TabTitle tabChild = TabTitle(id: 1, count: 1);
    _tabList.add(tabChild);
    int childCount = _people.childCount;
    if (childCount < 1) {
      return 2;
    }
    TabTitle tab = TabTitle(id: 2, count: childCount);
    _tabList.add(tab);
    return 2 + childCount;
  }

  void updatePageList() {
    _pageList.clear();
    for (int i = 0; i < _tabList.length; i++) {
      TabTitle tabTitle = _tabList[i];
      if (tabTitle.count == 0) {
        break;
      }
      if (tabTitle.id == 0) {
        PageData pageData = new PageData(id: -1, count: 30);
        _pageList.add(pageData);
      } else if (tabTitle.id == 1) {
        PageData pageData = new PageData(id: 0, count: 10);
        _pageList.add(pageData);
      } else if (tabTitle.count > 0) {
        for (int j = 0; j < tabTitle.count; j++) {
          PageData pageData = new PageData(id: j + 1, count: 18);
          _pageList.add(pageData);
        }
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("dispose");
    _pageController?.dispose();
    _tabController?.dispose();
  }

  List<Widget> renderTabs() {
    List<Widget> tabs = [];
    for (int i = 0; i < _tabList.length; i++) {
      TabTitle tabTitle = _tabList[i];
      if (tabTitle.count == 0) {
        break;
      }
      String label = "";
      if (tabTitle.id == 0) {
        label = CommonUtils.getStrings(context).adults;
        Tab tab = Tab(
          text: label,
        );
        tabs.add(tab);
      } else if (tabTitle.id == 1) {
        label = CommonUtils.getStrings(context).children;
        Tab tab = Tab(
          text: label,
        );
        tabs.add(tab);
      } else if (tabTitle.count > 0) {
        for (int j = 0; j < tabTitle.count; j++) {
          label = CommonUtils.getStrings(context).children +
              '${j + 1}' +
              CommonUtils.getStrings(context).age;
          Tab tab = Tab(
            text: label,
          );
          tabs.add(tab);
        }
      }
    }
    return tabs;
  }

  List<Widget> renderPages() {
    List<Widget> pages = [];
    int length = _pageList.length;
    for (int i = 0; i < length; i++) {
      PageData pageData = _pageList[i];
      int size = pageData.count;
      int id = pageData.id;
      Widget page = GridView.builder(
        gridDelegate: _kPeopleGridDelegate,
        itemBuilder: (context, index) {
          bool isSelected = false;
          int count = index;
          if (id == -1) {
            count = index + 1;
            isSelected = _people.adultCount == count;
          } else if (id == 0) {
            count = index + 1;
            isSelected = _people.childCount == count;
          } else if (_people.childCount > 0) {
            List<int> ages = _people.children;
            if (ages.length >= id) {
              int age = ages[id - 1];
              isSelected = age == count;
            }
          }
          return buildLabel(id, isSelected, count);
        },
        itemCount: size,
      );
      pages.add(page);
    }
    return pages;
  }

  Widget buildLabel(int id, bool isSelected, int count) {
    const TextStyle normalStyle =
        TextStyle(color: Color(0xFF505050), fontSize: 17);
    const TextStyle selectedStyle =
        TextStyle(color: Colors.white, fontSize: 17);
    Widget label = Container(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? _kSelectdColor : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(1, 1),
//                blurRadius: 15,
            ),
          ],
        ),
        child: Text(
          "$count",
          style: isSelected ? selectedStyle : normalStyle,
        ),
      ),
    );
    label = GestureDetector(
      onTap: () {
//        print("count = $count");
        bool changed = false;
        People people;
        if (id == -1) {
          if (_people.adultCount != count) {
            changed = true;
            people = People(
                adultCount: count,
                childCount: _people.childCount,
                children: _people.children);
          }
        } else if (id == 0) {
          //选择儿童数
          if (count != _people.childCount) {
            changed = true;
            List<int> children = List.filled(count, -1, growable: true);
            people = People(
                adultCount: _people.adultCount,
                childCount: count,
                children: children);
          }
        } else {
          List<int> children = _people.children;
          if (children.length == _people.childCount && id <= children.length) {
            if (children[id - 1] != count) {
              changed = true;
              children[id - 1] = count;
              people = People(
                  adultCount: _people.adultCount,
                  childCount: _people.childCount,
                  children: children);
            }
          } else {
            print("childCount exception");
          }
        }
        if (changed) {
          _people = people;
          updateTabList();
          updatePageList();
          print("_people = $_people _currentPageIndex = $_currentPageIndex");
          setState(() {});
          addBuildStatusListener();
          widget.onChanged?.call(_people);
        }
      },
      child: label,
    );
    return label;
  }

  void addBuildStatusListener() {
    WidgetsBinding binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((callback) {
      int nextPage = _currentPageIndex + 1;
      print("----------------nextPage = $nextPage");
      if (nextPage >= _tabController.length) {
        nextPage = 0;
      } else {
        _tabController.animateTo(nextPage,
            duration: Duration(milliseconds: 50), curve: Curves.ease);
      }
//         _pageController.animateToPage(_currentPageIndex,duration: Duration(milliseconds: 50),curve: Curves.ease);
    });
  }
  void animateToPage(int target,int duration) async{
      await _pageController.animateToPage(target,
          duration: Duration(milliseconds: duration), curve: Curves.ease);
      print("animateToPage $target");
  }
  void onPageChange(int targetIndex, {PageController p, TabController t}) async {
    if (p != null && p.page != targetIndex) {
      _canChangeTabBar = true;
      await _pageController.animateToPage(targetIndex,
          duration: Duration(milliseconds: 200), curve: Curves.ease);
      _canChangeTabBar = false;//一次切换多页时 ，保证切换过程中不触发TabBar的切换
    } else if (t != null && t.index != targetIndex) {
        _tabController?.animateTo(targetIndex); //切换Tabbar
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    List<Widget> tabs = renderTabs();
    List<Widget> pages = renderPages();
    bindController(tabs.length);
    return SizedBox(
      height: 165,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: buildTabBar(tabs),
            ),
            Flexible(
              flex: 2,
              child: buildPageView(pages),
            ),
          ],
        ),
      ),
    );
    ;
  }

  Container buildTabBar(List<Widget> tabs) {
    return Container(
      padding: EdgeInsets.only(right: 65),
      height: 35,
      //width: 86.0 * tabList.length,
      child: TabBar(
        isScrollable: true,
        indicatorColor: Color(0xFFFB2289),
        controller: _tabController,
        labelColor: Color(0xFFFB2289),
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: Color(0xFF505050),
        tabs: tabs,
      ),
    );
  }

  PageView buildPageView(List<Widget> pages) {
    return PageView(
      key: pageViewKey,
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      children: pages,
      onPageChanged: (index) {
        print("onPageViewChange index = $index");
        if(!_canChangeTabBar){//PageView一次性切换多页时，会多次调用onPageChanged，
            onPageChange(index, t: _tabController);
        }
      },
    );
  }
}

class _PeoplePickerDialog extends StatefulWidget {
  const _PeoplePickerDialog({
    Key key,
    this.people,
    this.width,
    this.onConfirm,
  }) : super(key: key);

  final People people;
  final double width;
  final ValueChanged<People> onConfirm;

  @override
  _PeoplePickerDialogState createState() => _PeoplePickerDialogState();
}

class _PeoplePickerDialogState extends State<_PeoplePickerDialog> {
  People _people;
  MaterialLocalizations localizations;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _people = widget.people;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
  }

  void _handleOk() {
    widget.onConfirm?.call(_people);
    Navigator.pop(context, _people);
  }

  void _handleChangle(People value) {
    _people = value;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final dialog = Material(
      color: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 24,
      type: MaterialType.card,
      child: Container(
//          decoration: BoxDecoration(
//            borderRadius: BorderRadius.circular(10),
//          ),
          width: widget.width,
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              _PeoplePicker(people: _people, onChanged: _handleChangle),
              PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: FlatButton(
                    onPressed: _handleOk,
                    child: Text(
                      localizations.okButtonLabel,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: theme.primaryColor),
                    ),
                  )),
            ],
          )),
    );
    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }
}

Future<People> showPeoplePicker({
  @required BuildContext context,
  People people,
  Offset offset,
  double width,
  ValueChanged<People> onConfirm,
  Locale locale,
  TransitionBuilder builder,
}) async {
  Widget child = _PeoplePickerDialog(
    width: width,
    people: people,
    onConfirm: onConfirm,
  );

  if (locale != null) {
    child = Localizations.override(
      context: context,
      locale: locale,
      child: child,
    );
  }
  return await app_dialog.showDialog<People>(
    context: context,
    offset: offset,
    builder: (BuildContext context) {
      return builder == null ? child : builder(context, child);
    },
  );
}
