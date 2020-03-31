import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';

double toDecimal(List coordinates) {
  return double.parse(coordinates[0].toString()) +
      double.parse(coordinates[1].toString()) / 60 +
      (double.parse(coordinates[2].toString().split('/')[0]) /
              double.parse(coordinates[2].toString().split('/')[1])) /
          3600;
}

List<double> getCoordinates(Map<String, IfdTag> exif) {
  if (exif.containsKey('GPS GPSLatitudeRef')) {
    double latitude =
        (exif['GPS GPSLatitudeRef'].toString() == 'N' ? 1 : -1) *
            toDecimal(exif['GPS GPSLatitude'].values);
    double longitude = (exif['GPS GPSLongitudeRef'].toString() == 'E' ? 1 : -1) *
        toDecimal(exif['GPS GPSLongitude'].values);
    return [latitude, longitude];
  } else {
    return null;
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  Map<String, IfdTag> _exif;
  var _coordinates;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _image = image;
    _exif = await readExifFromBytes(await image.readAsBytes());
    _coordinates = getCoordinates(_exif);
    setState(() {});

    print(_exif);
    print(_coordinates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Center(
        child: _image == null ? Text('No image selected.') : Image.file(_image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
