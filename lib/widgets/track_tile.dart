import 'package:flutter/material.dart';

class TrackTile extends StatefulWidget {
  TrackTile({
    Key key,
    @required this.id,
    @required this.name,
    @required this.band,
    @required this.year,
    @required this.image,
  }) : super(key: key);

  final String id;
  final String name;
  final String band;
  final int year;
  final String image;

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
    );
  }
}
