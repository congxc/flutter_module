import 'package:flutter/material.dart';

Future<T> showDialog<T>({
  @required
      BuildContext context,
  bool barrierDismissible = true,
  Offset offset,
  @Deprecated(
      'Instead of using the "child" argument, return the child from a closure '
      'provided to the "builder" argument. This will ensure that the BuildContext '
      'is appropriate for widgets built in the dialog.')
      Widget child,
  WidgetBuilder builder,
}) {
  assert(child == null || builder == null);
  assert(debugCheckHasMaterialLocalizations(context));
  final ThemeData theme = Theme.of(context, shadowThemeOnly: false);
  return showGeneralDialog(
    context: context,
    offset: offset,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final Widget pageChild = child ?? Builder(builder: builder);
      return SafeArea(
        child: Builder(builder: (BuildContext context) {
          return theme != null
              ? Theme(data: theme, child: pageChild)
              : pageChild;
        }),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Color(0x01000000),
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: _buildMaterialDialogTransitions,
  );
}

Widget _buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}

Future<T> showGeneralDialog<T>({
  @required BuildContext context,
  @required RoutePageBuilder pageBuilder,
  Offset offset,
  bool barrierDismissible,
  String barrierLabel,
  Color barrierColor,
  Duration transitionDuration,
  RouteTransitionsBuilder transitionBuilder,
}) {
  assert(pageBuilder != null);
  assert(!barrierDismissible || barrierLabel != null);
  return Navigator.of(context, rootNavigator: true).push<T>(_DialogRoute<T>(
    offset: offset,
    pageBuilder: pageBuilder,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    transitionBuilder: transitionBuilder,
  ));
}

class _DialogRoute<T> extends PopupRoute<T> {
  _DialogRoute({
    @required RoutePageBuilder pageBuilder,
    this.offset,
    bool barrierDismissible = true,
    String barrierLabel,
    Color barrierColor = const Color(0x80000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder transitionBuilder,
    RouteSettings settings,
  })  : assert(barrierDismissible != null),
        _pageBuilder = pageBuilder,
        _barrierDismissible = barrierDismissible,
        _barrierLabel = barrierLabel,
        _barrierColor = barrierColor,
        _transitionDuration = transitionDuration,
        _transitionBuilder = transitionBuilder,
        super(settings: settings);

  final Offset offset;

  final RoutePageBuilder _pageBuilder;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  String get barrierLabel => _barrierLabel;
  final String _barrierLabel;

  @override
  Color get barrierColor => _barrierColor;
  final Color _barrierColor;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  final RouteTransitionsBuilder _transitionBuilder;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    if (this.offset == null) {
      return Semantics(
        child: _pageBuilder(context, animation, secondaryAnimation),
        scopesRoute: true,
        explicitChildNodes: true,
      );
    } else {
      return Stack(
        children: <Widget>[
          Positioned.directional(
            start: offset.dx,
            top: offset.dy,
            textDirection: TextDirection.ltr,
            child: _pageBuilder(
              context,
              animation,
              secondaryAnimation,
            ),
          )
        ],
      );
    }
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (_transitionBuilder == null) {
      return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
          child: child);
    } // Some default transition
    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }
}

class _OffsetRouteLayout extends SingleChildLayoutDelegate {
  final Offset offset;
  final double width;
  final double height;
  _OffsetRouteLayout(this.offset, this.width, this.height);

  @override
  bool shouldRelayout(_OffsetRouteLayout oldDelegate) {
    // TODO: implement shouldRelayout
    return offset != oldDelegate.offset;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // TODO: implement getPositionForChild
    print("offset=$offset");
//     childSizeSize(960.0, 540.0)
//     offset=Offset(155.0, 284.0)
//     width = 295.0, heigt = 295.0
//     Size =  Size(960.0, 540.0)
//     reslut = Offset(-177.5, 161.5)

//    double x  = width/2.0 - (ScreenUtil.screenWidthDp/2.0 - offset.dx); = 147.5 - (480 - 155) = 147.5 -
//    double y  = offset.dy - (ScreenUtil.screenHeightDp - height)/2.0 ;
    print("width = $width, heigt = $height");
    print("Size =  $size");
    double x = width / 2.0 - (size.width / 2.0 - offset.dx);
    double y = offset.dy - (size.height - height) / 2.0;
    var reslut = Offset(x, y);
    print("reslut = $reslut");
    return reslut;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // TODO: implement getConstraintsForChild
    return super.getConstraintsForChild(constraints);
  }
}
