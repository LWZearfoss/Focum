import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:focum/pin.dart';

///////////////////////////////////////////////

class PostMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: PostMap(),
    );
  }
}

class PostMap extends StatefulWidget {
  @override
  State<PostMap> createState() => PostMapState();
}

class PostMapState extends State<PostMap> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _locationCamera;
  double pinPosition = -100;
  Map<String, PinInformation> info = <String, PinInformation>{};
  PinInformation currentlySelectedPin = PinInformation(
      imagePath: '', userPath: '', locationName: '', userName: '');
  BitmapDescriptor _pinLocationIcon;

  @override
  void initState() {
    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((position) {
      setState(() {
        _locationCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.4746,
        );
      });
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(.05,.05)), 'assets/pin4.png')
        .then((onValue) {
      _pinLocationIcon = onValue;
    });
    listenPosts();
    super.initState();
  }

  listenPosts() {
    Stream<QuerySnapshot> streamPosts =
        Firestore.instance.collection('posts').snapshots();
    streamPosts.listen((snapshot) {
      info.clear();
      snapshot.documents.forEach((document) {
        initMarker(document.data);
      });
    });
  }

  initMarker(post) {
    final MarkerId markerId = MarkerId(post['address']);
    if (!info.containsKey(post['address'])) {
      info[post['address']] = PinInformation(
        imagePath: post['image'],
        locationName: post['address'],
        userName: post['userName'],
        userPath: post['userImage'],
        userId: post['userId'],
      );
    } else {
      info[post['address']].posts.add(
            PostInformation(
              imagePath: post['image'],
              locationName: post['address'],
              userName: post['userName'],
              userPath: post['userImage'],
              userId: post['userId'],
            ),
          );
    }
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(post['location'].latitude, post['location'].longitude),
      icon: _pinLocationIcon,
      onTap: () {
        setState(() {
          currentlySelectedPin = info[post['address']];
          pinPosition = 0;
        });
      },
    );
    markers[markerId] = marker;
  }

  // Adapted from https://stackoverflow.com/questions/58942707/flutter-firestore-listen-for-document-changes
  @override
  Widget build(BuildContext context) {
    if (_locationCamera == null) {
      return new Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _locationCamera,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              markers: Set<Marker>.of(markers.values),
              onTap: (LatLng location) {
                setState(() {
                  pinPosition = -100;
                });
              },
            ),
            MapPinComponent(
                pinPosition: pinPosition,
                currentlySelectedPin: currentlySelectedPin)
          ],
        ),
      );
    }
  }
}
