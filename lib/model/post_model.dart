import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String postId;
  String userId;
  String imageUrl;
  String caption;
  List<String> likes;
  List<String> comments;

  PostModel({
    required this.postId,
    required this.userId,
    required this.imageUrl,
    this.caption = '',
    this.likes = const [],
    this.comments = const [],
  });

  factory PostModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PostModel(
      postId: data['postId'],
      userId: data['userId'],
      imageUrl: data['imageUrl'],
      caption: data['caption'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      comments: List<String>.from(data['comments'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': likes,
      'comments': comments,
    };
  }
}
