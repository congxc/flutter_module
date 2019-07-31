import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class SpanGridDelegateWithFixedCrossAxisCount extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with a fixed number of tiles in
  /// the cross axis.
  ///
  /// All of the arguments must not be null. The `mainAxisSpacing` and
  /// `crossAxisSpacing` arguments must not be negative. The `crossAxisCount`
  /// and `childAspectRatio` arguments must be greater than zero.
  const SpanGridDelegateWithFixedCrossAxisCount({
    @required this.crossAxisCount,
    this.sizeLookup,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(childAspectRatio != null && childAspectRatio > 0);

  /// The number of each child spanSize
  final SpanSizeLookup sizeLookup;

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
    return SpanSliverGridLayout(
      sizeLookup: sizeLookup,
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SpanGridDelegateWithFixedCrossAxisCount oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio;
  }
}

class SpanSliverGridLayout extends SliverGridLayout {
  /// Creates a layout that uses equally sized and spaced tiles.
  ///
  /// All of the arguments must not be null and must not be negative. The
  /// `crossAxisCount` argument must be greater than zero.
  const SpanSliverGridLayout({
    @required this.sizeLookup,
    @required this.crossAxisCount,
    @required this.mainAxisStride,
    @required this.crossAxisStride,
    @required this.childMainAxisExtent,
    @required this.childCrossAxisExtent,
    @required this.reverseCrossAxis,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisStride != null && mainAxisStride >= 0),
        assert(crossAxisStride != null && crossAxisStride >= 0),
        assert(childMainAxisExtent != null && childMainAxisExtent >= 0),
        assert(childCrossAxisExtent != null && childCrossAxisExtent >= 0),
        assert(reverseCrossAxis != null);

  final SpanSizeLookup sizeLookup;

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of pixels from the leading edge of one tile to the leading edge
  /// of the next tile in the main axis.
  final double mainAxisStride;

  /// The number of pixels from the leading edge of one tile to the leading edge
  /// of the next tile in the cross axis.
  final double crossAxisStride;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the main axis.
  final double childMainAxisExtent;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the cross axis.
  final double childCrossAxisExtent;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    if (mainAxisStride <= 0.0) {
      return 0;
    }
    int min = crossAxisCount * (scrollOffset ~/ mainAxisStride);
    if (sizeLookup == null || sizeLookup is DefaultSpanSizeLookup) {
      return min;
    }
    int rowIndex = (scrollOffset ~/ mainAxisStride);
    min = sizeLookup.getMinPositionForRowIndex(rowIndex, crossAxisCount);
    return min;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    // 734.0, max = 8
    if (mainAxisStride <= 0.0) {
      return 0;
    }
    final int mainAxisCount = (scrollOffset / mainAxisStride).ceil();
    int max = math.max(0, crossAxisCount * mainAxisCount - 1);
    if (sizeLookup == null || sizeLookup is DefaultSpanSizeLookup) {
      return max;
    }
    int rowIndex = scrollOffset ~/ mainAxisStride;
    max = sizeLookup.getMaxPositionForRowIndex(rowIndex, crossAxisCount);
    return max;
  }

  double _getOffsetFromStartInCrossAxis(int index, double crossAxisStart) {
    if (reverseCrossAxis)
      return crossAxisCount * crossAxisStride -
          crossAxisStart -
          childCrossAxisExtent *
              (sizeLookup == null ? 1 : sizeLookup.getSpanSize(index)) -
          (crossAxisStride - childCrossAxisExtent);
    return crossAxisStart;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    double crossAxisStart;
    int row;
    int spanIndex = 0;
    double childCrossAxisWidth;
    if (sizeLookup == null || sizeLookup is DefaultSpanSizeLookup) {
      row = index ~/ crossAxisCount;
      spanIndex = index % crossAxisCount;
      childCrossAxisWidth = childCrossAxisExtent;
    } else {
      row = sizeLookup.getSpanGroupIndex(index, crossAxisCount);
      spanIndex = sizeLookup.getCachedSpanIndex(index, crossAxisCount);
      childCrossAxisWidth =
          childCrossAxisExtent * sizeLookup.getSpanSize(index) +
              (sizeLookup.getSpanSize(index) - 1) *
                  (crossAxisStride - childCrossAxisExtent);
    }
    crossAxisStart = spanIndex * crossAxisStride;
//    print("childCrossAxisWidth =  $childCrossAxisWidth,spanIndex = $spanIndex");
    return SliverGridGeometry(
      scrollOffset: row * mainAxisStride,
      crossAxisOffset: _getOffsetFromStartInCrossAxis(index, crossAxisStart),
      mainAxisExtent: childMainAxisExtent,
//      crossAxisExtent: childCrossAxisExtent ,
      crossAxisExtent: childCrossAxisWidth,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    assert(childCount != null);
    int mainAxisCount;
    if (sizeLookup == null || sizeLookup is DefaultSpanSizeLookup) {
      mainAxisCount = ((childCount - 1) ~/ crossAxisCount) + 1; //行数
    } else {
      mainAxisCount =
          sizeLookup.getSpanGroupIndex(childCount - 1, crossAxisCount) + 1;
    }

    final double mainAxisSpacing = mainAxisStride - childMainAxisExtent;
    double maxOffset = mainAxisStride * mainAxisCount - mainAxisSpacing;
    return maxOffset;
  }
}

abstract class SpanSizeLookup {
  SparseIntArray mSpanIndexCache;

  bool mCacheSpanIndices;

  SpanSizeLookup({this.mCacheSpanIndices = true}) {
    mSpanIndexCache = SparseIntArray()..init(10);
    print("constructor SpanSizeLookup");
  }
  //返回position占用空间， 返回1=占用一列 ，返回3等于占用3列
  int getSpanSize(int position);

  set setSpanIndexCacheEnabled(bool cacheSpanIndices) {
    this.mCacheSpanIndices = cacheSpanIndices;
  }

  void invalidateSpanIndexCache() {
    print("invalidateSpanIndexCache SpanSizeLookup");
    this.mSpanIndexCache.clear();
    this.mSpanIndexCache.init(10);
  }

  bool get isSpanIndexCacheEnabled {
    return this.mCacheSpanIndices;
  }

  //从缓存中获取并返回position对应列数
  int getCachedSpanIndex(int position, int spanCount) {
    if (!this.mCacheSpanIndices) {
      return this.getSpanIndex(position, spanCount);
    } else {
      int existing = this.mSpanIndexCache.get(position, -1);
      if (existing != -1) {
        return existing;
      } else {
        int value = this.getSpanIndex(position, spanCount);
        this.mSpanIndexCache.put(position, value);
        return value;
      }
    }
  }

  //返回position对应列数
  int getSpanIndex(int position, int spanCount) {
    int positionSpanSize = this.getSpanSize(position); //1
    if (positionSpanSize == spanCount) {
      return 0;
    } else {
      int span = 0;
      int startPos = 0;
      int i;
      if (this.mCacheSpanIndices && this.mSpanIndexCache.size() > 0) {
        i = this.findReferenceIndexFromCache(position);
        if (i >= 0) {
          span = this.mSpanIndexCache.get(i, -1) + this.getSpanSize(i);
          startPos = i + 1;
        }
      }

      for (i = startPos; i < position; ++i) {
        //当前所属于列数 = 之前占用列数之和  比如 3列  position = 4  012 34
        int size = this.getSpanSize(i);
        span += size; // 1 + 1 + 1  // 1 + 1 + 2 //
        if (span == spanCount) {
          //这里换行
          span = 0;
        } else if (span > spanCount) {
          span = size; // = 2
        }
      }

      if (span + positionSpanSize <= spanCount) {
        //如果 position位置空间不够了就换行 比如 3列时 position = 2 最后一列 但是它赞2列
        return span;
      } else {
        return 0;
      }
    }
  }

  int findReferenceIndexFromCache(int position) {
    int lo = 0;
    int hi = this.mSpanIndexCache.size() - 1;

    int index;
    while (lo <= hi) {
      index = lo + hi >> 1;
      int midVal = this.mSpanIndexCache.keyAt(index);
      if (midVal < position) {
        lo = index + 1;
      } else {
        hi = index - 1;
      }
    }

    index = lo - 1;
    if (index >= 0 && index < this.mSpanIndexCache.size()) {
      return this.mSpanIndexCache.keyAt(index);
    } else {
      return -1;
    }
  }

  //返回position对应行数
  int getSpanGroupIndex(int adapterPosition, int spanCount) {
    int span = 0;
    int group = 0;
    int positionSpanSize = this.getSpanSize(adapterPosition);

    for (int i = 0; i < adapterPosition; ++i) {
      int size = this.getSpanSize(i);
      span += size;
      if (span == spanCount) {
        span = 0;
        ++group;
      } else if (span > spanCount) {
        span = size;
        ++group;
      }
    }

    if (span + positionSpanSize > spanCount) {
      ++group;
    }

    return group;
  }

  //所在行数的最小position
  int getMinPositionForRowIndex(int rowIndex, int spanCount) {
    int minPosition = 0;
    for (int i = 0; true; i++) {
      int index = getSpanGroupIndex(i, spanCount);
      if (index == rowIndex) {
        minPosition = i;
        break;
      }
    }
    return minPosition;
  }

  //所在行数的最大position
  int getMaxPositionForRowIndex(int rowIndex, int spanCount) {
    int minPosition = getMinPositionForRowIndex(rowIndex, spanCount);
    if (spanCount <= 1 || spanCount == getSpanSize(minPosition)) {
      return minPosition;
    }
    int span = 0;
    for (int i = 0; i < spanCount - 1; i++) {
      // i < 2  0, 1
      int size = getSpanSize(minPosition + i);
      span += size; //3
      if (span == spanCount) {
        span = span - size;
      } else if (span > spanCount) {
        span = 0;
      }
    }
    int maxPosition = minPosition + span;
    return maxPosition;
  }
}

class DefaultSpanSizeLookup extends SpanSizeLookup {
  final bool mCacheSpanIndices;

  DefaultSpanSizeLookup({this.mCacheSpanIndices})
      : super(mCacheSpanIndices: mCacheSpanIndices);
  //返回position占用空间，比如列数等于3 返回1=占用一列 ，返回3等于占用3列
  int getSpanSize(int position) {
    return 1;
  }

  //返回position对应列数
  int getSpanIndex(int position, int spanCount) {
    return position % spanCount;
  }
}

class SparseIntArray {
  List<int> mKeys;
  List<int> mValues;
  int mSize;
  SparseIntArray(){
    print("constructor SparseIntArray");
  }

  void init(int initialCapacity) {
    print("init SparseIntArray");
    if (initialCapacity == 0) {
      mKeys = [];
      mValues = [];
    } else {
      mKeys = new List(initialCapacity);
      //print("keys = $mKeys");
      mValues = new List(mKeys.length);
    }
    mSize = 0;
  }

  void clear() {
    mSize = 0;
    mKeys = new List();
    mValues = new List();
  }

  void put(int key, int value) {
    print("----------------------put SparseIntArray");
    int i = binarySearch(mKeys, mSize, key);
    if (i >= 0) {
      mValues[i] = value;
    } else {
      i = ~i;
      print("--------- i = $i");
      mKeys = insert(mKeys, mSize, i, key);
      print("--------- keys = $mKeys");
      mValues = insert(mValues, mSize, i, value);
      mSize++;
    }
  }

  int get(int key, int valueIfKeyNotFound) {
   // print("----------------------get SparseIntArray");
    int i = binarySearch(mKeys, mSize, key);
    if (i < 0) {
      return valueIfKeyNotFound;
    } else {
      return mValues[i];
    }
  }

  int keyAt(int index) {
    return mKeys[index];
  }

  int size() {
    return mSize;
  }
}

int binarySearch(List<int> array, int size, int value) {
  int lo = 0;
  int hi = size - 1;

  while (lo <= hi) {
    final int mid = (lo + hi) >> 1;
    final int midVal = array[mid];

    if (midVal < value) {
      lo = mid + 1;
    } else if (midVal > value) {
      hi = mid - 1;
    } else {
      return mid; // value found
    }
  }
  int position = ~lo;
  print("binarySearch = position = $position");
  return ~lo; // value not present
}

List<int> insert(List<int> array, int currentSize, int index, int element) {
  assert(currentSize <= array.length);
  if (currentSize + 1 <= array.length) {
    List<int> newArray = List<int>.of(array);
    newArray[index] = element;
    return newArray;
  }

  List<int> newArray = new List<int>(currentSize + 1); //实现扩容
  List.copyRange(newArray, 0, array);
  newArray[index] = element;
  return newArray;
}
