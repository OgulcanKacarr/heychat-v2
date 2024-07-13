import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heychat_2/services/firestore_service.dart';
import 'package:photo_view/photo_view.dart';

import '../../model/post_model.dart';
import '../../model/user_model.dart';
import '../../utils/constants.dart';

class ProfilePageViewmodel extends ChangeNotifier {
  int selectedIndex = 0;
  FirestoreService _firestoreService = FirestoreService();
  FirebaseAuth _auth = FirebaseAuth.instance;

  String profile_pp = "";
  String cover_image = "";
  String display_name = "";
  String email = "";
  String bio = "";
  String username = "";
  String check_post_status = Constants.empty_searchuser_post;
  String check_friends_status = Constants.empty_searchuser_friend;
  bool isOnline = false;
  String? userId;
  bool showSettingsButton = true;
  String friend_button_status = Constants.add_friend;
  List<String>? friends = [];
  List<String>? sent_requests = [];
  List<String>? get_requests = [];
  List<String>? posts = [];

  List<PostModel>? posts_model = [];
  List<UserModel>? friends_model = [];

  bool isFriendRequestSent = false;
  bool isFriendRequestReceived = false;
  bool isFriend = false;

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void goSettingsPage(BuildContext context) {
    Navigator.pushNamed(context, "settings_page");
    notifyListeners();
  }

  void goSearchPage(BuildContext context) {
    Navigator.pushNamed(context, "home_page");
    notifyListeners();
  }

  //Kullanıcının bilgilerini getir
  Future<UserModel?> getUserInfo(BuildContext context) async {
    UserModel? user =
        await _firestoreService.getUserInfoDatabaseAndStorage(context);
    notifyListeners();
    return user;
  }

  //Aranan kullanıcının bilgilerini getir
  Future<UserModel?> getUserInfoFromSearch(
      BuildContext context, String user_id) async {
    UserModel? user =
        await _firestoreService.getUserInfoSearchedUser(context, user_id);
    notifyListeners();
    return user;
  }

  //postları çek
  Future<List<PostModel>> getPostsByPostIds(List<String> postIds) async {
    try {
      List<PostModel> posts =
          await _firestoreService.getPostsByPostIds(postIds);
      return posts;
    } catch (e) {
      print("Error getting posts by postIds: $e");
      return [];
    }
  }

  //Arkadaşları çek
  Future<List<UserModel>> getFriendsByFriendsIds(
      List<String> friends_ids) async {
    try {
      List<UserModel> friends =
          await _firestoreService.getFriendsByFriendsIds(friends_ids);
      notifyListeners();
      return friends;
    } catch (e) {
      print("Error getting posts by postIds: $e");
      return [];
    }
  }

  Future<String> sendFriendsRequest(
      BuildContext context, String target_id) async {
    String status =
        await _firestoreService.sendFriendsRequest(context, target_id);
    notifyListeners();
    return status;
  }

  //arkadaş isteği kabul et
  Future<String> acceptFriendsRequest(String recipientUid) async {
    String status = await _firestoreService.acceptFriendsRequest(recipientUid);
    notifyListeners();
    return status;
  }

  Future<String> cancelFriendsRequest(String recipientUid) async {
    String status = await _firestoreService.cancelFriendsRequest(recipientUid);
    notifyListeners();
    return status;
  }

  Future<String> removeFriends(String recipientUid) async {
    String status = await _firestoreService.removeFriends(recipientUid);
    notifyListeners();
    return status;
  }
  Future<void> removePost(String postId) async {
    await _firestoreService.removePost(postId);
    notifyListeners();
  }


  Future<List<DocumentSnapshot>> getInvitations() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot invitationsSnapshot = await FirebaseFirestore.instance
          .collection('invitations')
          .where('friend_uid', isEqualTo: currentUserId)
          .get();

      return invitationsSnapshot.docs;
    } catch (e) {
      print('Davetleri getirirken hata oluştu: $e');
      return []; // Hata durumunda boş liste döndürülebilir veya null
    }
  }

  //birlikte izleyi kabul et
  Future<void> acceptInvitation(
      BuildContext context, String invitationId) async {
    // Daveti kabul etme işlemleri
    await FirebaseFirestore.instance
        .collection('invitations')
        .doc(invitationId)
        .update({'status': 'accepted'});

    // Seans bilgilerini alın
    final invitationSnapshot = await FirebaseFirestore.instance
        .collection('invitations')
        .doc(invitationId)
        .get();
    final sessionId = invitationSnapshot.data()?['sessionId'] ?? '';
    final friendName = invitationSnapshot.data()?['friendName'] ?? '';

    // WatchTogetherPage ekranına geçiş yap
    Navigator.pushNamed(
      context,
      'watch_together_page',
      arguments: {'sessionId': sessionId, 'friendName': friendName},
    );
  }

  // Daveti reddetme işlemi
  Future<void> rejectInvitation(String invitationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('invitations')
          .doc(invitationId)
          .update({'status': 'rejected'});
    } catch (e) {
      print('Daveti reddederken hata oluştu: $e');
    }
  }

  Future<void> handleFriendRequest(
      BuildContext context, String target_id) async {
    if (!isFriendRequestSent && !isFriendRequestReceived) {
      friend_button_status = await sendFriendsRequest(context, target_id);
    } else if (isFriendRequestReceived) {
      friend_button_status = await acceptFriendsRequest(target_id);
    } else if (isFriendRequestSent) {
      friend_button_status = await cancelFriendsRequest(target_id);
    } else if (isFriend) {
      friend_button_status = await removeFriends(userId!);
    }
    notifyListeners();
  }

  Future<String> createNewSession(String friendName, String friend_uid) async {
    DocumentReference sessionRef =
        await FirebaseFirestore.instance.collection('sessions').add({
      'videoId': '',
      'isPlaying': false,
      'currentTime': 0,
      'current_uid': _auth.currentUser!.uid,
      'friendName': friendName,
    });
    // Daveti arkadaşınıza gönderin
    await FirebaseFirestore.instance.collection('invitations').add({
      'sessionId': sessionRef.id,
      'friendName': friendName,
      'friend_uid': friend_uid,
      'status': 'pending', // davetin durumu
    });
    return sessionRef.id;
  }

  void showCoverPhotoDialog(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 2,
            maxWidth: MediaQuery.of(context).size.width - 10,
          ),
          child: PhotoView.customChild(
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            initialScale: PhotoViewComputedScale.contained,
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.contain,
              progressIndicatorBuilder: (context, url, downloadProgress) {
                if (downloadProgress.totalSize != null) {
                  final percent =
                      (downloadProgress.progress! * 100).toStringAsFixed(0);
                  return Center(
                    child: Text("$percent% tamamlandı"),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }

  void showProfilePhotoDialog(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: PhotoView.customChild(
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            initialScale: PhotoViewComputedScale.contained,
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.contain,
              progressIndicatorBuilder: (context, url, downloadProgress) {
                if (downloadProgress.totalSize != null) {
                  final percent =
                      (downloadProgress.progress! * 100).toStringAsFixed(0);
                  return Center(
                    child: Text("$percent% tamamlandı"),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget getPhoto(String image_url) {
    return PhotoView.customChild(
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 2,
      backgroundDecoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      initialScale: PhotoViewComputedScale.contained,
      child: CachedNetworkImage(
        imageUrl: image_url,
        fit: BoxFit.contain,
        progressIndicatorBuilder: (context, url, downloadProgress) {
          if (downloadProgress.totalSize != null) {
            final percent =
                (downloadProgress.progress! * 100).toStringAsFixed(0);
            return Center(
              child: Text("$percent% tamamlandı"),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

  Future<void> ShowPostDialog(
      BuildContext context, List postsModel, int index) async {
    return await showDialog(
        context: context,
        builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: double.infinity,
                      child: getPhoto(postsModel[index].imageUrl),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          postsModel![index].caption,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
