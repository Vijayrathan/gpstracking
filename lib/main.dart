import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './GpsDetect.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  Workmanager.registerPeriodicTask(
    "1",
    fetchBackground,
    frequency: Duration(minutes: 2),
  );
  await Firebase.initializeApp();

  runApp(MaterialApp(initialRoute: 'first', routes: {
    'first':(context)=>MyApp(),
    'second':(context)=>Gps(token)
  }));
}
double latitude;
double longitude;
final firestore=FirebaseFirestore.instance;
var email;
var password;
var token;
const fetchBackground = "fetchBackground";
void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
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
        break;
    }
    return Future.value(true);
  });
}


class MyApp extends StatelessWidget {
  final _auth = FirebaseAuth.instance;


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
                    fontSize: 27,
                    color: Colors.white70,
                    fontWeight: FontWeight.w800),
              ),
            ),
            backgroundColor: Colors.indigo,
            elevation: 0.0,
          ),
          extendBodyBehindAppBar: true,
          body: Container(
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
                        style: TextStyle(fontSize: 14),
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
                        style: TextStyle(fontSize: 14),
                      ),
                      alignment: Alignment.center,
                    ),
                    Container(
                      margin: EdgeInsets.all(15.0),
                      child: Center(
                          child: Text(
                        "Token No",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                          hintText: 'Enter Token no here',
                        ),
                        obscureText: true,
                        style: TextStyle(fontSize: 14),
                      ),
                      alignment: Alignment.center,
                    ),
                    Container(
                      margin: EdgeInsets.all(15.0),
                      child: RaisedButton(
                        child: Text("LOGIN"),
                        onPressed: () async {
                          try {
                            final newUser =
                                await _auth.signInWithEmailAndPassword(
                                    email: email, password: password);
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
                        onPressed: () {
                          Navigator.pushNamed(context, "Main");
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
