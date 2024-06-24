import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> userIds;
  final String lastMessage;
  final DateTime lastMessageTimestamp;

  ChatModel({
    required this.chatId,
    required this.userIds,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String chatId) {
    return ChatModel(
      chatId: chatId,
      userIds: List<String>.from(map['userIds'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp).toDate(),
    );
  }
}
