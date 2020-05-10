import 'package:flutter/material.dart';

import 'package:focum/auth.dart';
import 'package:focum/information.dart';
import 'package:focum/post.dart';
import 'package:focum/viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostListPage extends StatelessWidget {
  final String posterId;
  final String posterName;

  const PostListPage({Key key, this.posterId, this.posterName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: posterId == userId
            ? Text("My Posts")
            : Text(posterName + "'s Posts"),
      ),
      body: new Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('posts')
              .where("userId", isEqualTo: posterId)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return new Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return new Scrollbar(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return new Card(
                      child: ListTile(
                        leading: InkWell(
                          child: Image.network(
                              snapshot.data.documents[index].data['image']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenWrapper(
                                  title: snapshot
                                      .data.documents[index].data['address'],
                                  imageProvider: NetworkImage(snapshot
                                      .data.documents[index].data['image']),
                                ),
                              ),
                            );
                          },
                        ),
                        title: Text('Location: ' +
                            snapshot.data.documents[index].data['address']),
                        trailing: posterId == userId
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  Firestore.instance
                                      .collection('posts')
                                      .document(snapshot
                                          .data.documents[index].documentID)
                                      .delete();
                                },
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostPage(
                                post: PostInformation(
                                  imagePath: snapshot
                                      .data.documents[index].data['image'],
                                  locationName: snapshot
                                      .data.documents[index].data['address'],
                                  userId: snapshot
                                      .data.documents[index].data['userId'],
                                  userPath: snapshot
                                      .data.documents[index].data['userImage'],
                                  userName: snapshot
                                      .data.documents[index].data['userName'],
                                  postId:
                                      snapshot.data.documents[index].documentID,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
