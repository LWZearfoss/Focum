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
      body: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: FlatButton.icon(
                    color: Color(0xFF8CA3D1),
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostMapPage()));
                    },
                    icon: Icon(Icons.map),
                    label: Text("Map"),
                  ),
                ),
                Expanded(
                  child: FlatButton.icon(
                    color: Color(0xFF726DA8),
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UploadPage()));
                    },
                    icon: Icon(Icons.photo_camera),
                    label: Text("Camera"),
                  ),
                ),
                Expanded(
                  child: FlatButton.icon(
                    color: Color(0xFF693794),
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostListPage(
                            posterId: userId,
                            posterName: userName,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.photo),
                    label: Text("Gallery"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
