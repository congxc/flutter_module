class People {
  int adultCount; //成人数量
  int childCount; //小孩数量
  List<int> children;

  People({this.adultCount, this.childCount, this.children});

  @override
  String toString() {
    return 'People{adultCount: $adultCount, childCount: $childCount, children: $children}';
  } //小孩年龄

}