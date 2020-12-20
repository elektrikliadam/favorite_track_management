import 'dart:convert';

import 'package:favorite_track_management/modules/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum Status { Liked, Disliked, Neutral }

class TrackTile extends StatefulWidget {
  TrackTile({
    Key key,
    @required this.id,
    @required this.name,
    @required this.band,
    @required this.year,
    @required this.image,
    @required this.authenticatedUser,
    this.status = Status.Neutral,
  }) : super(key: key);

  final String id;
  final String name;
  final String band;
  final int year;
  final String image;
  final User authenticatedUser;
  final Status status;

  @override
  _TrackTileState createState() => _TrackTileState();
}

class _TrackTileState extends State<TrackTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Image.asset("assets/images/${widget.image}"),
        title: Text(widget.name),
        subtitle: Text(widget.band + "\n" + widget.year.toString()),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: Icon(
                  Icons.thumb_down,
                  color: widget.status == Status.Disliked ? Colors.red : null,
                ),
                onPressed: () {}),
            IconButton(
                icon: Icon(
                  Icons.thumb_up,
                  color: widget.status == Status.Liked ? Colors.red : null,
                ),
                onPressed: () {}),
          ],
        ));
  }
}
