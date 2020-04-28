import 'package:flutter/material.dart';

import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focum/information.dart';
import 'package:focum/auth.dart';
import 'package:focum/list.dart';

class PostPage extends StatefulWidget {
  final PostInformation post;

  PostPage({this.post});

  @override
  PostPageState createState() => PostPageState();
}

class PostPageState extends State<PostPage> {
  final commentController = TextEditingController();

  void createComment(text) {
    Firestore.instance.collection('comments').document().setData({
      'postId': widget.post.postId,
      'text': text,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
    });
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.userName + "'s Post"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.width / 1.5,
                    child: ClipRect(
                      child: PhotoView(
                        imageProvider: NetworkImage(widget.post.imagePath),
                        maxScale: PhotoViewComputedScale.covered * 2.0,
                        minScale: PhotoViewComputedScale.contained * 0.8,
                        initialScale: PhotoViewComputedScale.contained,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.width,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance
                            .collection('comments')
                            .where("postId", isEqualTo: widget.post.postId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return new Text('Error: ${snapshot.error}');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        margin: EdgeInsets.only(left: 10),
                                        child: ClipOval(
                                          child: Image.network(
                                            snapshot.data.documents[index]
                                                .data['userImage'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        snapshot
                                            .data.documents[index].data['text'],
                                      ),
                                      subtitle: Text(
                                        snapshot.data.documents[index]
                                            .data['userName'],
                                      ),
                                      trailing: snapshot.data.documents[index]
                                                  .data['userId'] ==
                                              userId
                                          ? IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                Firestore.instance
                                                    .collection('comments')
                                                    .document(snapshot
                                                        .data
                                                        .documents[index]
                                                        .documentID)
                                                    .delete();
                                              },
                                            )
                                          : null,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PostListPage(
                                              posterId: snapshot
                                                  .data
                                                  .documents[index]
                                                  .data['userId'],
                                              posterName: snapshot
                                                  .data
                                                  .documents[index]
                                                  .data['userName'],
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
                  ),
                  Material(
                    elevation: 20.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(3.0),
                        ),
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Leave a comment',
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 20.0,
                            ),
                            onPressed: () {
                              commentController.clear();
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                        ),
                        onSubmitted: (String text) {
                          createComment(text);
                          commentController.clear();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
