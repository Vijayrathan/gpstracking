import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gpstracking/main.dart';
import 'package:geodesy/geodesy.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Gps extends StatefulWidget {
  final token;
  Gps(this.token);
  @override
  _GpsState createState() => _GpsState();
}

class _GpsState extends State<Gps> {
  double latitude;
  double longitude;
  double radius = 10.0;
  final firestore = FirebaseFirestore.instance;
  Geodesy geodesy = Geodesy();
  List<LatLng> geofencedPoints = [];
  var resListLat = [];
  var resListLong = [];
  var id;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<dynamic> currentLoc() async {
    await Geolocator.requestPermission();
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      latitude = position.latitude;
      longitude = position.longitude;
      //print(latitude);
    } catch (e) {
      print(e);
    }
    if (latitude != null && longitude != null) {
      firestore.collection("gps").add({
        "latitude": latitude,
        "longitude": longitude,
        "timestamp": DateTime.now().hour,
        "id": token
      });
    } else {
      print(Exception("Null lat and long"));
    }
  }

  Future<List<LatLng>> tracker() async {
    var result = await firestore
        .collection("gps")
        .where("timestamp", isEqualTo: DateTime.now().hour)
        .get();
    result.docs.forEach((res) async {
      resListLat.add(res.data()["latitude"]);
      resListLong.add(res.data()["longitude"]);
    });
    print(resListLat);
    print(resListLong);
  }

  List<LatLng> fetch() {
    for (int item = 0; item < resListLat.length; item++) {
      final point = LatLng(latitude, longitude);
      print(point);
      final pointsToCheck = <LatLng>[
        LatLng(resListLat[item], resListLong[item])
      ];
      final distance = 5;
      geofencedPoints =
          geodesy.pointsInRange(point, pointsToCheck, distance).toList();
      print(geofencedPoints);
    }
  }

  dynamic result() async {
    var col = await firestore
        .collection("gps")
        .where("timestamp", isEqualTo: DateTime.now().hour)
        .get();
    col.docs.forEach((element) async{
      for (int i = 0; i < geofencedPoints.length; i++) {
        if (geofencedPoints[i] ==
            LatLng(element.data()["latitude"], element.data()["longitude"])) {
            id = await element.data()["id"];
          if(id==token){
            print("Only you");
          }
          else{
             return id;
          }
        }
        else{
          print("No-onee");
        }
      }
    });
  }
  Future onSelectNotification(String payload) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewScreen(
        payload: payload,
      );
    }));
  }

    showNotification() async {
      var android = new AndroidNotificationDetails(
          'id', 'channel ', 'description',
          priority: Priority.high, importance: Importance.max);
      var iOS = new IOSNotificationDetails();
      var platform = new NotificationDetails(android:android);
      await flutterLocalNotificationsPlugin.show(
          0, 'Social distancing', 'You are not following social distancing', platform,
          payload: 'Welcome to the Local Notification demo ');
    }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(android:
        initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
    currentLoc();
    tracker();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('TRACKING'),
          ),
          body: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Current state:'),
                    Center(
                      child: RaisedButton(
                          child: const Text('Register'),
                          onPressed: () async{
                            fetch();
                            result();
                           await showNotification();
                          }),
                    ),
                  ]))),
    );
  }
}
class NewScreen extends StatelessWidget {
  String payload;

  NewScreen({
    @required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(payload),
      ),
    );
  }
}
