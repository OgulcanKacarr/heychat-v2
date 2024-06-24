import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/model/user_model.dart';
import 'package:intl/intl.dart';
import '../../model/message_model.dart';
import '../../services/firestore_service.dart';
import '../../view_model/chats/send_and_get_messages_page_viewmodel.dart';

final view_model = ChangeNotifierProvider((ref) => SendAndGetMessagesPageViewmodel());

class SendAndGetMessagesPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SendAndGetMessagesPage> createState() => _SendAndGetMessagesPageState();
}

class _SendAndGetMessagesPageState extends ConsumerState<SendAndGetMessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  FirebaseAuth _auth = FirebaseAuth.instance;
  late String receiverId;
  late String chatId = "";
  late String senderId;
  UserModel? user;


  @override
  void initState() {
    super.initState();
    // initState içinde kullanıcı bilgisini çekmek için getUserInfo metodunu çağırabiliriz.
    getUserInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    receiverId = (ModalRoute.of(context)?.settings.arguments as String?)!;
    getUserInfo();
  }

  Future<void> getUserInfo() async {

    user = await ref.watch(view_model).getUserInfoWithId(context, receiverId);
    if (mounted) {
      setState(() {});
    }

  }

  @override
  Widget build(BuildContext context) {
    senderId = _auth.currentUser!.uid;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(user!.displayName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(chatId)),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList(String chatId) {
    return StreamBuilder<List<Message>>(
      stream: _firestoreService.getMessages(senderId, receiverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("hata ${snapshot.error.toString()}");
          return Center(child: Text('Bir hata oluştu.'));
        }

        var messages = snapshot.data ?? [];

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];

            String date = DateFormat('dd.MM.yyyy HH:mm').format(message.timestamp);
            bool isSentByCurrentUser = message.senderId == _auth.currentUser!.uid;

            return Align(
              alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSentByCurrentUser ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    var watch = ref.watch(view_model);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Mesajınızı yazın...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () async {
              if (_messageController.text.trim().isNotEmpty) {
                await _firestoreService.sendMessage(
                  senderId: senderId,
                  receiverId: receiverId,
                  content: _messageController.text.trim(),
                );
                _messageController.clear();
              }
            },
          ),

        ],
      ),
    );
  }
}
