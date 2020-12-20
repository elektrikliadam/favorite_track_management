import 'dart:convert';
import 'package:favorite_track_management/scoped_model/main_model.dart';
import 'package:favorite_track_management/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'modules/user.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.model}) : super(key: key);

  final String title;
  final MainModel model;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    _initApp();
    super.initState();
  }

  _initApp() async {
    await widget.model.loadApiKeys();
    await widget.model.authenticate();
    await widget.model.fetchTracks();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
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
                    onPressed: () {
                      model.changeFilteredStatus(Status.Liked);
                    },
                  ),
                  RaisedButton(
                    child: Text("Disliked Song List"),
                    onPressed: () {
                      model.changeFilteredStatus(Status.Disliked);
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: model.displayTracks.length,
                  itemBuilder: (context, i) {
                    return model.displayTracks[i];
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
