import 'dart:convert';

import 'package:favorite_track_management/modules/user.dart';
import 'package:favorite_track_management/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainModel extends Model {
  List<TrackTile> trackList = [];
  User _authenticatedUser;
  String _firebaseApiKey;
  Status filteredStatus = Status.Neutral;

  List<TrackTile> get displayTracks {
    if (filteredStatus == Status.Liked) {
      return trackList.where((e) => e.status == Status.Liked).toList();
    } else if (filteredStatus == Status.Disliked) {
      return trackList.where((e) => e.status == Status.Disliked).toList();
    } else {
      return trackList;
    }
  }

  Future loadApiKeys() async {
    String jsonString = await rootBundle.loadString('api_keys.json');
    final jsonResponse = json.decode(jsonString);
    _firebaseApiKey = jsonResponse["firebase"];
  }

  void changeFilteredStatus(Status newStatus) {
    filteredStatus = newStatus;
    notifyListeners();
  }

  Future<Map<String, dynamic>> authenticate() async {
    Map<String, dynamic> _authData = {'returnSecureToken': true};
    http.Response response;

    response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseApiKey',
        body: json.encode(_authData),
        headers: {'Content-Type': 'application/json'});

    bool hasError = true;
    String message = "Something went wrong!";

    final Map<String, dynamic> responseData = json.decode(response.body);
    print(responseData);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      _authenticatedUser =
          User(id: responseData['localId'], token: responseData['idToken']);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));

      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString('userId', responseData['localId']);
      _prefs.setString('token', responseData['idToken']);
      _prefs.setString('refreshToken', responseData['refreshToken']);
      _prefs.setString('expiryTime', expiryTime.toIso8601String());
      print("AUTHENTICATED WITH ${_authenticatedUser.id}");
    } else if (responseData['error']['message'] == 'OPERATION_NOT_ALLOWED') {
      message = "This operation can't be allowed";
    }
    return {'success': !hasError, 'message': message};
  }

  Future fetchTracks() async {
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
        authenticatedUser: _authenticatedUser,
      );
      tempList.add(newTile);
    });

    trackList = tempList;
    notifyListeners();
  }

  Future<bool> updateStatus(
      TrackTile updatedTrackTile, Status changedStatus) async {
    TrackTile newTile = TrackTile(
      authenticatedUser: updatedTrackTile.authenticatedUser,
      band: updatedTrackTile.band,
      id: updatedTrackTile.id,
      image: updatedTrackTile.image,
      name: updatedTrackTile.name,
      year: updatedTrackTile.year,
      status: changedStatus,
    );
    var selectedIndex =
        trackList.indexWhere((element) => element.id == updatedTrackTile.id);

    trackList[selectedIndex] = newTile;

    notifyListeners();

    final Map<String, dynamic> _tempTrackData = {
      "status": changedStatus.index,
    };
    try {
      final http.Response response = await http.put(
          'https://favorite-track-management-default-rtdb.firebaseio.com/users/${_authenticatedUser.id}/tracks/${updatedTrackTile.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(_tempTrackData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("Connection error while updating track");
        return false;
      }

      debugPrint("Track updated successfully");
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }
}
