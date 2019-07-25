import 'package:flutter/material.dart';
import 'package:flutter_module/common/bean/destination.dart';
import 'package:flutter_module/res/style/style.dart';
import 'dialog.dart' as app_dialog;

const double _kItemHeight = 38.0;

class DestinationWidget extends StatefulWidget {
  final Destination destination;
  final List<Destination> data;
  final ValueChanged<Destination> onItemClicked;

  const DestinationWidget(
      {Key key, this.destination, this.data, this.onItemClicked})
      : super(key: key);

  @override
  _DestinationWidgetState createState() => _DestinationWidgetState();
}

class _DestinationWidgetState extends State<DestinationWidget> {
  List<Destination> _data;
  Destination _destination;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _destination = widget.destination;
    _data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) {
          Destination item = _data[index];
          TextStyle style;
          if (item == _destination) {
            style = TextStyle(fontSize: 18, color: theme.primaryColor);
          } else {
            style = TextStyle(fontSize: 18, color: Color(AppColors.textColor));
          }
          return GestureDetector(
            onTap: () {
              widget.onItemClicked?.call(item);
            },
            child: SizedBox(
              height: _kItemHeight,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${item.name}",
                  style: style,
                ),
              ),
            ),
          );
        },
        itemCount: _data.length,
      ),
    );
  }
}

class DestinationDialog extends StatefulWidget {
  final double width;
  final Destination destination;
  final List<Destination> data;

  const DestinationDialog({Key key, this.width, this.destination, this.data})
      : super(key: key);

  @override
  _DestinationDialogState createState() => _DestinationDialogState();
}

class _DestinationDialogState extends State<DestinationDialog> {
  List<Destination> _data;
  Destination _destination;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _destination = widget.destination;
    _data = widget.data;
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
          width: widget.width,
          height: 5 * _kItemHeight + 20,
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: Container(
            child: DestinationWidget(
              destination: _destination,
              data: _data,
              onItemClicked: handleOk,
            ),
          )),
    );
    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }

  handleOk(Destination item) {
    Navigator.of(context).pop(item);
  }
}

Future<Destination> showDestinationDialog({
  @required BuildContext context,
  Destination destination,
  @required List<Destination> data,
  Offset offset,
  double width,
  Locale locale,
  TransitionBuilder builder,
}) async {
  Widget child = DestinationDialog(
    width: width,
    destination: destination,
    data: data,
  );

  if (locale != null) {
    child = Localizations.override(
      context: context,
      locale: locale,
      child: child,
    );
  }
  return await app_dialog.showDialog<Destination>(
    context: context,
    offset: offset,
    builder: (BuildContext context) {
      return builder == null ? child : builder(context, child);
    },
  );
}
