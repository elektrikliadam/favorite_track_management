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
  Status _fetchedStatus = Status.Neutral;

  @override
  void initState() {
    fetchStatus();
    super.initState();
  }

  Future<Null> fetchStatus() async {
    try {
      final http.Response response = await http.get(
          'https://favorite-track-management-default-rtdb.firebaseio.com/users/${widget.authenticatedUser.id}/tracks/${widget.id}.json?auth=${widget.authenticatedUser.token}');
      final Map<String, dynamic> _trackData = json.decode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("Couldn't fetch the tracks");
        return;
      }
      setState(() {
        _fetchedStatus = _trackData["status"];
      });

      return;
    } catch (error) {
      print(error.toString());
      debugPrint("Unkown error while fetching track");
      return;
    }
  }

  Future<bool> updateStatus(Status changedStatus) async {
    final Map<String, dynamic> _tempTrackData = {
      "status": changedStatus.index,
    };
    try {
      final http.Response response = await http.put(
          'https://favorite-track-management-default-rtdb.firebaseio.com/users/${widget.authenticatedUser.id}/tracks/${widget.id}.json?auth=${widget.authenticatedUser.token}',
          body: json.encode(_tempTrackData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("Connection error while updating track");
        return false;
      }

      debugPrint("Track updated successfully");
      setState(() {});

      return true;
    } catch (error) {
      return false;
    }
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
                  color: _fetchedStatus == Status.Disliked ? Colors.red : null,
                ),
                onPressed: () {
                  updateStatus(Status.Disliked);
                  _fetchedStatus = Status.Disliked;
                }),
            IconButton(
                icon: Icon(
                  Icons.thumb_up,
                  color: _fetchedStatus == Status.Liked ? Colors.red : null,
                ),
                onPressed: () {
                  updateStatus(Status.Liked);
                  _fetchedStatus = Status.Liked;
                }),
          ],
        ));
  }
}
