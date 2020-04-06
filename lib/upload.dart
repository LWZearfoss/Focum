import 'dart:io';

import 'package:flutter/material.dart';
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
  var _coordinates;

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
        _coordinates = getCoordinates(await readExifFromBytes(await _image.readAsBytes()));
        if (_coordinates == null) {
          LocationResult result = await showLocationPicker(
              context, "[YOUR API KEY HERE]");
          _coordinates = result == null
              ? null
              : [result.latLng.latitude, result.latLng.longitude];
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Column(
        children: <Widget>[
          Center(
              child: _image == null
                  ? Text('No image selected.')
                  : Image.file(_image)),
          Center(
              child: _coordinates == null
                  ? Text('No location data')
                  : Text(_coordinates[0].toString() +
                      ', ' +
                      _coordinates[1].toString())),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
