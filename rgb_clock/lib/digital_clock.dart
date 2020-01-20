// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

var _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

var _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //  Duration(minutes: 1) -
      //      Duration(seconds: _dateTime.second) -
      //      Duration(milliseconds: _dateTime.millisecond),
      //  _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  bool detectBrightness(int r, int g, int b) {
    /*
    From this W3C document: http://www.webmasterworld.com/r.cgi?f=88&d=9769&url=http://www.w3.org/TR/AERT#color-contrast

    https://webaim.org/resources/contrastchecker/
    
    Color brightness is determined by the following formula: 
    ((Red value X 299) + (Green value X 587) + (Blue value X 114)) / 1000
    
    I know this could be more compact, but I think this is easier to read/explain.
    
    */
    final threshold =
        130; /* about half of 256. Lower threshold equals more dark text on dark background  */

    final cBrightness = ((r * 299) + (g * 587) + (b * 114)) / 1000;
    return (cBrightness > threshold);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 5.5;
    final offset = -fontSize / 7;

    setState(() {
      final r = int.tryParse(hour) * 10;
      final g = int.tryParse(minute) * 4;
      final b = int.tryParse(second) * 4;

      if (detectBrightness(r, b, b)) {
        colors[_Element.text] = Color.fromRGBO(0, 0, 0, 1.0);
        colors[_Element.shadow] = Color.fromRGBO(255, 255, 255, 1.0);
      } else {
        colors[_Element.text] = Color.fromRGBO(255, 255, 255, 1.0);
        colors[_Element.shadow] = Color.fromRGBO(0, 0, 0, 1.0);
      }

      if (Theme.of(context).brightness == Brightness.light) {
        colors[_Element.background] = Color.fromRGBO(r, g, b, 1.0);
      } else {
        colors[_Element.background] =
            Color.fromRGBO(255 - r, 255 - g, 255 - b, 1.0);
      }
    });

    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'PressStart2P',
      fontSize: fontSize,
      shadows: [
        Shadow(
          blurRadius: 0,
          color: colors[_Element.shadow],
          offset: Offset(5, 0),
        ),
      ],
    );

    return Container(
      color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.fromLTRB(1.0, 1.0, 10.0, 1.0),
                      child: Text(hour)),
                  Container(
                    padding: const EdgeInsets.fromLTRB(1.0, 1.0, 10.0, 1.0),
                    child: Text(minute),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(1.0, 1.0, 10.0, 1.0),
                    child: Text(second),
                  ),
                ],
              ),
            ],
          ),

          //child: Stack(
          //  children: <Widget>[
          //    Positioned(left: offset, top: 0, child: Text(hour + minute)),
          //    Positioned(right: offset, bottom: offset, child: Text(second)),
          //  ],
          //),
        ),
      ),
    );
  }
}
