import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../model/message_model.dart';
import '../../services/firestore_service.dart';
import '../../view_model/chats/send_and_get_messages_page_viewmodel.dart';
import '../../model/user_model.dart';
import 'package:heychat_2/utils/constants.dart';

final view_model = ChangeNotifierProvider((ref) => SendAndGetMessagesPageViewmodel());

class SendAndGetMessagesPage extends ConsumerStatefulWidget {
  @override
  _SendAndGetMessagesPageState createState() => _SendAndGetMessagesPageState();
}

class _SendAndGetMessagesPageState extends ConsumerState<SendAndGetMessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  FirebaseAuth _auth = FirebaseAuth.instance;
  late String receiverId;
  late String chatId = "";
  late String senderId;
  UserModel? user;
  late ScrollController _scrollController;
  bool pp_state = false;


  @override
  void initState() {
    super.initState();
    // initState içinde kullanıcı bilgisini çekmek için getUserInfo metodunu çağırabiliriz.
    _scrollController = ScrollController();
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
        actions: [
          if (!pp_state)
            CircleAvatar(
              radius: 20,
              backgroundImage: user!.profileImageUrl.isNotEmpty
                  ? CachedNetworkImageProvider(user!.profileImageUrl)
                  : const AssetImage(Constants.logo_path) as ImageProvider,
            ),
        ],
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

        // Otomatik aşağıya kaydırma için ScrollController kullanımı
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];

            String date = DateFormat('dd.MM.yyyy HH:mm').format(message.timestamp);
            bool isSentByCurrentUser = message.senderId == _auth.currentUser!.uid;

            pp_state = isSentByCurrentUser;
            return Align(
              alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSentByCurrentUser ? Colors.green : Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: isSentByCurrentUser ? CrossAxisAlignment.start : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: const TextStyle(color: Colors.white),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.white,fontSize: 13),
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
                hintText: Constants.enter_message,
                hintStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
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
