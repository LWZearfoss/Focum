import 'package:flutter/material.dart';

import 'package:photo_view/photo_view.dart'; 

class FullScreenWrapper extends StatelessWidget {
  const FullScreenWrapper({
    this.title,
    this.imageProvider,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition = Alignment.center,
    this.filterQuality = FilterQuality.none,
  });

  final String title;
  final ImageProvider imageProvider;
  final LoadingBuilder loadingBuilder;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment basePosition;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(title),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            extendBodyBehindAppBar: true,
            body: Container(
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              child: PhotoView(
                imageProvider: imageProvider,
                loadingBuilder: loadingBuilder,
                backgroundDecoration: backgroundDecoration,
                minScale: minScale,
                maxScale: maxScale,
                initialScale: initialScale,
                basePosition: basePosition,
                filterQuality: filterQuality,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
