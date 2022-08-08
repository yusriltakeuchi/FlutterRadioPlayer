import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_radio_player/flutter_radio_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  final playerState = FlutterRadioPlayer.flutter_radio_paused;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  double volume = 0.8;
  FlutterRadioPlayer _flutterRadioPlayer = new FlutterRadioPlayer();

  @override
  void initState() {
    super.initState();
    initRadioService();
  }

  Future<void> initRadioService() async {
    try {
      await _flutterRadioPlayer.init(
        "Flutter Radio Example",
        "Live",
        "https://s2.radio.co/sf58a82d7d/listen",
        "false",
      );
    } on PlatformException {
      print("Exception occurred while trying to register the services.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Radio Player Example'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              StreamBuilder(
                stream: _flutterRadioPlayer.isPlayingStream,
                initialData: widget.playerState,
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  String returnData = snapshot.data!;
                  print("object data: " + returnData);
                  switch (returnData) {
                    case FlutterRadioPlayer.flutter_radio_stopped:
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(),
                        child: Text("Start listening now"),
                        onPressed: () async {
                          await initRadioService();
                        },
                      );
                    case FlutterRadioPlayer.flutter_radio_loading:
                      return Text("Loading stream...");
                    case FlutterRadioPlayer.flutter_radio_error:
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(),
                        child: Text("Retry ?"),
                        onPressed: () async {
                          await initRadioService();
                        },
                      );
                    default:
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            onPressed: () async {
                              print("button press data: " +
                                  snapshot.data.toString());
                              await _flutterRadioPlayer.playOrPause();
                            },
                            icon: snapshot.data ==
                                    FlutterRadioPlayer.flutter_radio_playing
                                ? Icon(Icons.pause)
                                : Icon(Icons.play_arrow),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _flutterRadioPlayer.stop();
                            },
                            icon: Icon(Icons.stop),
                          )
                        ],
                      );
                  }
                },
              ),
              Slider(
                value: volume,
                min: 0,
                max: 1.0,
                onChanged: (value) => setState(
                  () {
                    volume = value;
                    _flutterRadioPlayer.setVolume(volume);
                  },
                ),
              ),
              Text(
                "Volume: " + (volume * 100).toStringAsFixed(0),
              ),
              SizedBox(
                height: 15,
              ),
              Text("Metadata Track "),
              StreamBuilder<String?>(
                initialData: "",
                stream: _flutterRadioPlayer.metaDataStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var json = jsonDecode(snapshot.data as String);
                    return Text(
                      "${json['title']} - ${json['station']}",
                      textAlign: TextAlign.center
                    );
                  }
                  return Text("");
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(),
                child: Text("Change URL"),
                onPressed: () async {
                  _flutterRadioPlayer.setUrl(
                    "https://s2.radio.co/sf58a82d7d/listen",
                    "false",
                  );
                },
              )
            ],
          ),
        ),
        bottomNavigationBar: new BottomNavigationBar(
          currentIndex: this._currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.pages),
              label: "Second Page",
            )
          ],
        ),
      ),
    );
  }
}
