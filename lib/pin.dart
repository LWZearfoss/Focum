import 'package:flutter/material.dart';

import 'package:focum/list.dart';
import 'package:focum/viewer.dart';

// Adapted from https://medium.com/flutter-community/add-a-custom-info-window-to-your-google-map-pins-in-flutter-2e96fdca211a

class PinInformation {
  String imagePath;
  String userPath;
  String locationName;
  String userName;
  String userId;

  PinInformation(
      {this.imagePath,
      this.userPath,
      this.locationName,
      this.userName,
      this.userId});
}

class MapPinComponent extends StatefulWidget {
  final double pinPosition;
  final PinInformation currentlySelectedPin;

  MapPinComponent({this.pinPosition, this.currentlySelectedPin});

  @override
  State<StatefulWidget> createState() => MapPinComponentState();
}

class MapPinComponentState extends State<MapPinComponent> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      bottom: widget.pinPosition,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(20),
          height: 70,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(50)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostListPage(
                        posterId: widget.currentlySelectedPin.userId,
                        posterName: widget.currentlySelectedPin.userName,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(left: 10),
                  child: ClipOval(
                      child: Image.network(widget.currentlySelectedPin.userPath,
                          fit: BoxFit.cover)),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostListPage(
                          posterId: widget.currentlySelectedPin.userId,
                          posterName: widget.currentlySelectedPin.userName,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(widget.currentlySelectedPin.locationName),
                        Text(widget.currentlySelectedPin.userName),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenWrapper(
                        title: widget.currentlySelectedPin.locationName,
                        imageProvider:
                            NetworkImage(widget.currentlySelectedPin.imagePath),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Image.network(widget.currentlySelectedPin.imagePath,
                      width: 50, height: 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
