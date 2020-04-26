import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;

import 'package:focum/api_key.dart';

import 'package:photo_view/photo_view.dart';
import 'package:focum/auth.dart';
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
  Placemark placemark = (await Geolocator()
          .placemarkFromCoordinates(coordinates[0], coordinates[1]))[0];
  String address = placemark.subThoroughfare + ' ' + placemark.thoroughfare + ', ' + placemark.locality + ' ' + placemark.postalCode;
    
  Firestore.instance.collection('posts').document().setData({
    'image': downloadURL,
    'location': GeoPoint(coordinates[0], coordinates[1]),
    'address': address,
    'userId': userId,
    'userName': userName,
    'userImage': userImage,
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
        title: Text('Upload'),
      ),
      body: Container(
          child: _image == null || _coordinates == null
              ? Flex(
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
                              color: Color(0xFF9EA9DA),
                              textColor: Colors.white,
                              onPressed: () {
                                getImage();
                              },
                              icon: Icon(Icons.add_a_photo),
                              label: Text("Create post"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints.expand(
                        width: MediaQuery.of(context).size.width,
                      ),
                      child: PhotoView(
                        imageProvider: FileImage(_image),
                        initialScale: PhotoViewComputedScale.covered,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        FlatButton.icon(
                          color: Color(0x50000000),
                          textColor: Colors.white,
                          onPressed: () {
                            _upLButton();
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_upward),
                          label: Text("Upload"),
                        ),
                        FlatButton.icon(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          color: Color(0x50000000),
                          textColor: Colors.white,
                          onPressed: () {
                            getImage();
                          },
                          icon: Icon(Icons.repeat),
                          label: Text("Retake Image"),
                        ),
                      ],
                    ),
                  ],
                )),
    );
  }
}
