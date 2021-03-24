import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth = FirebaseAuth.instance;
  var email;
  var password;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Center(
                child: Text(
                  "SOCIAL DISTANCING",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: Colors.indigo,
            ),
            body: Container(
              child: ListView(children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          child: Center(child: Text("Email ID")),
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
                        ),
                        alignment: Alignment.center,
                      ),
                      Container(
                        margin: EdgeInsets.all(15.0),
                        child: Center(child: Text("Password")),
                        alignment: Alignment.center,
                      ),
                      Container(
                        child: TextField(
                          textAlign: TextAlign.center,
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter  here',
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                      Container(
                        margin: EdgeInsets.all(15.0),
                        child: RaisedButton(
                          child: Text("Register"),
                          onPressed: () async {
                            try {
                              final newUser =
                              await _auth.createUserWithEmailAndPassword(
                                  email: email, password: password);
                              if (newUser != null) {
                                Navigator.pushNamed(context, 'first');
                              }
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                      )
                    ])
              ]),
            )));
  }
}
