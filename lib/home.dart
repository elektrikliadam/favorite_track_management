import 'dart:convert';
import 'package:favorite_track_management/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TrackTile> _trackList = [];

  @override
  void initState() {
    _fetchTracks();
    super.initState();
  }

  Future _fetchTracks() async {
    String jsonString = await rootBundle.loadString('assets/tracks.json');
    final List jsonResponse = json.decode(jsonString);
    List<TrackTile> tempList = [];

    jsonResponse.forEach((element) {
      TrackTile newTile = new TrackTile(
        id: element["_id"],
        band: element["track_band"],
        image: element["image"],
        name: element["track_name"],
        year: element["release_year"],
      );
      tempList.add(newTile);
    });

    setState(() {
      _trackList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Text("Liked Song List"),
                  onPressed: () {},
                ),
                RaisedButton(
                  child: Text("Disliked Song List"),
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _trackList.length,
                itemBuilder: (context, i) {
                  return _trackList[i];
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
