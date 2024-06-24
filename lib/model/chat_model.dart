import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heychat_2/model/user_model.dart';

class ChatModel {
  final String chatId;
  final List<String> userIds;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final UserModel user; // UserModel'i ekledik

  ChatModel({
    required this.chatId,
    required this.userIds,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.user, // UserModel'i required olarak ekledik
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String chatId, UserModel user) {
    return ChatModel(
      chatId: chatId,
      userIds: List<String>.from(map['userIds'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp).toDate(),
      user: user, // user alanını fabrik metodu içinde atadık
    );
  }
}
