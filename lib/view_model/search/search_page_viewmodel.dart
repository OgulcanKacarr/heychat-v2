import 'package:flutter/cupertino.dart';
import 'package:heychat_2/model/user_model.dart';
import 'package:heychat_2/services/firestore_service.dart';

class SearchPageViewmodel extends ChangeNotifier{

  FirestoreService _firestoreService = FirestoreService();

  //Kullanıcı ara
  Future<UserModel?> searchUserWithUsername(BuildContext context, String username) async{
    UserModel? user = await _firestoreService.searchUserWithUsername(context, username);
    notifyListeners();
    return user;
  }
}