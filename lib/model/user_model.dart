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
  List<String>? friends;
  List<String>? friendRequests;
  List<String>? posts;

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
      friends: data?['friends'] is Iterable ? List.from(data?['friends']) : null,
      friendRequests: data?['friendRequests'] is Iterable ? List.from(data?['friendRequests']) : null,
      posts: data?['posts'] is Iterable ? List.from(data?['posts']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      "email": email,
      "username": username,
      "displayName": displayName,
      "bio": bio,
      "isOnline": isOnline,
      "profileImageUrl": profileImageUrl,
      "coverImageUrl": coverImageUrl,
      "friends": friends,
      "friendRequests": friendRequests,
      "posts": posts,
    };
  }

  @override
  String toString() {
    return 'UserModel(displayName: $displayName, email: $email, bio: $bio, username: $username, profileImageUrl: $profileImageUrl, coverImageUrl: $coverImageUrl)';
  }
}
