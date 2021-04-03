import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Maps extends StatefulWidget {
  final latitude, longitude;

  Maps({this.latitude, this.longitude});

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  GoogleMapController myController;
  BitmapDescriptor customIcon1;

  Set<Marker> markers;

  createMarker(context) {
    if (customIcon1 == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(context);

      BitmapDescriptor.fromAssetImage(configuration, 'assets/images/fire.png')
          .then((icon) {
        setState(() {
          customIcon1 = icon;
        });
      });
    }
  }
  Future<dynamic> currentLoc() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      latitude = position.latitude;
      longitude = position.longitude;
      //print(latitude);
    } catch (e) {
      print(e);
    }
  }

  final LatLng _center = const LatLng(12.9764088, 80.2268982);

  void _onMapCreated(GoogleMapController controller) {
    myController = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    markers = Set.from([]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition:
                  CameraPosition(target: LatLng(latitude,longitude), zoom: 18.0, bearing: 15.0),
              markers: markers,
              onTap: (pos) {
                print(pos);
                Marker f = Marker(
                    markerId: MarkerId('1'),
                    icon: customIcon1,
                    position: LatLng(latitude, longitude),
                    onTap: () {});

                setState(() {
                  markers.add(f);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  onPressed: () => print('You have pressed the button'),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.map, size: 30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Faulters extends StatefulWidget {
  @override
  _FaultersState createState() => _FaultersState();
}

class _FaultersState extends State<Faulters> {
  var people = [];
  final _firestore = FirebaseFirestore.instance;

  dynamic violator() async {
    var faulters = await _firestore
        .collection("violators")
        .where("User", isNotEqualTo: null)
        .get();
    faulters.docs.forEach((element) async {
      people.add(element.data()["User"]);
    });
  }

  ListView display() {
    for (int i = 0; i < people.length; i++) {
      ListView(
        children: [
          Container(
            child: Text(people[0], style: TextStyle(fontSize: 22)),
          )
        ],
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    violator();
  }

  @override
  Widget build(BuildContext context) {
    violator();
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/blue_background_201400.jpg'),
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.8), BlendMode.dstATop),
              fit: BoxFit.cover)),
      child: Column(children: [
        Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Container(
              child: SizedBox(
                child: Text(
                  'User token no: $token'
                  '\nE-mail ID : vijay@email.com',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
                width: 600,
                height: 50,
              ),
              margin: EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                color: Colors.indigo,
                border: Border.all(width: 8, color: Colors.indigo),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ))
          ],
        )),
        Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                child: SizedBox(
                  child: Text(
                    'User token no: 97'
                    '\nE-mail ID : vijayk@gmail.com',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                  width: 600,
                  height: 50,
                ),
                margin: EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  border: Border.all(width: 8, color: Colors.indigo),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            )
          ],
        )),
        Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                child: SizedBox(
                  child: Text(
                    'User token no: 79'
                    '\nE-mail ID : example@gmail.com',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                  width: 600,
                  height: 50,
                ),
                margin: EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  border: Border.all(width: 8, color: Colors.indigo),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            )
          ],
        ))
      ]),
    );
  }
}

class TabsStructure extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('SOCIAL DISTANCING'),
            backgroundColor: Colors.indigo,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.map), text: "MAPS"),
                Tab(icon: Icon(Icons.warning), text: "VIOLATORS")
              ],
            ),
          ),
          body: TabBarView(
            children: [Maps(), Faulters()],
          ),
        ),
      ),
    );
  }
}
