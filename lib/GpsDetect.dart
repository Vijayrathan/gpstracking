import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geofencing/geofencing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gpstracking/main.dart';


class Gps extends StatefulWidget {
  final token;
  Gps(this.token);
  @override
  _GpsState createState() => _GpsState();
}

class _GpsState extends State<Gps> {
  String geofenceState = 'N/A';
  List<String> registeredGeofences = [];
  double latitude ;
  double longitude;
  double radius = 10.0;
  final firestore=FirebaseFirestore.instance;

  Future<dynamic> currentLoc()async{
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
    firestore.collection("gps").add({
      "latitude": latitude,
      "longitude": longitude,
      "timestamp": DateTime.now(),
      "id": token
    });
  }
  ReceivePort port = ReceivePort();
  final List<GeofenceEvent> triggers = <GeofenceEvent>[
    GeofenceEvent.enter,
    GeofenceEvent.dwell,
    GeofenceEvent.exit
  ];
  final AndroidGeofencingSettings androidSettings = AndroidGeofencingSettings(
      initialTrigger: <GeofenceEvent>[
        GeofenceEvent.enter,
        GeofenceEvent.exit,
        GeofenceEvent.dwell
      ],
      loiteringDelay: 1000 * 60);

  @override
  void initState() {
    super.initState();
    currentLoc();
    IsolateNameServer.registerPortWithName(
        port.sendPort, 'geofencing_send_port');
    port.listen((dynamic data) {
      print('Event: $data');
      setState(() {
        geofenceState = data;
      });
    });
    initPlatformState();
  }

  static void callback(List<String> ids, Location l, GeofenceEvent e) async {
    print('Fences: $ids Location $l Event: $e');
    final SendPort send =
    IsolateNameServer.lookupPortByName('geofencing_send_port');
    send?.send(e.toString());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    print('Initializing...');
    await GeofencingManager.initialize();
    print('Initialization done');
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
                    Text('Current state: $geofenceState'),
                    Center(
                      child: RaisedButton(
                        child: const Text('Register'),
                        onPressed: () {
                          if (latitude == null) {
                            setState(() => latitude = 0.0);
                          }
                          if (longitude == null) {
                            setState(() => longitude = 0.0);
                          }
                          if (radius == null) {
                            setState(() => radius = 0.0);
                          }
                          GeofencingManager.registerGeofence(
                              GeofenceRegion(
                                  'mtv', latitude, longitude, radius, triggers,
                                  androidSettings: androidSettings),
                              callback).then((_) {
                            GeofencingManager.getRegisteredGeofenceIds().then((value) {
                              setState(() {
                                registeredGeofences = value;
                              });
                            });
                          });
                        },
                      ),
                    ),
                    Text('Registered Geofences: $registeredGeofences'),
                    Center(
                      child: RaisedButton(
                        child: const Text('Unregister'),
                        onPressed: () =>
                            GeofencingManager.removeGeofenceById('mtv').then((_) {
                              GeofencingManager.getRegisteredGeofenceIds().then((value){
                                setState(() {
                                  registeredGeofences = value;
                                });
                              });
                            }),
                      ),
                    ),
                  ]))),
    );
  }
}