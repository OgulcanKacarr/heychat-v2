import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomNetworkImageCacheWidget extends StatelessWidget {
  String image;

  CustomNetworkImageCacheWidget({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        if (downloadProgress.progress != null) {
          final percent = (downloadProgress.progress! * 100).toStringAsFixed(0);
          return Center(
            child: Text("$percent% done loading"),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
      // Error widget to display if image fails to load
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
