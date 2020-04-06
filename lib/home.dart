import 'package:flutter/material.dart';

import 'package:focum/upload.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Focum"),
      ),
      body: Center(
        child: RaisedButton( child: Text('Upload Image'), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UploadPage()));
        },),
      ),
    );
  }
}
