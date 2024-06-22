import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:heychat_2/model/post_model.dart';
import 'package:heychat_2/model/user_model.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/utils/snackbar_util.dart';

class FirestoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addUserInfoInDatabase(
      BuildContext context, UserModel user) async {
    try {
      await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(user.uid)
          .set(user.toFirestore())
          .whenComplete(() {
        //Displayname'i güncelle
        _auth.currentUser!.updateDisplayName(user.displayName);
      });
    } catch (e) {
      SnackbarUtil.showSnackbar(context, " hata oluştu: $e");
    }
  }

  //Kullanıcı bilgilerini getir
  Future<UserModel?> getUserInfoDatabaseAndStorage(BuildContext context) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(_auth.currentUser!.uid)
          .get();
      if (snapshot.exists) {
        UserModel userModel = UserModel.fromFirestore(snapshot, null);
        // Kullanıcı verilerini kullanmak için burada userModel'i kullanabilirsiniz
        return userModel;
      } else {
        SnackbarUtil.showSnackbar(context, Constants.user_not_found);
      }
    } catch (e) {
      print("Hata: ${e.toString()}");
      SnackbarUtil.showSnackbar(context, "Hata: ${e.toString()}");
    }
    return null;
  }

  //Aranan kullanıcı bilgilerini getir
  Future<UserModel?> getUserInfoSearchedUser(
      BuildContext context, String user_id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(user_id)
          .get();
      if (snapshot.exists) {
        UserModel userModel = UserModel.fromFirestore(snapshot, null);
        // Kullanıcı verilerini kullanmak için burada userModel'i kullanabilirsiniz
        return userModel;
      } else {
        SnackbarUtil.showSnackbar(context, Constants.user_not_found);
      }
    } catch (e) {
      print("Hata: ${e.toString()}");
      SnackbarUtil.showSnackbar(context, "Hata: ${e.toString()}");
    }
    return null;
  }

  //Kullanıcı ara
  Future<UserModel?> searchUserWithUsername(
      BuildContext context, String username) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection(Constants.fb_users)
          .where("username", isEqualTo: username)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming username is unique, only one document should be returned
        QueryDocumentSnapshot<Map<String, dynamic>> doc = snapshot.docs.first;
        UserModel user = UserModel.fromFirestore(doc, null);
        return user;
      } else {
        return null; // Username not found
      }
    } catch (e) {
      print("Error searching user: $e");
      return null;
    }
  }

  //Post ekle
  Future<void> addPostInfoInFb(
      BuildContext context, String image_url, String caption) async {
    String userId = _auth.currentUser!.uid;
    String postId = FirebaseFirestore.instance
        .collection(Constants.fb_post)
        .doc()
        .id;
    List<String> likes = [];
    List<String> comments = [];


    PostModel post =
        PostModel(postId: postId, userId: userId, imageUrl: image_url,likes: likes,comments: comments,caption: caption,createdAt: Timestamp.fromDate(DateTime.now()));

    //Postları fb ekle
    _firebaseFirestore
        .collection(Constants.fb_post)
        .doc(postId)
        .set(post.toFirestore());

    //postu paylaşanın postlarına ekleme yap
    await _firebaseFirestore.collection(Constants.fb_users).doc(userId).update({
      'posts': FieldValue.arrayUnion([postId])
    });
  }


/*
  //Postları çek
  Future<List<PostModel>> getPosts() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore.collection(Constants.fb_post).get();
    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }

 */

  //Postları çek
  Future<List<String>> getMyPostIds(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection(Constants.fb_post)
          .where('userId', isEqualTo: userId)
          .get();


      List<String> postIds = snapshot.docs.map((doc) => doc.id).toList();
      return postIds;
    } catch (e) {
      print('Error getting my post ids: $e');
      return [];
    }
  }


  Future<UserModel> getUserById(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore.collection(Constants.fb_users).doc(userId).get();
    return UserModel.fromFirestore(snapshot,null);
  }


  // Feed için Postları çek
  Future<List<PostModel>> getFriendsPosts(List<String> friendsIds) async {
    try {
      List<PostModel> friendsPosts = [];
      for (String friendId in friendsIds) {
        QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
            .collection(Constants.fb_post)
            .where('userId', isEqualTo: friendId)
            .get();
        for (var doc in snapshot.docs) {
          friendsPosts.add(PostModel.fromFirestore(doc));
        }
      }
      return friendsPosts;
    } catch (e) {
      print("Error getting posts by friendsIds: $e");
      return [];
    }
  }

  Future<List<String>> getFriendIds(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firebaseFirestore.collection(Constants.fb_users).doc(userId).get();
      Map<String, dynamic>? userData = snapshot.data();
      if (userData != null && userData['friends'] is List) {
        return List<String>.from(userData['friends']);
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting friend ids: $e");
      throw e;
    }
  }







  //postları profil için çek
  Future<List<PostModel>> getPostsByPostIds(List<String> postIds) async {
    try {
      List<PostModel> posts = [];
      for (String postId in postIds) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
            .collection(Constants.fb_post)
            .doc(postId)
            .get();
        if (snapshot.exists) {
          PostModel post = PostModel.fromFirestore(snapshot);
          posts.add(post);
        }
      }
      return posts;
    } catch (e) {
      print("Error getting posts by postIds: $e");
      return [];
    }
  }




  //arkadaşları çek
  Future<List<UserModel>> getFriendsByFriendsIds(List<String> friendsIds) async {
    try {
      List<UserModel> friends = [];
      for (String friendId in friendsIds) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
            .collection(Constants.fb_users)
            .doc(friendId)
            .get();
        if (snapshot.exists) {
          UserModel user = UserModel.fromFirestore(snapshot,null);
          friends.add(user);
        }
      }
      return friends;
    } catch (e) {
      print("Arkadaşları getirirken hata oluştu: $e");
      return [];
    }
  }

  //Arkadaş isteği gönder
  Future<String> sendFriendsRequest(
      BuildContext context, String recipientUid) async {
    String currentUserUid = _auth.currentUser?.uid ?? '';
    String button_status = "";
    try {
      // Gönderen kullanıcının sentFriendRequests alanına alıcıyı ekle
      await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(currentUserUid)
          .update({
        'sentFriendRequests': FieldValue.arrayUnion([recipientUid])
      }).whenComplete(() async {
        // Alıcı kullanıcının receivedFriendRequests alanına göndereni ekle
        await _firebaseFirestore
            .collection(Constants.fb_users)
            .doc(recipientUid)
            .update({
          'receivedFriendRequests': FieldValue.arrayUnion([currentUserUid])
        });
        button_status = Constants.cencel_friend;
      });

      return button_status;
    } catch (e) {
      print(e);
    }

    // Debug çıktısı
    print("Friend request sent from $currentUserUid to $recipientUid");

    return Constants.send_friend_failed;
  }

  // Arkadaş isteğini kabul et
  Future<String> acceptFriendsRequest(String recipientUid) async {
    try {
      // Giriş yapan kullanıcının UID'sini al
      String currentUserUid = _auth.currentUser?.uid ?? '';

      // Gönderen kullanıcının arkadaş listesine alıcıyı ekle
      await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(currentUserUid)
          .update({
        'friends': FieldValue.arrayUnion([recipientUid]),
        'friendRequests': FieldValue.arrayRemove([recipientUid]),
      });
      // Alıcı kullanıcının arkadaş listesine göndereni ekle
      await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(recipientUid)
          .update({
        'friends': FieldValue.arrayUnion([currentUserUid]),
        'receivedFriendRequests': FieldValue.arrayRemove([currentUserUid]),
      });

      return Constants.remove_friend;
    } catch (e) {
      print(e);
      return Constants.accept_friend_failed;
    }
  }

//arkadaş isteği iptal et
  Future<String> cancelFriendsRequest(String recipientUid) async {
    String currentUserUid = _auth.currentUser?.uid ?? '';
    try {
      await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(currentUserUid)
          .update({
        'sentFriendRequests': FieldValue.arrayRemove([recipientUid])
      }).whenComplete(() async {
        await _firebaseFirestore
            .collection(Constants.fb_users)
            .doc(recipientUid)
            .update({
          'receivedFriendRequests': FieldValue.arrayRemove([currentUserUid])
        });
      });

      return Constants.add_friend;
    } catch (e) {
      print(e);
    }
    return Constants.send_friend_failed;
  }

  //arkadaşı sil
  Future<String> removeFriends(String recipientUid) async {
    String currentUserUid = _auth.currentUser?.uid ?? '';
    try {
      await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(currentUserUid)
          .update({
        'friends': FieldValue.arrayRemove([recipientUid])
      }).whenComplete(() async {
        await _firebaseFirestore
            .collection(Constants.fb_users)
            .doc(recipientUid)
            .update({
          'friends': FieldValue.arrayRemove([currentUserUid])
        });
      });

      return Constants.add_friend;
    } catch (e) {
      print(e);
    }
    return Constants.send_friend_failed;
  }

}
