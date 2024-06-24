import 'package:flutter/widgets.dart';
import 'package:heychat_2/services/firestore_service.dart';

import '../../model/chat_model.dart';
import '../../model/user_model.dart';

class ChatsPageViewmodel extends ChangeNotifier{
  FirestoreService _firestoreService = FirestoreService();

  Future<List<ChatModel>> getChats(String userId) async {
    List<ChatModel> chats = await _firestoreService.getChats(userId);
    notifyListeners();
    return chats;
  }
}