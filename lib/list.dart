import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class PostListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List"),
      ),
      body: createPostList(),
    );
  }
}

Widget createPostList() {
  return new Scaffold(
    body: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('posts').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  return new ListTile(
                    leading: Image.network(
                        snapshot.data.documents[index].data['image']),
                    subtitle: Text('Location: ' + snapshot.data.documents[index].data['address']),
                  );
                },
              ),
            );
        }
      },
    ),
  );
}
