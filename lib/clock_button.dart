import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

enum ButtonType { RaisedButton, FlatButton, OutlineButton }

class ClockButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color disabledColor;
  final TextStyle activeTextStyle;
  final TextStyle disabledTextStyle;
  final ButtonType buttonType;

  const ClockButton({
    Key key,
    @required this.label,
    @required this.onPressed,
    this.color = Colors.white,
    this.disabledColor,
    this.buttonType = ButtonType.RaisedButton,
    this.activeTextStyle = const TextStyle(color: Colors.white),
    this.disabledTextStyle = const TextStyle(color: Colors.white),
  })  : assert(label != null),
        assert(activeTextStyle != null),
        assert(disabledTextStyle != null),
        super(key: key);

  @override
  _ClockBtnState createState() => new _ClockBtnState();
}

class _ClockBtnState extends State<ClockButton> {
  String time = '00:00:00';
  Timer t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(Duration(seconds: 1), (Timer t) => this.updateTime());
  }
  @override
  void dispose() {
    t.cancel();
    super.dispose();
  }

  Widget getChild() {
    return new Container(
      child: new Text(time, style: widget.activeTextStyle,),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.buttonType) {
      case ButtonType.RaisedButton:
        return new RaisedButton(
            disabledColor: widget.disabledColor,
            color: widget.color,
            onPressed: () {
              widget.onPressed();
            },
            child: getChild());
        break;
      case ButtonType.FlatButton:
        return new FlatButton(
            color: widget.color,
            disabledColor: widget.disabledColor,
            onPressed: () {
              widget.onPressed();
            },
            child: getChild());
        break;
      case ButtonType.OutlineButton:
        return new OutlineButton(
            borderSide: new BorderSide(
              color: widget.color,
            ),
            disabledBorderColor: widget.disabledColor,
            onPressed: () {
              widget.onPressed();
            },
            child: getChild());
        break;
    }
    return new Container();
  }

  void updateTime() {
    setState(() {
      time = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }
}
