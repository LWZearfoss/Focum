import 'dart:io';

import 'package:flutter/material.dart';
import 'package:focum/home.dart';
import 'package:focum/login.dart';
import 'package:path/path.dart' as Path;

import 'package:focum/api_key.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:exif/exif.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';

double toDecimal(List coordinates) {
  return double.parse(coordinates[0].toString()) +
      double.parse(coordinates[1].toString()) / 60 +
      (double.parse(coordinates[2].toString().split('/')[0]) /
              double.parse(coordinates[2].toString().split('/')[1])) /
          3600;
}

List<double> getCoordinates(Map<String, IfdTag> exif) {
  if (exif.containsKey('GPS GPSLatitudeRef')) {
    double latitude = (exif['GPS GPSLatitudeRef'].toString() == 'N' ? 1 : -1) *
        toDecimal(exif['GPS GPSLatitude'].values);
    double longitude =
        (exif['GPS GPSLongitudeRef'].toString() == 'E' ? 1 : -1) *
            toDecimal(exif['GPS GPSLongitude'].values);
    return [latitude, longitude];
  } else {
    return null;
  }
}

Future<String> uploadImage(image) async {
  final StorageReference ref = FirebaseStorage.instance
      .ref()
      .child('images/${Path.basename(image.path)}}');
  final StorageUploadTask uploadTask = ref.putFile(
    image,
    StorageMetadata(
      contentLanguage: 'en',
    ),
  );
  final downloadURL = await (await uploadTask.onComplete).ref.getDownloadURL();
  return downloadURL.toString();
}

Future<void> createPost(String downloadURL, List coordinates) async {
  String address = (await Geolocator()
          .placemarkFromCoordinates(coordinates[0], coordinates[1]))[0]
      .thoroughfare;
  Firestore.instance.collection('posts').document().setData({
    'image': downloadURL,
    'location': GeoPoint(coordinates[0], coordinates[1]),
    'address': address,
  });
}

Widget sourceAlert(context) {
  return AlertDialog(
    title: Text(
      "Select Image Source",
      textAlign: TextAlign.center,
    ),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        MaterialButton(
          child: Icon(Icons.camera_alt),
          onPressed: () => Navigator.pop(context, ImageSource.camera),
        ),
        MaterialButton(
          child: Icon(Icons.image),
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ],
    ),
  );
}

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File _image;
  List _coordinates;

  Future getImage() async {
    while (!await Permission.locationWhenInUse.isGranted) {
      await Permission.locationWhenInUse.request();
    }
    final imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) => sourceAlert(context),
    );
    if (imageSource == null) {
      _image = _coordinates = null;
    } else {
      _image = await ImagePicker.pickImage(source: imageSource);
      if (_image == null) {
        _coordinates = null;
      } else if (imageSource == ImageSource.camera) {
        Position position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        _coordinates = [position.latitude, position.longitude];
      } else if (imageSource == ImageSource.gallery) {
        _coordinates =
            getCoordinates(await readExifFromBytes(await _image.readAsBytes()));
        if (_coordinates == null) {
          LocationResult result = await showLocationPicker(context, apiKey);
          _coordinates = result == null
              ? null
              : [result.latLng.latitude, result.latLng.longitude];
        }
      }
    }
    // set these two buttons to the button. If image is not null, render button.
//    createPost(await uploadImage(_image), _coordinates);
    setState(() {});
  }

  Future _upLButton() async {
    createPost(await uploadImage(_image), _coordinates);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FOCUM'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pinkAccent, Colors.blueAccent]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: _image == null && _coordinates == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            Text(
                              'No Image Selected',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(-1.0, -1.0),
                                        color: Colors.black),
                                    Shadow(
                                        // bottomRight
                                        offset: Offset(1.0, -1.0),
                                        color: Colors.black),
                                    Shadow(
                                        // topRight
                                        offset: Offset(1.0, 1.0),
                                        color: Colors.black),
                                    Shadow(
                                        // topLeft
                                        offset: Offset(-1.0, 1.0),
                                        color: Colors.black),
                                  ]),
                            ),
                            Text(
                              'No Location Data.',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(-1.0, -1.0),
                                        color: Colors.black),
                                    Shadow(
                                        // bottomRight
                                        offset: Offset(1.0, -1.0),
                                        color: Colors.black),
                                    Shadow(
                                        // topRight
                                        offset: Offset(1.0, 1.0),
                                        color: Colors.black),
                                    Shadow(
                                        // topLeft
                                        offset: Offset(-1.0, 1.0),
                                        color: Colors.black),
                                  ]),
                            ),
                            OutlineButton.icon(
                                padding: const EdgeInsets.all(20.0),
                                textColor: Colors.white,
                                borderSide: BorderSide(color: Colors.black87),
                                highlightedBorderColor: Colors.white,
                                onPressed: () {
                                  getImage();
                                },
                                icon: Icon(Icons.add_a_photo),
                                label: Text("Let's take a photo"))
                          ])
                    : _image == null
                        ? Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'No Image Selected. Please Retake Image.',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                            // bottomLeft
                                            offset: Offset(-1.0, -1.0),
                                            color: Colors.black),
                                        Shadow(
                                            // bottomRight
                                            offset: Offset(1.0, -1.0),
                                            color: Colors.black),
                                        Shadow(
                                            // topRight
                                            offset: Offset(1.0, 1.0),
                                            color: Colors.black),
                                        Shadow(
                                            // topLeft
                                            offset: Offset(-1.0, 1.0),
                                            color: Colors.black),
                                      ]),
                                ),
                              ),
                              RaisedButton.icon(
                                  onPressed: () {
                                    getImage();
                                  },
                                  icon: Icon(Icons.add_a_photo),
                                  label: Text("Retake Image"))
                            ],
                          )
                        : _coordinates == null
                            ? Column(
                                children: <Widget>[
                                  Center(
                                    child: Text(
                                      'No Location Data. Please Retake Image with Location.',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                                // bottomLeft
                                                offset: Offset(-1.0, -1.0),
                                                color: Colors.black),
                                            Shadow(
                                                // bottomRight
                                                offset: Offset(1.0, -1.0),
                                                color: Colors.black),
                                            Shadow(
                                                // topRight
                                                offset: Offset(1.0, 1.0),
                                                color: Colors.black),
                                            Shadow(
                                                // topLeft
                                                offset: Offset(-1.0, 1.0),
                                                color: Colors.black),
                                          ]),
                                    ),
                                  ),
                                  RaisedButton.icon(
                                      onPressed: () {
                                        getImage();
                                      },
                                      icon: Icon(Icons.repeat),
                                      label: Text("Retake Image"))
                                ],
                              )
                            : Column(
                                children: <Widget>[
                                  Image.file(_image),
                                  RaisedButton.icon(
                                      onPressed: () {
                                        _upLButton();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage()));
                                      },
                                      icon: Icon(Icons.arrow_upward),
                                      label: Text("Upload")),
                                  RaisedButton.icon(
                                      onPressed: () {
                                        getImage();
                                      },
                                      icon: Icon(Icons.repeat),
                                      label: Text("Retake Image"))
                                ],
                              )),
          ],
        ),
      ),
    );
  }
}
