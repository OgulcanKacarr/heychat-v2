import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/model/chat_model.dart';
import 'package:heychat_2/view_model/chats/chats_page_viewmodel.dart';
import 'package:intl/intl.dart';
import '../../model/user_model.dart'; // Kullanıcı modelinizi içeri aktarın
import '../../utils/constants.dart';
import '../../view_model/chats/send_and_get_messages_page_viewmodel.dart';

final view_model = ChangeNotifierProvider((ref) => ChatsPageViewmodel());

class ChatsPage extends ConsumerStatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends ConsumerState<ChatsPage> {
  List<ChatModel>? chats;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    getChats();
  }

  Future<void> getChats() async {
     chats = (await ref.read(view_model).getChats(_auth.currentUser!.uid)) as List<ChatModel>?;
    // setState veya notifyListeners kullanarak widget'ı güncelleyin
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildChatList(),
    );
  }

  Widget _buildChatList() {
    //var chats = ref.watch(view_model).getChats(userId);

    if (chats == null) {
      return Center(child: Text('Sohbet bulunamadı.'));
    }

    return ListView.builder(
      itemCount: chats!.length,
      itemBuilder: (context, index) {
        var user = chats![index];
        String date = DateFormat('dd.MM.yyyy HH:mm').format(user.lastMessageTimestamp);


        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.user.profileImageUrl.isNotEmpty
                ? CachedNetworkImageProvider(user.user.profileImageUrl)
                : const AssetImage(Constants.logo_path) as ImageProvider,
          ),
          title: Text(user.user.displayName),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${user.lastMessage}",style: TextStyle(fontStyle: FontStyle.italic),),
              Text("${date}",style: TextStyle(fontSize: 10),),
            ],
          ), // İleride ekleyebilirsiniz
          onTap: () {
            // Sohbete tıklandığında yapılacak işlemler
            // Örneğin sohbet sayfasına yönlendirme yapılabilir
            Navigator.pushNamed(context, "send_message_page",arguments: user.user.uid);

          },
        );
      },
    );
  }
}
