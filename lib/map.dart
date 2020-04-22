import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
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
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _locationCamera;

  @override
  void initState() {
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

  initMarker(post, postId) {
    final MarkerId markerId = MarkerId(postId);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(post['location'].latitude, post['location'].longitude),
      infoWindow: InfoWindow(title: post['address'])
    );

    //

    markers[markerId] = marker;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('posts').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return new Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting ||
                _locationCamera == null) {
              return new Center(
                child: CircularProgressIndicator(),
              );
            } else {
              for (int i = 0; i < snapshot.data.documents.length; ++i) {
                initMarker(snapshot.data.documents[i].data,
                    snapshot.data.documents[i].documentID);
              }
              return new GoogleMap(
                mapType: MapType.hybrid,
                initialCameraPosition: _locationCamera,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                markers: Set<Marker>.of(markers.values),
              );
            }
          }),
    );
  }
}
