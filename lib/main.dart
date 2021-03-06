import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_player/songs.dart';
import 'package:music_player/theme.dart';
import 'package:meta/meta.dart';
import 'package:fluttery/gestures.dart';

import 'bottom_controls.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios),
          color: const Color(0xFFDDDDDD),
          onPressed: () {},
        ),
        title: Text(''),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.menu),
            color: const Color(0xFFDDDDDD),
            onPressed: () {},
          ),
        ],
      ),
      body: new Column(
        children: <Widget>[
          //seek bar
          new Expanded(
            child: new RadialSeekBar(),
          ),

          //visualizer
          new Container(
            width: double.infinity,
            height: 125.0,
          ),

          //song title, artist name, and controls
          new BottomControls()
        ],
      ),
    );
  }
}

class RadialSeekBar extends StatefulWidget {
  final double seekPercent;

  RadialSeekBar({
    this.seekPercent = 0.0,
  });
  @override
  RadialSeekBarState createState() {
    return new RadialSeekBarState();
  }
}

class RadialSeekBarState extends State<RadialSeekBar> {
  
  double _seekPercent = 0.25;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;

  @override
  void initState(){
    super.initState();
    _seekPercent = widget.seekPercent;
  }
  @override
  void didUpdateWidget(RadialSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _seekPercent = widget.seekPercent;
  }

  void _OnDragStart(PolarCoord coord) {
    _startDragCoord = coord;
    _startDragPercent = _seekPercent;
  }

  void _OnDragUpdate(PolarCoord coord) {
    final dragAngle = coord.angle - _startDragCoord.angle;
    final dragPercent = dragAngle / (2 * pi);
    setState(() {
      _currentDragPercent = (_startDragPercent + dragPercent) % 1.0;
    });
  }

  void _OnDragEnd() {
    setState(() {
      _seekPercent = _currentDragPercent;
      _currentDragPercent = null;
      _startDragCoord = null;
      _startDragPercent = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new RadialDragGestureDetector(
      onRadialDragStart: _OnDragStart,
      onRadialDragUpdate: _OnDragUpdate,
      onRadialDragEnd: _OnDragEnd,
      child: new Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: new Center(
          child: new Container(
            width: 140.0,
            height: 140.0,
            child: new RadialProgressBar(
              trackColor: const Color(0xFFDDDDDD),
              progressPercent: _currentDragPercent ?? _seekPercent,
              progressColor: accentColor,
              thumbPosition: _currentDragPercent ?? _seekPercent,
              thumbColor: lightAccentColor,
              innerPadding: const EdgeInsets.all(10.0),
              outerPadding: const EdgeInsets.all(10.0),
              child: ClipOval(
                clipper: new CircleClipper(),
                child: new Image.network(
                  demoPlaylist.songs[0].albumArtUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RadialProgressBar extends StatefulWidget {
  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final double progressPercent;
  final double thumbPosition;
  final double thumbSize;
  final Color thumbColor;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final Widget child;

  RadialProgressBar({
    this.trackWidth = 3.0,
    this.trackColor = Colors.grey,
    this.progressWidth = 5.0,
    this.progressColor = Colors.black,
    this.progressPercent = 0.0,
    this.thumbPosition = 0.0,
    this.thumbSize = 10.0,
    this.thumbColor = Colors.black,
    this.outerPadding = const EdgeInsets.all(0.0),
    this.innerPadding = const EdgeInsets.all(0.0),
    this.child,
  });

  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {
  EdgeInsets _insetsForPainter() {
    //make room for the painted track, progress and thumb.
    // we divide by 2.0 because we want to allow flush painitng
    // against the track, so we only need to account the thickness
    //outside the track, not inside.
    final outerThickness =
        max(widget.trackWidth, max(widget.progressWidth, widget.thumbSize)) /
            2.0;
    return new EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outerPadding,
      child: CustomPaint(
        foregroundPainter: new RadialProgressBarPainter(
          trackWidth: widget.trackWidth,
          trackColor: widget.trackColor,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          progressPercent: widget.progressPercent,
          thumbSize: widget.thumbSize,
          thumbColor: widget.thumbColor,
          thumbPosition: widget.thumbPosition,
        ),
        child: Padding(
          padding: _insetsForPainter() + widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }
}

class RadialProgressBarPainter extends CustomPainter {
  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final Paint progressPaint;
  final double progressPercent;
  final double thumbPosition;
  final double thumbSize;
  final Paint thumbPaint;

  RadialProgressBarPainter({
    @required this.trackWidth,
    @required trackColor,
    @required this.progressWidth,
    @required progressColor,
    @required this.progressPercent,
    @required this.thumbPosition,
    @required this.thumbSize,
    @required thumbColor,
  })  : trackPaint = new Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth,
        progressPaint = new Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWidth
          ..strokeCap = StrokeCap.round,
        thumbPaint = new Paint()
          ..color = thumbColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final outerThickness = max(trackWidth, max(progressWidth, thumbSize));
    final constraineSize =
        new Size(size.width - outerThickness, size.height - outerThickness);

    final center = new Offset(size.width, size.height) / 2;
    final radius = min(constraineSize.width, constraineSize.height) / 2;
    // paint track
    canvas.drawCircle(center, radius, trackPaint);

    //paint progress
    final progressAngle = 2 * pi * progressPercent;
    canvas.drawArc(
        new Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        -pi / 2,
        progressAngle,
        false,
        progressPaint);

    //paint thumb
    final thumbAngle = 2 * pi * thumbPosition - (pi / 2);
    final thumbx = cos(thumbAngle) * radius;
    final thumby = sin(thumbAngle) * radius;
    final thumbCenter = new Offset(thumbx, thumby) + center;
    final thumbRadius = thumbSize / 2;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
