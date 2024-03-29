import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/widget/dialog.dart' as app_dialog;
import 'package:flutter/rendering.dart';

enum DatePickerMode {
  /// Show a date picker UI for choosing a month and day.
  day,

  /// Show a date picker UI for choosing a year.
  year,
}
const Color _rangColor = Color(0xFFFFE3F1);
const Color _shapeColor = Color(0xFFFB2289);
const Duration _kMonthScrollDuration = Duration(milliseconds: 200);
const double _kDayPickerRowHeight = 32.5;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight =
    _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2);

class _DatePickerHeader extends StatelessWidget {
  const _DatePickerHeader({
    Key key,
    @required this.selectedDate,
    @required this.mode,
    @required this.onModeChanged,
    @required this.orientation,
  })  : assert(selectedDate != null),
        assert(mode != null),
        assert(orientation != null),
        super(key: key);

  final DateTime selectedDate;
  final DatePickerMode mode;
  final ValueChanged<DatePickerMode> onModeChanged;
  final Orientation orientation;

  void _handleChangeMode(DatePickerMode value) {
    if (value != mode) onModeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final TextTheme headerTextTheme = themeData.primaryTextTheme;
    Color dayColor;
    Color yearColor;
    switch (themeData.primaryColorBrightness) {
      case Brightness.light:
        dayColor = mode == DatePickerMode.day ? Colors.black87 : Colors.black54;
        yearColor =
            mode == DatePickerMode.year ? Colors.black87 : Colors.black54;
        break;
      case Brightness.dark:
        dayColor = mode == DatePickerMode.day ? Colors.white : Colors.white70;
        yearColor = mode == DatePickerMode.year ? Colors.white : Colors.white70;
        break;
    }
    final TextStyle dayStyle =
        headerTextTheme.display1.copyWith(color: dayColor);
    final TextStyle yearStyle =
        headerTextTheme.subhead.copyWith(color: yearColor);

    Color backgroundColor;
    switch (themeData.brightness) {
      case Brightness.light:
        backgroundColor = themeData.primaryColor;
        break;
      case Brightness.dark:
        backgroundColor = themeData.backgroundColor;
        break;
    }

    EdgeInsets padding;
    MainAxisAlignment mainAxisAlignment;
    switch (orientation) {
      case Orientation.portrait:
        padding = const EdgeInsets.all(16.0);
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case Orientation.landscape:
        padding = const EdgeInsets.all(8.0);
        mainAxisAlignment = MainAxisAlignment.start;
        break;
    }

    final Widget yearButton = IgnorePointer(
      ignoring: mode != DatePickerMode.day,
      ignoringSemantics: false,
      child: _DateHeaderButton(
        color: backgroundColor,
        onTap: Feedback.wrapForTap(
            () => _handleChangeMode(DatePickerMode.year), context),
        child: Semantics(
          selected: mode == DatePickerMode.year,
          child: Text(localizations.formatYear(selectedDate), style: yearStyle),
        ),
      ),
    );

    final Widget dayButton = IgnorePointer(
      ignoring: mode == DatePickerMode.day,
      ignoringSemantics: false,
      child: _DateHeaderButton(
        color: backgroundColor,
        onTap: Feedback.wrapForTap(
            () => _handleChangeMode(DatePickerMode.day), context),
        child: Semantics(
          selected: mode == DatePickerMode.day,
          child: Text(localizations.formatMediumDate(selectedDate),
              style: dayStyle),
        ),
      ),
    );

    return Container(
      padding: padding,
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[yearButton, dayButton],
      ),
    );
  }
}

class _DateHeaderButton extends StatelessWidget {
  const _DateHeaderButton({
    Key key,
    this.onTap,
    this.color,
    this.child,
  }) : super(key: key);

  final VoidCallback onTap;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      type: MaterialType.button,
      color: color,
      child: InkWell(
        borderRadius: kMaterialEdges[MaterialType.button],
        highlightColor: theme.highlightColor,
        splashColor: theme.splashColor,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: child,
        ),
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double viewTileHeight =
        constraints.viewportMainAxisExtent / (_kMaxDayPickerRowCount + 1);
    final double tileHeight = math.max(_kDayPickerRowHeight, viewTileHeight);
    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: tileHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }
}

const _DayPickerGridDelegate _kDayPickerGridDelegate = _DayPickerGridDelegate();

/// Displays the days of a given month and allows choosing a day.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
///
/// The day picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// See also:
///
///  * [showDatePicker], which shows a dialog that contains a material design
///    date picker.
///  * [showTimePicker], which shows a dialog that contains a material design
///    time picker.
class DayPicker extends StatelessWidget {
  /// Creates a day picker.
  ///
  /// Rarely used directly. Instead, typically used as part of a [MonthPicker].
  DayPicker({
    Key key,
    @required this.selectedDate,
    @required this.currentDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    @required this.displayedMonth,
    this.supportRange = false,
    this.startDate,
    this.endDate,
    this.selectableDayPredicate,
    this.dragStartBehavior = DragStartBehavior.start,
    this.firstDayOfWeekIndex = -1,
  })  : assert(supportRange || selectedDate != null),
        assert(currentDate != null),
        assert(onChanged != null),
        assert(displayedMonth != null),
        assert(dragStartBehavior != null),
        assert(supportRange || !firstDate.isAfter(lastDate)),
        assert(supportRange ||
            (selectedDate.isAfter(firstDate) ||
                selectedDate.isAtSameMomentAs(firstDate))),
        super(key: key);

  final bool supportRange; //支持范围选择

  final int firstDayOfWeekIndex;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;
  final DateTime startDate; //选择日期返回的 起始日期
  final DateTime endDate; //选择日期返回的 结束日期

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate selectableDayPredicate;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag gesture used to scroll a
  /// date picker wheel will begin upon the detection of a drag gesture. If set
  /// to [DragStartBehavior.down] it will begin when a down event is first
  /// detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for the different behaviors.
  final DragStartBehavior dragStartBehavior;

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  /// ```
  /// ┌ Sunday is the first day of week in the US (en_US)
  /// |
  /// S M T W T F S  <-- the returned list contains these widgets
  /// _ _ _ _ _ 1 2
  /// 3 4 5 6 7 8 9
  ///
  /// ┌ But it's Monday in the UK (en_GB)
  /// |
  /// M T W T F S S  <-- the returned list contains these widgets
  /// _ _ _ _ 1 2 3
  /// 4 5 6 7 8 9 10
  /// ```
  List<Widget> _getDayHeaders(BuildContext context, TextStyle headerStyle,
      int firstDayOfWeekIndex, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    String code = Localizations.localeOf(context).languageCode;
    bool isZh = code == "zh";
    if (firstDayOfWeekIndex == -1) {
      firstDayOfWeekIndex = localizations.firstDayOfWeekIndex;
    }
    for (int i = firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      String weekday = localizations.narrowWeekdays[i];
      if (isZh) {
        weekday = "周" + weekday;
      }
      result.add(ExcludeSemantics(
        child: Center(child: Text(weekday, style: headerStyle)),
      ));
      if (i == (firstDayOfWeekIndex - 1) % 7) break;
    }
    return result;
  }

  // Do not use this directly - call getDaysInMonth instead.
  static const List<int> _daysInMonth = <int>[
    31,
    -1,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];

  /// Returns the number of days in a month, according to the proleptic
  /// Gregorian calendar.
  ///
  /// This applies the leap year logic introduced by the Gregorian reforms of
  /// 1582. It will not give valid results for dates prior to that time.
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      if (isLeapYear) return 29;
      return 28;
    }
    return _daysInMonth[month - 1];
  }

  /// Computes the offset from the first day of week that the first day of the
  /// [month] falls on.
  ///
  /// For example, September 1, 2017 falls on a Friday, which in the calendar
  /// localized for United States English appears as:
  ///
  /// ```
  /// S M T W T F S
  /// _ _ _ _ _ 1 2
  /// ```
  ///
  /// The offset for the first day of the months is the number of leading blanks
  /// in the calendar, i.e. 5.
  ///
  /// The same date localized for the Russian calendar has a different offset,
  /// because the first day of week is Monday rather than Sunday:
  ///
  /// ```
  /// M T W T F S S
  /// _ _ _ _ 1 2 3
  /// ```
  ///
  /// So the offset is 4, rather than 5.
  ///
  /// This code consolidates the following:
  ///
  /// - [DateTime.weekday] provides a 1-based index into days of week, with 1
  ///   falling on Monday.
  /// - [MaterialLocalizations.firstDayOfWeekIndex] provides a 0-based index
  ///   into the [MaterialLocalizations.narrowWeekdays] list.
  /// - [MaterialLocalizations.narrowWeekdays] list provides localized names of
  ///   days of week, always starting with Sunday and ending with Saturday.
  int _computeFirstDayOffset(int year, int month, int firstDayOfWeekIndex,
      MaterialLocalizations localizations) {
    // 0-based day of week, with 0 representing Monday. 2019-07-01 08-01
    final int weekdayFromMonday = DateTime(year, month).weekday -
        1; //DateTime.weekday 国际日历对应年对应月的 1号的（S M T W T F S）从周日开始起始位置
    print("weekdayFromMonday = $weekdayFromMonday"); //1号从周一开始数的 位置 0 - 6
    // 0-based day of week, with 0 representing Sunday.
    int firstDayOfWeekFromSunday = firstDayOfWeekIndex;
    if (firstDayOfWeekIndex == -1) {
      firstDayOfWeekFromSunday =
          localizations.firstDayOfWeekIndex; // 0 表示周日在第一列 1 表示周一在第一列
    }
    // firstDayOfWeekFromSunday recomputed to be Monday-based
    final int firstDayOfWeekFromMonday =
        (firstDayOfWeekFromSunday - 1) % 7; //6或者0  最后一列 ，或者 第一列
    // Number of days between the first day of week appearing on the calendar,
    // and the day corresponding to the 1-st of the month.
    int firstDayOffset =
        (weekdayFromMonday - firstDayOfWeekFromMonday) % 7; //       1      4
    return firstDayOffset;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final int year = displayedMonth.year;
    final int month = displayedMonth.month;
    final int daysInMonth = getDaysInMonth(year, month); //此月有多少天
    final int firstDayOffset = _computeFirstDayOffset(
        year, month, firstDayOfWeekIndex, localizations); //第一天的起始位置
    final List<Widget> labels = <Widget>[];
    TextStyle textStyle = themeData.textTheme.caption
        .copyWith(color: themeData.primaryColor, fontSize: 15);
    TextStyle titleStyle =
        textStyle.copyWith(fontSize: 17, fontWeight: FontWeight.bold);
    labels.addAll(_getDayHeaders(
        context, textStyle, firstDayOfWeekIndex, localizations)); //title 周一到周日
    bool showRangBg = false;
    if (startDate != null && endDate != null && endDate.isAfter(startDate)) {
      showRangBg = true;
    }
    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      // S M
      final int day = i - firstDayOffset + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        labels.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool disabled = dayToBuild.isAfter(lastDate) ||
            dayToBuild.isBefore(firstDate) ||
            (selectableDayPredicate != null &&
                !selectableDayPredicate(dayToBuild));

        BoxDecoration decoration;
        TextStyle itemStyle = themeData.textTheme.body1;

        bool isSelectedDay = false;
        bool isStartDay = false;
        bool isEndDay = false;
        bool isRange = false;
        if (supportRange) {
          if (startDate != null) {
            isStartDay = startDate.year == year &&
                startDate.month == month &&
                startDate.day == day;
          }
          if (endDate != null) {
            isEndDay = endDate.year == year &&
                endDate.month == month &&
                endDate.day == day;
          }

          if (showRangBg) {
            if (dayToBuild.isAfter(startDate) && dayToBuild.isBefore(endDate)) {
              isRange = true;
            }
          }
        } else {
          isSelectedDay = selectedDate.year == year &&
              selectedDate.month == month &&
              selectedDate.day == day;
        }
        if (isSelectedDay || isStartDay || isEndDay) {
          // The selected day gets a circle background highlight, and a contrasting text color.
          itemStyle = themeData.accentTextTheme.body2;
          decoration = BoxDecoration(
//            color: themeData.accentColor,
            color: _shapeColor,
            shape: BoxShape.circle,
          );
        } else if (disabled) {
          itemStyle = themeData.textTheme.body1
              .copyWith(color: themeData.disabledColor);
        } else if (currentDate.year == year &&
            currentDate.month == month &&
            currentDate.day == day) {
          // The current day gets a different text color.
          itemStyle =
              themeData.textTheme.body2.copyWith(color: themeData.accentColor);
        }

        Widget dayWidget = Container(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  //背景
                  Flexible(
                      child: Container(
                          color: (showRangBg && (isRange || isEndDay))
                              ? _rangColor
                              : Colors.transparent)),
                  Flexible(
                      child: Container(
                          color: (showRangBg && (isRange || isStartDay))
                              ? _rangColor
                              : Colors.transparent)),
                ],
              ),
              Container(
                decoration: decoration,
                child: Center(
                  child: Semantics(
                    // We want the day of month to be spoken first irrespective of the
                    // locale-specific preferences or TextDirection. This is because
                    // an accessibility user is more likely to be interested in the
                    // day of month before the rest of the date, as they are looking
                    // for the day of month. To do that we prepend day of month to the
                    // formatted full date.
                    label:
                        '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
                    selected: isSelectedDay,
                    sortKey: OrdinalSortKey(day.toDouble()),
                    child: ExcludeSemantics(
                      child: Text(localizations.formatDecimal(day),
                          style: itemStyle),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        if (!disabled) {
          dayWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onChanged(dayToBuild);
            },
            child: dayWidget,
            dragStartBehavior: dragStartBehavior,
          );
        }

        labels.add(dayWidget);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
      child: Column(
        children: <Widget>[
          Container(
            height: _kDayPickerRowHeight + 4,
            child: Center(
              child: ExcludeSemantics(
                child: Text(
                  localizations.formatMonthYear(displayedMonth),
                  style: titleStyle,
                ),
              ),
            ),
          ),
          Flexible(
            child: GridView.custom(
              gridDelegate: _kDayPickerGridDelegate,
              childrenDelegate:
                  SliverChildListDelegate(labels, addRepaintBoundaries: false),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

/// A scrollable list of months to allow picking a month.
///
/// Shows the days of each month in a rectangular grid with one column for each
/// day of the week.
///
/// The month picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// See also:
///
///  * [showDatePicker], which shows a dialog that contains a material design
///    date picker.
///  * [showTimePicker], which shows a dialog that contains a material design
///    time picker.
class MonthPicker extends StatefulWidget {
  /// Creates a month picker.
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  MonthPicker({
    Key key,
    @required this.selectedDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    this.supportRange,
    this.startDate,
    this.endDate,
    this.firstDayOfWeekIndex,
    this.selectableDayPredicate,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert((!supportRange && selectedDate != null) ||
            (supportRange && selectedDate == null)),
        assert(onChanged != null),
        assert(supportRange || !firstDate.isAfter(lastDate)),
        assert(supportRange ||
            (selectedDate.isAfter(firstDate) ||
                selectedDate.isAtSameMomentAs(firstDate))),
        super(key: key);
  final int firstDayOfWeekIndex;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  final DateTime startDate;
  final DateTime endDate;
  final bool supportRange;

  /// Called when the user picks a month.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate selectableDayPredicate;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _chevronOpacityTween =
      Tween<double>(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();

    // Initially display the pre-selected date.
    int monthPage;
    if (widget.selectedDate == null) {
      monthPage = _monthDelta(widget.firstDate, DateTime.now());
    } else {
      monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
    }
    _dayPickerController = PageController(initialPage: monthPage);
    _handleMonthPageChanged(monthPage);
    _updateCurrentDate();

    // Setup the fade animation for chevrons
    _chevronOpacityController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _chevronOpacityAnimation =
        _chevronOpacityController.drive(_chevronOpacityTween);
  }

  @override
  void didUpdateWidget(MonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      final int monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
      _dayPickerController = PageController(initialPage: monthPage);
      _handleMonthPageChanged(monthPage);
    }
  }

  MaterialLocalizations localizations;
  TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
  }

  DateTime _todayDate;
  DateTime _currentDisplayedMonthDate;
  Timer _timer;
  PageController _dayPickerController;
  AnimationController _chevronOpacityController;
  Animation<double> _chevronOpacityAnimation;

  void _updateCurrentDate() {
    _todayDate = DateTime.now();
    final DateTime tomorrow =
        DateTime(_todayDate.year, _todayDate.month, _todayDate.day + 1);
    Duration timeUntilTomorrow = tomorrow.difference(_todayDate);
    timeUntilTomorrow +=
        const Duration(seconds: 1); // so we don't miss it by rounding
    _timer?.cancel();
    _timer = Timer(timeUntilTomorrow, () {
      setState(() {
        _updateCurrentDate();
      });
    });
  }

  static int _monthDelta(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }

  /// Add months to a month truncated date.
  DateTime _addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    return DateTime(
        monthDate.year + monthsToAdd ~/ 12, monthDate.month + monthsToAdd % 12);
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime month = _addMonthsToMonthDate(widget.firstDate, index);
    return DayPicker(
      key: ValueKey<DateTime>(month),
      selectedDate: widget.selectedDate,
      currentDate: _todayDate,
      onChanged: widget.onChanged,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      startDate: widget.startDate,
      endDate: widget.endDate,
      supportRange: widget.supportRange,
      firstDayOfWeekIndex: widget.firstDayOfWeekIndex,
      displayedMonth: month,
      selectableDayPredicate: widget.selectableDayPredicate,
      dragStartBehavior: widget.dragStartBehavior,
    );
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
          localizations.formatMonthYear(_nextMonthDate), textDirection);
      _dayPickerController.nextPage(
          duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
          localizations.formatMonthYear(_previousMonthDate), textDirection);
      _dayPickerController.previousPage(
          duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth {
    return !_currentDisplayedMonthDate
        .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));
  }

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth {
    return !_currentDisplayedMonthDate
        .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  DateTime _previousMonthDate;
  DateTime _nextMonthDate;

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      _previousMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage - 1);
      _currentDisplayedMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage);
      _nextMonthDate = _addMonthsToMonthDate(widget.firstDate, monthPage + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return SizedBox(
      // The month picker just adds month navigation to the day picker, so make
      // it the same height as the DayPicker
      height: _kMaxDayPickerHeight,
      child: Stack(
        children: <Widget>[
          Semantics(
            sortKey: _MonthPickerSortKey.calendar,
            child: NotificationListener<ScrollStartNotification>(
              onNotification: (_) {
                _chevronOpacityController.forward();
                return false;
              },
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (_) {
                  _chevronOpacityController.reverse();
                  return false;
                },
                child: PageView.builder(
                  dragStartBehavior: widget.dragStartBehavior,
                  key: ValueKey<DateTime>(widget.selectedDate),
                  controller: _dayPickerController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _monthDelta(widget.firstDate, widget.lastDate) + 1,
                  itemBuilder: _buildItems,
                  onPageChanged: _handleMonthPageChanged,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            start: 8.0,
            child: Semantics(
              sortKey: _MonthPickerSortKey.previousMonth,
              child: FadeTransition(
                opacity: _chevronOpacityAnimation,
                child: IconButton(
                  iconSize: 26,
                  color: themeData.primaryColor,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: _isDisplayingFirstMonth
                      ? null
                      : '${localizations.previousMonthTooltip} ${localizations.formatMonthYear(_previousMonthDate)}',
                  onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            end: 8.0,
            child: Semantics(
              sortKey: _MonthPickerSortKey.nextMonth,
              child: FadeTransition(
                opacity: _chevronOpacityAnimation,
                child: IconButton(
                  iconSize: 26,
                  color: themeData.primaryColor,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: _isDisplayingLastMonth
                      ? null
                      : '${localizations.nextMonthTooltip} ${localizations.formatMonthYear(_nextMonthDate)}',
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _chevronOpacityController?.dispose();
    _dayPickerController?.dispose();
    super.dispose();
  }
}

// Defines semantic traversal order of the top-level widgets inside the month
// picker.
class _MonthPickerSortKey extends OrdinalSortKey {
  const _MonthPickerSortKey(double order) : super(order);

  static const _MonthPickerSortKey previousMonth = _MonthPickerSortKey(1.0);
  static const _MonthPickerSortKey nextMonth = _MonthPickerSortKey(2.0);
  static const _MonthPickerSortKey calendar = _MonthPickerSortKey(3.0);
}

/// A scrollable list of years to allow picking a year.
///
/// The year picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [showDatePicker], which shows a dialog that contains a material design
///    date picker.
///  * [showTimePicker], which shows a dialog that contains a material design
///    time picker.
class YearPicker extends StatefulWidget {
  /// Creates a year picker.
  ///
  /// The [selectedDate] and [onChanged] arguments must not be null. The
  /// [lastDate] must be after the [firstDate].
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  YearPicker({
    Key key,
    @required this.selectedDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(selectedDate != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a year.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  _YearPickerState createState() => _YearPickerState();
}

class _YearPickerState extends State<YearPicker> {
  static const double _itemExtent = 50.0;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      // Move the initial scroll position to the currently selected date's year.
      initialScrollOffset:
          (widget.selectedDate.year - widget.firstDate.year) * _itemExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = Theme.of(context);
    final TextStyle style = themeData.textTheme.body1;
    return ListView.builder(
      dragStartBehavior: widget.dragStartBehavior,
      controller: scrollController,
      itemExtent: _itemExtent,
      itemCount: widget.lastDate.year - widget.firstDate.year + 1,
      itemBuilder: (BuildContext context, int index) {
        final int year = widget.firstDate.year + index;
        final bool isSelected = year == widget.selectedDate.year;
        final TextStyle itemStyle = isSelected
            ? themeData.textTheme.headline
                .copyWith(color: themeData.accentColor)
            : style;
        return InkWell(
          key: ValueKey<int>(year),
          onTap: () {
            widget.onChanged(DateTime(
                year, widget.selectedDate.month, widget.selectedDate.day));
          },
          child: Center(
            child: Semantics(
              selected: isSelected,
              child: Text(year.toString(), style: itemStyle),
            ),
          ),
        );
      },
    );
  }
}

class _DatePickerDialog extends StatefulWidget {
  const _DatePickerDialog({
    Key key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.width = double.infinity,
    this.supportRange,
    this.startDate,
    this.endDate,
    this.showBottomButton,
    this.onTapFirst,
    this.onTapSecond,
    this.onConfirm,
    this.selectableDayPredicate,
    this.initialDatePickerMode,
    this.firstDayOfWeekIndex,
  }) : super(key: key);
  final int firstDayOfWeekIndex;
  final double width;
  final bool showBottomButton;
  final GestureTapCallback onTapFirst;
  final GestureTapCallback onTapSecond;
  final VoidCallback onConfirm;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime startDate;
  final DateTime endDate;
  final bool supportRange;
  final SelectableDayPredicate selectableDayPredicate;
  final DatePickerMode initialDatePickerMode;

  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  @override
  void initState() {
    super.initState();
    _mode = widget.initialDatePickerMode;
    _supportRange = widget.supportRange;
    _selectedDate = widget.initialDate;
    if (_supportRange) {
      _startDate = widget.startDate;
      _endDate = widget.endDate;
    }
  }

  bool _announcedInitialDate = false;

  MaterialLocalizations localizations;
  TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      if (_selectedDate != null) {
        SemanticsService.announce(
          localizations.formatFullDate(_selectedDate),
          textDirection,
        );
      }
    }
  }

  DateTime _selectedDate;
  DatePickerMode _mode;
  bool _supportRange;
  DateTime _startDate;
  DateTime _endDate;
  final GlobalKey _pickerKey = GlobalKey();

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
        break;
    }
  }

  void _handleYearChanged(DateTime value) {
    if (value.isBefore(widget.firstDate))
      value = widget.firstDate;
    else if (value.isAfter(widget.lastDate)) value = widget.lastDate;
    if (value == _selectedDate) return;

    _vibrate();
    setState(() {
      _mode = DatePickerMode.day;
      saveSelectedDate(value);
    });
  }

  void saveSelectedDate(DateTime value) {
    if (_supportRange) {
      // _selectedDate = value;
      if (_startDate == null) {
        if (_endDate != null && value.isAfter(_endDate)) {
          _startDate = _endDate;
          _endDate = value;
          widget.onTapFirst?.call(_startDate);
          widget.onTapSecond?.call(_endDate);
          _handleOk();
        } else {
          _startDate = value;
          widget.onTapFirst?.call(value);
        }
      } else if (_endDate == null) {
        if (value.isBefore(_startDate)) {
          _endDate = _startDate;
          _startDate = value;
          widget.onTapFirst?.call(_startDate);
          widget.onTapSecond?.call(_endDate);
        } else {
          _endDate = value;
          widget.onTapSecond?.call(value);
        }
        _handleOk();
      } else {
        _startDate = null;
        _endDate = null;
        widget.onTapFirst?.call(_startDate);
        widget.onTapSecond?.call(_endDate);
      }
    } else {
      _selectedDate = value;
    }
  }

  void _handleDayChanged(DateTime value) {
    _vibrate();
    setState(() {
      saveSelectedDate(value);
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    widget.onConfirm?.call();
    Navigator.pop(context, _selectedDate);
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
      if (_mode == DatePickerMode.day) {
        SemanticsService.announce(
            localizations.formatMonthYear(_selectedDate), textDirection);
      } else {
        SemanticsService.announce(
            localizations.formatYear(_selectedDate), textDirection);
      }
    });
  }

  Widget _buildPicker() {
    assert(_mode != null);
    switch (_mode) {
      case DatePickerMode.day:
        return MonthPicker(
          key: _pickerKey,
          selectedDate: _selectedDate,
          firstDayOfWeekIndex: widget.firstDayOfWeekIndex,
          onChanged: _handleDayChanged,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          startDate: _startDate,
          endDate: _endDate,
          supportRange: widget.supportRange,
          selectableDayPredicate: widget.selectableDayPredicate,
        );
      case DatePickerMode.year:
        return YearPicker(
          key: _pickerKey,
          selectedDate: _selectedDate,
          onChanged: _handleYearChanged,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget picker = _buildPicker();
    Widget actions;
    if (widget.showBottomButton) {
      actions = ButtonTheme.bar(
        child: ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text(localizations.cancelButtonLabel),
              onPressed: _handleCancel,
            ),
            FlatButton(
              child: Text(localizations.okButtonLabel),
              onPressed: _handleOk,
            ),
          ],
        ),
      );
    }
    Widget dialog;
    if (widget.width != null && widget.width != double.infinity) {
      dialog = Material(
        color: Theme.of(context).dialogBackgroundColor,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        type: MaterialType.card,
        child: Container(
          width: widget.width,
          child: actions == null
              ? picker
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(child: picker),
                    actions,
                  ],
                ),
        ),
      );
    } else {
      dialog = Dialog(
        elevation: 0,
        backgroundColor: Color(0x010000),
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            switch (orientation) {
              case Orientation.portrait:
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: actions == null
                      ? picker
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Flexible(child: picker),
                            actions,
                          ],
                        ),
                );
              case Orientation.landscape:
                return Row(
                  children: <Widget>[
                    Flexible(child: GestureDetector(onTap: (){Navigator.of(context).pop();},)),
                    Flexible(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: actions == null
                            ? picker
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Flexible(child: picker),
                                  actions,
                                ],
                              ),
                      ),
                    ),
                    Flexible(child: GestureDetector(onTap: (){Navigator.of(context).pop();},)),
                  ],
                );
            }
            return null;
          },
        ),
      );
    }

    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }
}

typedef GestureTapCallback = void Function(DateTime dateTime);

typedef VoidCallback = void Function();

Future<DateTime> showDatePicker({
  @required BuildContext context,
  DateTime initialDate,
  @required DateTime firstDate,
  @required DateTime lastDate,
  bool supportRange,
  DateTime startDate,
  DateTime endDate,
  double width,
  Offset offset,
  bool showBottomButton,
  int firstDayOfWeekIndex,
  GestureTapCallback onTapFirst,
  GestureTapCallback onTapSecond,
  VoidCallback onConfirm,
  SelectableDayPredicate selectableDayPredicate,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  Locale locale,
  TextDirection textDirection,
  TransitionBuilder builder,
}) async {
  // assert(initialDate != null);
  assert(firstDate != null);
  assert(lastDate != null);
  assert(initialDate == null || !initialDate.isBefore(firstDate),
      'initialDate must be on or after firstDate');
  assert(initialDate == null || !initialDate.isAfter(lastDate),
      'initialDate must be on or before lastDate');
  assert(
      !firstDate.isAfter(lastDate), 'lastDate must be on or after firstDate');
  assert(selectableDayPredicate == null || selectableDayPredicate(initialDate),
      'Provided initialDate must satisfy provided selectableDayPredicate');
  assert(
      initialDatePickerMode != null, 'initialDatePickerMode must not be null');
  assert(context != null);
  assert(debugCheckHasMaterialLocalizations(context));
  print("width = $width");
  Widget child = _DatePickerDialog(
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    supportRange: supportRange,
    startDate: startDate,
    endDate: endDate,
    firstDayOfWeekIndex: firstDayOfWeekIndex,
    width: width,
    showBottomButton: showBottomButton,
    onTapFirst: onTapFirst,
    onTapSecond: onTapSecond,
    onConfirm: onConfirm,
    selectableDayPredicate: selectableDayPredicate,
    initialDatePickerMode: initialDatePickerMode,
  );

  if (textDirection != null) {
    child = Directionality(
      textDirection: textDirection,
      child: child,
    );
  }

  if (locale != null) {
    child = Localizations.override(
      context: context,
      locale: locale,
      child: child,
    );
  }
  if (width == null || width == double.infinity) {
    offset = null;
  }
  print("offset = $offset");
  return await app_dialog.showDialog<DateTime>(
    context: context,
    offset: offset,
    builder: (BuildContext context) {
      return builder == null ? child : builder(context, child);
    },
  );
}
