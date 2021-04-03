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
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
            extendBodyBehindAppBar: true,
            body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/blue_background_201400.jpg'),
                      colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(0.8), BlendMode.dstATop),
                      fit: BoxFit.cover)),
              child: ListView(children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          child: Center(
                              child: Text(
                            "Email ID",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                          style: TextStyle(color: Colors.white),
                        ),
                        alignment: Alignment.center,
                      ),
                      Container(
                        margin: EdgeInsets.all(15.0),
                        child: Center(
                            child: Text(
                          "Password",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
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
                          style: TextStyle(color: Colors.white),
                        ),
                        alignment: Alignment.center,
                      ),
                      Container(
                        margin: EdgeInsets.all(15.0),
                        child: RaisedButton(
                          child: Text("Register"),
                          onPressed: () async {
                            if (password.length < 7 || password == null) {
                              Future<void> showMyDialog() async {
                                return showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  // user must tap button!
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(' PASSWORD ERROR!!'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text(
                                                "Password should be atleast 6 characters"),
                                            Text(
                                                'Would you like to approve of this message?'),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Re-enter'),
                                          onPressed: () {
                                            Navigator.pushNamed(context, 'reg');
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }

                              showMyDialog();
                            } else {
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
                            }
                          },
                        ),
                      )
                    ])
              ]),
            )));
  }
}
