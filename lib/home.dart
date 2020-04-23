import 'package:flutter/material.dart';

import 'package:focum/auth.dart';
import 'package:focum/login.dart';
import 'package:focum/list.dart';
import 'package:focum/upload.dart';
import 'package:focum/map.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Focum, " + userName),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              signOutGoogle();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.pinkAccent, Colors.blueAccent]
            ),
          ),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton.icon(onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => PostMapPage()));},
                        icon: Icon(Icons.map),
                        label: Text("Map"),
                        color: Colors.blue,
                      ),
                      RaisedButton.icon(onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => UploadPage()));},
                        icon: Icon(Icons.photo_camera),
                        label: Text("Camera"),
                        color: Colors.orangeAccent,
                      ),
                      RaisedButton.icon(onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => PostListPage(posterId: userId, posterName: userName,)));},
                          icon: Icon(Icons.photo),
                          label: Text("Gallery"),
                          color: Colors.lightGreen
                      ),
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
