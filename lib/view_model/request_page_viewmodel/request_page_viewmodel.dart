import 'package:flutter/material.dart';
import 'package:heychat_2/services/firestore_service.dart';

class RequestPageViewmodel extends ChangeNotifier {
  FirestoreService _firestoreService = FirestoreService();
  List<Map<String, String>> friendRequests = [];

  RequestPageViewmodel() {
    loadFriendRequests();
  }

  Future<void> loadFriendRequests() async {
    friendRequests = await _firestoreService.getFriendsRequests();
    notifyListeners();
  }

  // Arkadaş isteğini kabul et
  Future<void> acceptFriendsRequest(String recipientUid) async {
    await _firestoreService.acceptFriendsRequest(recipientUid).whenComplete((){
      friendRequests.removeWhere((friend) => friend['uid'] == recipientUid);
    });
    notifyListeners();  // notifyListeners çağrısını burada kullanarak UI'nin güncellenmesini sağlıyoruz.
  }

  // Arkadaş isteğini iptal et
  Future<void> removeFriends(String recipientUid) async {
    await _firestoreService.cancelFriendsRequest(recipientUid).whenComplete((){
      friendRequests.removeWhere((friend) => friend['uid'] == recipientUid);
    });
    notifyListeners();  // notifyListeners çağrısını burada kullanarak UI'nin güncellenmesini sağlıyoruz.
  }
}
