import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import './GpsDetect.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import './regUser.dart';
import './mapsView.dart';
import 'package:geodesy/geodesy.dart';

double latitude;
double longitude;
final firestore = FirebaseFirestore.instance;
var email;
var password;
var token;
const fetchBackground = "fetchBackground";

double radius = 10.0;
Geodesy geodesy = Geodesy();
var geofencedPoints = [];
var resListLat = [];
var resListLong = [];
var id;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager.registerPeriodicTask("1", fetchBackground,
      frequency: Duration(minutes: 15), initialDelay: Duration(seconds: 20));
  await Firebase.initializeApp();

  runApp(MaterialApp(initialRoute: 'first', routes: {
    'first': (context) => MyApp(),
    'second': (context) => Gps(token, geofencedPoints),
    'reg': (context) => Register(),
    'map': (context) => TabsStructure()
  }));
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        getLocation();
        break;
    }
    return Future.value(true);
  });
}

void getLocation() async {
  Geolocator.isLocationServiceEnabled().then((value) async {
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
      print(Exception("Null lat  and long"));
    }
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _auth = FirebaseAuth.instance;

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

  Future<List<dynamic>>fetch() async{
    for (int item = 0; item < resListLat.length; item++) {
      final point = LatLng(latitude, longitude);
      print(point);
      final pointsToCheck = <LatLng>[
        LatLng(resListLat[item], resListLong[item])
      ];
      final distance = 5;
      geofencedPoints = geodesy.pointsInRange(point, pointsToCheck, distance);
      print(geofencedPoints);
      return geofencedPoints;
    }
  }

  Future<dynamic> result() async {
    var col = await firestore
        .collection("gps")
        .where("timestamp", isEqualTo: DateTime.now().hour)
        .get();
    col.docs.forEach((element) async {
      for (int i = 0; i < geofencedPoints.length; i++) {
        if (geofencedPoints[i] ==
            LatLng(element.data()["latitude"], element.data()["longitude"])) {
          id = await element.data()["id"];
          if (id == token) {
            print("Only you");
          } else {
            print(id);
            return id;
          }
        } else {
          print("No-one");
        }
      }
    });
  }
  Future<UserCredential> showMyDialog() async {
    return showDialog<UserCredential>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('INCORRECT USER NAME OR PASSWORD!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Please re-enter the correct password"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Re-enter'),
              onPressed: () {
                Navigator.pushNamed(context, 'first');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text(
                "Social distancing",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              image:DecorationImage(
                  image:AssetImage('assets/blue_background_201400.jpg'),
                  colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.8),BlendMode.dstATop),
                  fit: BoxFit.cover
              )
          ),
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        child: Center(
                            child: Text(
                          "Email ID",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                        margin: EdgeInsets.all(15.0),
                        alignment: Alignment.center),
                    Container(
                      child: TextField(
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          email = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter your Email ID ',
                        ),
                        style: TextStyle(fontSize: 14,color: Colors.white),
                      ),
                      alignment: Alignment.center,
                    ),
                    Container(
                      margin: EdgeInsets.all(15.0),
                      child: Center(
                          child: Text(
                        "Password",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                      alignment: Alignment.center,
                    ),
                    Container(
                      child: TextField(
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          password = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Password here',
                        ),
                        obscureText: true,
                        style: TextStyle(fontSize: 14,color: Colors.white),
                      ),
                      alignment: Alignment.center,
                    ),
                    Container(
                      margin: EdgeInsets.all(15.0),
                      child: Center(
                          child: Text(
                        "Token No",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                      )),
                      alignment: Alignment.center,
                    ),
                    Container(
                      child: TextField(
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          token = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Last two digits of your phone number',
                          hintStyle: TextStyle(color: Colors.black)
                        ),
                        style: TextStyle(fontSize: 14,color: Colors.white),
                      ),
                      alignment: Alignment.center,
                    ),
                    Container(
                      margin: EdgeInsets.all(15.0),
                      child: RaisedButton(
                        child: Text("LOGIN"),
                        color: Colors.white70,
                        onPressed: () async {
                          await tracker();
                          await fetch();
                          await(result().whenComplete(() =>firestore.collection("violators").add({"User":token,"time":DateTime.now()}) ));
                          try {
                            final newUser =
                                await _auth.signInWithEmailAndPassword(
                                    email: email, password: password).onError((error, stackTrace) => showMyDialog() );
                            if (newUser != null) {
                              Navigator.pushNamed(context, 'second');
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(15.0),
                      child: RaisedButton(
                        child: Text("New User!! Register Here"),
                        color: Colors.white70,
                        onPressed: () {
                          Navigator.pushNamed(context, "reg");
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
