
import 'package:flutter/material.dart';
import 'package:music_player/songs.dart';

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
            child: new Center(
              child: new Container(
                width: 125.0,
                height: 125.0,
                
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

