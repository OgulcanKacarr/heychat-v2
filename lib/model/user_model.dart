import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  //Bir kullanıcı oluşturulduğunda ve sonrasında kullanıcıda olması gerekenler

  /*
 uid: Kullanıcının benzersiz kimlik numarası (UID).
email: Kullanıcının e-posta adresi.
username: Kullanıcı adı.
displayName: Kullanıcının görüntülenen adı.
bio: Kullanıcının profilinde gösterilecek kısa biyografi.
profileImageUrl: Profil fotoğrafının URL'si.
coverImageUrl: Kapak fotoğrafının URL'si.
followers: Kullanıcıyı takip eden diğer kullanıcıların listesi.
following: Kullanıcının takip ettiği diğer kullanıcıların listesi.
friends: Kullanıcının arkadaşları.
friendRequests: Kullanıcının gönderdiği/aldığı arkadaşlık istekleri.
posts: Kullanıcının paylaştığı postların listesi.
 */

  String uid;
  String email;
  String username;
  String displayName;
  String bio;
  String profileImageUrl;
  String coverImageUrl;
  bool isOnline;
  List<String>? followers;
  List<String>? following;
  List<String>? friends;
  List<String>? friendRequests;
  List<String>? posts;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    this.bio = '',
    this.isOnline = false,
    this.profileImageUrl = '',
    this.coverImageUrl = '',
    this.followers = const [],
    this.following = const [],
    this.friends = const [],
    this.friendRequests = const [],
    this.posts = const [],
  });

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,) {
    final data = snapshot.data();
    return UserModel(
      uid: data?['uid'],
      email: data?['email'],
      username: data?['username'],
      displayName: data?['displayName'],
      bio: data?['bio'],
      isOnline: data?['isOnline'],
      profileImageUrl: data?['profileImageUrl'],
      coverImageUrl: data?['coverImageUrl'],
      followers: data?['followers'] is Iterable ? List.from(data?['followers']) : null,
      following: data?['following'] is Iterable ? List.from(data?['following']) : null,
      friends: data?['friends'] is Iterable ? List.from(data?['friends']) : null,
      friendRequests: data?['friendRequests'] is Iterable ? List.from(data?['friendRequests']) : null,
      posts: data?['posts'] is Iterable ? List.from(data?['posts']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (uid != null) "uid": uid,
      if (email != null) "email": email,
      if (username != null) "username": username,
      if (displayName != null) "displayName": displayName,
      if (bio != null) "bio": bio,
      if (isOnline != null) "isOnline": bio,
      if (profileImageUrl != null) "profileImageUrl": profileImageUrl,
      if (coverImageUrl != null) "coverImageUrl": coverImageUrl,
      if (followers != null) "followers": followers,
      if (following != null) "following": following,
      if (friends != null) "friends": friends,
      if (friendRequests != null) "friendRequests": friendRequests,
      if (posts != null) "posts": posts,
    };
  }


}
