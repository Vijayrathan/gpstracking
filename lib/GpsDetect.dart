import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gpstracking/main.dart';
import 'package:geodesy/geodesy.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Gps extends StatefulWidget {
  final token, geofencedpoint;

  Gps(this.token, this.geofencedpoint);

  @override
  _GpsState createState() => _GpsState();
}

class _GpsState extends State<Gps> {
  double latitude;
  double longitude;
  double radius = 10.0;
  final firestore = FirebaseFirestore.instance;
  Geodesy geodesy = Geodesy();
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
    Navigator.pushNamed(context, 'map');
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
    var platform = new NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.show(0, 'Social distancing',
        'You are not following social distancing', platform,
        payload: 'Welcome to the Local Notification demo ');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initSetttings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
    if (geofencedPoints.length > 0) {
      showNotification();
    }
    currentLoc();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/blue_background_201400.jpg'),
                  colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.8), BlendMode.dstATop),
                  fit: BoxFit.cover)),
          child: Center(
            child: SpinKitChasingDots(
              color: Colors.greenAccent,
              size: 100.0,
            ),
          ),
        ),
      ),
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
