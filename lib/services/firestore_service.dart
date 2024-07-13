import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as messaging;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:heychat_2/model/message_model.dart';
import 'package:heychat_2/model/post_model.dart';
import 'package:heychat_2/model/user_model.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/utils/snackbar_util.dart';
import '../model/chat_model.dart';
import 'package:http/http.dart' as http;

class FirestoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addUserInfoInDatabase(BuildContext context,
      UserModel user) async {
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
  Future<UserModel?> getUserInfoSearchedUser(BuildContext context,
      String user_id) async {
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
  Future<UserModel?> searchUserWithUsername(BuildContext context,
      String username) async {
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
  Future<void> addPostInfoInFb(BuildContext context, String image_url,
      String caption) async {
    String userId = _auth.currentUser!.uid;
    String postId = FirebaseFirestore.instance
        .collection(Constants.fb_post)
        .doc()
        .id;
    List<String> likes = [];
    List<String> comments = [];

    DateTime date = DateTime.now();
    var timestamp = Timestamp.fromDate(date);

    PostModel post =
    PostModel(postId: postId,
        userId: userId,
        imageUrl: image_url,
        likes: likes,
        comments: comments,
        caption: caption,
        createdAt:timestamp);

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

// Post silme metodu
  Future<void> removePost(String postId) async {
    try {
      // Firestore'dan ilgili postu sil
      await _firebaseFirestore
          .collection(Constants.fb_post)
          .doc(postId)
          .delete();

      // Kullanıcının postlar listesinden silinen postu kaldır
      String userId = _auth.currentUser!.uid;
      await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(userId)
          .update({
        'posts': FieldValue.arrayRemove([postId])
      });
    } catch (e) {
      print("Error deleting post: $e");
    }
  }


  //Postları çek
  Future<List<String>> getMyPostIds(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection(Constants.fb_post)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();


      List<String> postIds = snapshot.docs.map((doc) => doc.id).toList();
      return postIds;
    } catch (e) {
      print('Error getting my post ids: $e');
      return [];
    }
  }


  Future<UserModel> getUserById(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
        .collection(Constants.fb_users).doc(userId).get();
    return UserModel.fromFirestore(snapshot, null);
  }


  // Feed için Postları çek
  Future<List<PostModel>> getFriendsPosts(List<String> friendsIds) async {
    try {
      List<PostModel> friendsPosts = [];
      for (String friendId in friendsIds) {
        QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
            .collection(Constants.fb_post)
            .where('userId', isEqualTo: friendId)
            .orderBy('createdAt', descending: true)
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
        DocumentSnapshot<
            Map<String, dynamic>> snapshot = await _firebaseFirestore
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
  Future<List<UserModel>> getFriendsByFriendsIds(
      List<String> friendsIds) async {
    try {
      List<UserModel> friends = [];
      for (String friendId in friendsIds) {
        DocumentSnapshot<
            Map<String, dynamic>> snapshot = await _firebaseFirestore
            .collection(Constants.fb_users)
            .doc(friendId)
            .get();
        if (snapshot.exists) {
          UserModel user = UserModel.fromFirestore(snapshot, null);
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
  Future<String> sendFriendsRequest(BuildContext context,
      String recipientUid) async {
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


  //arkadaş isteklerini getir
  Future<List<Map<String, String>>> getFriendsRequests() async {
    String currentUserUid = _auth.currentUser?.uid ?? '';
    try {
      DocumentSnapshot userDoc = await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(currentUserUid)
          .get();
      List<String> friendRequests = List<String>.from(userDoc['receivedFriendRequests']);

      // Her arkadaş isteği için kullanıcı bilgilerini al
      List<Map<String, String>> usersData = [];
      for (String uid in friendRequests) {
        DocumentSnapshot userData = await _firebaseFirestore.collection(Constants.fb_users).doc(uid).get();
        usersData.add({
          'uid': userData['uid'],
          'displayName': userData['displayName'],
          'username': userData['username'],
          'profileImageUrl': userData['profileImageUrl'] ?? ''
        });
      }
      return usersData;
    } catch (e) {
      print(e);
      return [];
    }
  }


  Future<String?> getReceiverToken(String receiverId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firebaseFirestore.collection(Constants.fb_users).doc(receiverId).get();
      Map<String, dynamic>? userData = snapshot.data();

      // userData varsa ve 'token' alanı String ise doğrudan döndür
      if (userData != null && userData['token'] is String) {
        String token = userData['token']; // Token'ı al
        print("hedefin tokeni: $token"); // Token'ı yazdır (Opsiyonel)
        return token; // Token'ı döndür
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting receiver token: $e");
      throw e;
    }
  }


  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    required String receiverToken, // Alıcının FCM token'ını buradan alın

  }) async {
    try {

      // Chat ID oluşturmak için katılımcıların UID'lerini sıralı bir şekilde birleştiriyoruz.
      List<String> userIds = [senderId, receiverId];
      userIds.sort(); // UID'leri sıralıyoruz ki chatId her iki kullanıcı için aynı olsun.

      String chatId = userIds.join('_'); // Örneğin: 'uid1_uid2'

      // Gönderilecek mesajın zaman damgasını alıyoruz.
      DateTime date = DateTime.now();
      var timestamp = Timestamp.fromDate(date);

      // Mesajı Firestore'a ekliyoruz.
      await FirebaseFirestore.instance.collection(Constants.fb_messages).add({
        'chatId': chatId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': timestamp,
        'isRead': false,
        'receiverToken': receiverToken,
      });

      // Son mesajı güncellemek için gerekli verileri hazırlıyoruz.
      String lastMessage = content;
      Timestamp lastMessageTimestamp = Timestamp.fromDate(date);

      // Chat belgesini kontrol ediyoruz.
      final chatDoc = await FirebaseFirestore.instance.collection(Constants.fb_chats).doc(chatId).get();

      // Eğer chat belgesi yoksa, yeni bir chat oluşturuyoruz.
      if (!chatDoc.exists) {
        await FirebaseFirestore.instance.collection(Constants.fb_chats).doc(chatId).set({
          'userIds': userIds,
          'lastMessage': lastMessage,
          'lastMessageTimestamp': lastMessageTimestamp,
          'isRead': false, // Yeni mesaj okunmadı olarak işaretleniyor
        });
      } else {
        // Eğer chat belgesi varsa, son mesajı ve zaman damgasını güncelliyoruz.
        await FirebaseFirestore.instance.collection(Constants.fb_chats).doc(chatId).update({
          'lastMessage': lastMessage,
          'lastMessageTimestamp': lastMessageTimestamp,
          'isRead': false, // Yeni mesaj okunmadı olarak işaretleniyor
        });


          // Mesaj içeriği (content) bildirim metni olarak kullanılabilir
          String messageBody = content;
          // Bildirim gönderme işlemi
          await sendNotification(receiverToken, 'Yeni Mesaj', messageBody);


      }
    } catch (e) {
      print('Hata oluştu: $e');
      // Hata durumunda uygun şekilde işleme alınabilir.
    }
  }

  Future<void> sendNotification(String receiverToken, String title, String messageBody) async {
    try {

    } catch (e) {
      print('Error sending notification: $e');
    }
  }


  Stream<List<Message>> getMessages(
      String senderId,
      String receiverId,
      ) {
    List<String> userIds = [senderId, receiverId];
    userIds.sort(); // UID'leri sıralıyoruz ki chatId her iki kullanıcı için aynı olsun.
    String chatId = userIds.join('_'); // Örneğin: 'uid1_uid2'
    try {
      // Belirli bir chatId'ye ait mesajları Firestore'dan çekmek için bir stream döndürüyoruz.
      return FirebaseFirestore.instance
          .collection(Constants.fb_messages)
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
    } catch (e) {
      print('Hata oluştu: $e');

      throw e;
    }

  }


  // Kullanıcının tüm sohbetlerini getiren metod

  Future<List<ChatModel>> getChats(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection(Constants.fb_chats)
          .where('userIds', arrayContains: userId)
          .orderBy('lastMessageTimestamp', descending: true)
          .get();

      List<ChatModel> chats = [];
      for (var doc in snapshot.docs) {
        List<dynamic> userIds = doc['userIds'];
        String otherUserId = userIds.firstWhere((id) => id != userId);

        DocumentSnapshot<Map<String, dynamic>> userSnapshot = await _firebaseFirestore
            .collection(Constants.fb_users)
            .doc(otherUserId)
            .get();

        if (userSnapshot.exists) {
          UserModel userModel = UserModel.fromFirestore(userSnapshot,null);

          ChatModel chatModel = ChatModel(
            chatId: doc.id,
            userIds: List<String>.from(doc['userIds']),
            lastMessage: doc['lastMessage'],
            lastMessageTimestamp: (doc['lastMessageTimestamp'] as Timestamp).toDate(),
            isRead: doc['isRead'], // UserModel'i ChatModel'e ekle
            user: userModel,
          );

          chats.add(chatModel);
        }
      }

      return chats;
    } catch (e) {
      print("Sohbetleri getirirken hata oluştu: $e");
      return [];
    }
  }


}