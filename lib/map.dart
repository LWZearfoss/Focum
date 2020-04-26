import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:focum/pin.dart';

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
  PinInformation currentlySelectedPin = PinInformation(
      imagePath: '', userPath: '', locationName: '', userName: '');

  @override
  void initState() {
    listenPosts();
    super.initState();
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
  }

  listenPosts() {
    Stream<QuerySnapshot> streamPosts =
        Firestore.instance.collection('posts').snapshots();
    streamPosts.listen((snapshot) {
      snapshot.documents.forEach((document) {
        initMarker(document.data, document.documentID);
      });
    });
  }

  initMarker(post, postId) {
    final MarkerId markerId = MarkerId(postId);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(post['location'].latitude, post['location'].longitude),
      onTap: () {
        setState(() {
          currentlySelectedPin = PinInformation(
            imagePath: post['image'],
            locationName: post['address'],
            userName: post['userName'],
            userPath: post['userImage'],
            userId: post['userId']
          );
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
