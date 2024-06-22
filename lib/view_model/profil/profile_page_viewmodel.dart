import 'package:flutter/cupertino.dart';
import 'package:heychat_2/services/firestore_service.dart';

import '../../model/user_model.dart';

class ProfilePageViewmodel extends ChangeNotifier{
  int selectedIndex = 0;
  FirestoreService _firestoreService = FirestoreService();

  void onItemTapped(int index) {
      selectedIndex = index;
      notifyListeners();
  }

  void goSettingsPage(BuildContext context){
    Navigator.pushNamed(context, "settings_page");
    notifyListeners();
  }

  void goSearchPage(BuildContext context){
    Navigator.pushNamed(context, "home_page");
    notifyListeners();
  }

  //Kullanıcının bilgilerini getir
  Future<UserModel?> getUserInfo(BuildContext context) async {
    UserModel? user = await _firestoreService.getUserInfoDatabaseAndStorage(context);
    notifyListeners();
    return user;
  }
  //Aranan kullanıcının bilgilerini getir
  Future<UserModel?> getUserInfoFromSearch(BuildContext context, String user_id) async {
    UserModel? user = await _firestoreService.getUserInfoSearchedUser(context, user_id);
    notifyListeners();
    return user;
  }




  Future<String> sendFriendsRequest(BuildContext context, String target_id) async {
    String status = await _firestoreService.sendFriendsRequest(context, target_id);
    notifyListeners();
    return status;
  }

  //arkadaş isteği kabul et
  Future<String> acceptFriendsRequest(String recipientUid) async {
    String status = await _firestoreService.acceptFriendsRequest(recipientUid);
    return status;
  }

  Future<String> cancelFriendsRequest(String recipientUid) async {
    String status = await _firestoreService.cancelFriendsRequest(recipientUid);
    return status;
  }


}