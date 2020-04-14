import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final Firestore _database = Firestore.instance;
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    createMarkers();
    super.initState();
  }

  createMarkers() {
    _database.collection('posts').getDocuments().then((posts) {
      if (posts.documents.isNotEmpty) {
        for (int i = 0; i < posts.documents.length; ++i) {
          initMarker(posts.documents[i].data, posts.documents[i].documentID);
        }
      }
    });
  }

  initMarker(post, postId) {
    final MarkerId markerId = MarkerId(postId);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(post['location'].latitude, post['location'].longitude),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        markers: Set<Marker>.of(markers.values),
      ),
    );
  }
}
