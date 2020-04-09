import 'package:flutter/material.dart';

import 'package:focum/auth.dart';
import 'package:focum/login.dart';
import 'package:focum/upload.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Focum"),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              signOutGoogle();
              Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Upload Image'),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => UploadPage()));
          },
        ),
      ),
    );
  }
}
