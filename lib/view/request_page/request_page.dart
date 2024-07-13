import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/view_model/request_page_viewmodel/request_page_viewmodel.dart';

final viewModelProvider = ChangeNotifierProvider((ref) => RequestPageViewmodel());

class RequestPage extends ConsumerStatefulWidget {
  const RequestPage({super.key});

  @override
  ConsumerState<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends ConsumerState<RequestPage> {
  GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    ref.read(viewModelProvider).loadFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(Constants.get_friends_request),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final viewModel = ref.watch(viewModelProvider);

    return Consumer(
      builder: (context, watch, _) {
        if (viewModel.friendRequests.isEmpty) {
          return const Center(child: Text('Gelen arkadaş isteği yok.'));
        } else {
          return ListView.builder(
            itemCount: viewModel.friendRequests.length,
            itemBuilder: (context, index) {
              var friend = viewModel.friendRequests[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: friend['profileImageUrl']!.isNotEmpty
                            ? NetworkImage(friend['profileImageUrl']!)
                            : const AssetImage(Constants.logo_path) as ImageProvider,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend['displayName']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              friend['username']!,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () async {
                          await viewModel.acceptFriendsRequest(friend['uid']!);
                          _showNotification('Arkadaşlık isteği kabul edildi.');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          await viewModel.removeFriends(friend['uid']!);
                          _showNotification('Arkadaşlık isteği reddedildi.');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye),
                        onPressed: () async {
                          Navigator.pushNamed(context, "profile_page",arguments: friend['uid']!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  void _showNotification(String message) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // İsteğe bağlı: Bildirimin görüntülenme süresi
      ),
    );
  }
}
