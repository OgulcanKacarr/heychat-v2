import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String username;
  String displayName;
  String bio;
  String profileImageUrl;
  String coverImageUrl;
  bool isOnline;
  List<String>? friends;
  List<String>? sentFriendRequests;
  List<String>? receivedFriendRequests;
  List<String>? posts;
  String? token;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    this.bio = '',
    this.isOnline = true,
    this.profileImageUrl = '',
    this.coverImageUrl = '',
    this.friends = const [],
    this.sentFriendRequests = const [],
    this.receivedFriendRequests = const [],
    this.posts = const [],
    this.token = "",
  });

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return UserModel(
      uid: data?['uid'],
      email: data?['email'],
      username: data?['username'],
      displayName: data?['displayName'],
      bio: data?['bio'] ?? '',
      isOnline: data?['isOnline'] ?? true,
      profileImageUrl: data?['profileImageUrl'] ?? '',
      coverImageUrl: data?['coverImageUrl'] ?? '',
      friends: data?['friends'] is List ? List.from(data?['friends']) : null,
      sentFriendRequests: data?['sentFriendRequests'] is List
          ? List.from(data?['sentFriendRequests'])
          : null,
      receivedFriendRequests: data?['receivedFriendRequests'] is List
          ? List.from(data?['receivedFriendRequests'])
          : null,
      posts: data?['posts'] is List ? List.from(data?['posts']) : null,
      token: data?['token'] ?? '',

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'isOnline': isOnline,
      'profileImageUrl': profileImageUrl,
      'coverImageUrl': coverImageUrl,
      'friends': friends,
      'sentFriendRequests': sentFriendRequests,
      'receivedFriendRequests': receivedFriendRequests,
      'posts': posts,
      'token': token,
    };
  }

  @override
  String toString() {
    return 'UserModel(displayName: $displayName, email: $email, bio: $bio, username: $username, profileImageUrl: $profileImageUrl, coverImageUrl: $coverImageUrl)';
  }
}
