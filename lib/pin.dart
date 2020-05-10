import 'package:flutter/material.dart';

import 'package:focum/information.dart';
import 'package:focum/list.dart';
import 'package:focum/viewer.dart';
import 'package:focum/post.dart';

// Adapted from https://medium.com/flutter-community/add-a-custom-info-window-to-your-google-map-pins-in-flutter-2e96fdca211a

class PostTile extends StatelessWidget {
  final PostInformation post;

  PostTile({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.all(20),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              blurRadius: 20,
              offset: Offset.zero,
              color: Colors.grey.withOpacity(0.5),
            ),
          ],
        ),
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
                      posterId: post.userId,
                      posterName: post.userName,
                    ),
                  ),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.only(
                  left: 10,
                ),
                child: ClipOval(
                  child: Image.network(
                    post.userPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostPage(
                        post: post,
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
                      Text(
                        post.locationName,
                      ),
                      Text(
                        post.userName,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
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
                      title: post.locationName,
                      imageProvider: NetworkImage(post.imagePath),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Image.network(post.imagePath, width: 50, height: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PinInformation {
  List<PostInformation> posts = List<PostInformation>();

  PinInformation({
    String imagePath,
    String userPath,
    String locationName,
    String userName,
    String userId,
    String postId,
  }) {
    this.posts.add(
          PostInformation(
            imagePath: imagePath,
            userPath: userPath,
            locationName: locationName,
            userName: userName,
            userId: userId,
            postId: postId,
          ),
        );
  }
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
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            height: 125,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.currentlySelectedPin.posts.length,
              itemBuilder: (builder, index) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: PostTile(
                    post: widget.currentlySelectedPin.posts[index],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
