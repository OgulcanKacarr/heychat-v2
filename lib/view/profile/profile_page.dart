import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/model/post_model.dart';
import 'package:heychat_2/utils/snackbar_util.dart';
import 'package:heychat_2/view/post_detail/post_detail.dart';
import 'package:heychat_2/view_model/profil/profile_page_viewmodel.dart';
import 'package:heychat_2/widgets/custom_button_widgets.dart';
import 'package:heychat_2/widgets/custom_divider_widgets.dart';
import 'package:heychat_2/widgets/custom_text_widgets.dart';
import 'package:photo_view/photo_view.dart';

import '../../model/user_model.dart';
import '../../utils/constants.dart';

final view_model = ChangeNotifierProvider((ref) => ProfilePageViewmodel());

class ProfilePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<UserModel?> _futureUser;
  String profile_pp = "";
  String cover_image = "";
  String display_name = "";
  String email = "";
  String bio = "";
  String username = "";
  String check_post_status = Constants.empty_searchuser_post;
  String check_friends_status = Constants.empty_searchuser_friend;
  bool isOnline = false;
  String? userId;
  bool showSettingsButton = true;
  String friend_button_status = Constants.add_friend;
  List<String>? friends = [];
  List<String>? sent_requests = [];
  List<String>? get_requests = [];
  List<String>? posts = [];

  List<PostModel>? posts_model = [];
  List<UserModel>? friends_model = [];

  bool isFriendRequestSent = false;
  bool isFriendRequestReceived = false;
  bool isFriend = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userId = ModalRoute.of(context)?.settings.arguments as String?;
    _futureUser = _getUserInfo();
  }

  Future<UserModel?> _getUserInfo() async {
    UserModel? user;
    if (userId != null && userId!.isNotEmpty) {
      check_post_status = Constants.empty_searchuser_post;
      check_friends_status = Constants.empty_searchuser_friend;
      showSettingsButton = false;
      user = await ref.read(view_model).getUserInfoFromSearch(context, userId!);
      posts = user?.posts;
      friends = user?.friends;

      if (friends != null) {
        friends_model = await ref
            .read(view_model)
            .getFriendsByFriendsIds(user?.friends ?? []);
      }
      if (posts != null) {
        posts_model = await ref.read(view_model).getPostsByPostIds(posts!);
      }

      if (user != null) {
        sent_requests = user.sentFriendRequests;
        get_requests = user.receivedFriendRequests;
        isFriendRequestSent =
            sent_requests?.contains(_auth.currentUser!.uid) ?? false;
        isFriendRequestReceived = get_requests?.contains(userId) ?? false;
        isFriend = friends?.contains(userId) ?? false;

        if (isFriendRequestReceived) {
          friend_button_status = Constants.add_friend;
        } else if (isFriendRequestSent) {
          friend_button_status = Constants.cencel_friend;
        } else if (isFriend) {
          friend_button_status = Constants.remove_friend;
        }
      }
    } else {
      check_post_status = Constants.empty_currentuser_post;
      check_friends_status = Constants.empty_currentuser_friend;
      user = await ref.read(view_model).getUserInfo(context);
      posts = user?.posts;
      friends = user?.friends;

      if (posts != null) {
        posts_model = await ref.read(view_model).getPostsByPostIds(posts!);
      }
      if (friends != null) {
        friends_model = await ref
            .read(view_model)
            .getFriendsByFriendsIds(user?.friends ?? []);
      }
    }

    return user;
  }

  List<Widget> widgetOptions(
    BuildContext context,
    ProfilePageViewmodel watch,
    List<PostModel>? posts_model,
    List<UserModel>? friends_model,
    Widget Function(String) getPhoto,
  ) {
    return [
// Gönderiler Sekmesi
      posts_model != null && posts_model!.isNotEmpty
          ? GridView.builder(
        padding: const EdgeInsets.all(2.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: posts_model.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  watch.ShowPostDialog(context, posts_model, index);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CachedNetworkImage(
                        imageUrl: posts_model[index].imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          posts_model[index].caption,
                          maxLines: 2, // Adjust max lines as needed
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: ()  async {
                            await watch.removePost(posts_model[index].postId).then((onValue){
                              setState(() {
                                posts_model.removeAt(index);
                                SnackbarUtil.showSnackbar(context, Constants.remove_post);
                              });
                            });
                          },
                        ),
                      ],
                    )

                  ],
                ),
              ),
            ],
          );
        },
      )
          : Center(child: Text(check_post_status)),

      // Arkadaşlar Sekmesi
      friends_model != null && friends_model.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: friends_model.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                        friends_model[index].profileImageUrl),
                  ),
                  title: Text(friends_model[index].displayName),
                  subtitle: Text(friends_model[index].username),
                  onTap: () {
                    Navigator.pushNamed(context, "profile_page",
                        arguments: friends_model[index].uid!);
                  },
                  onLongPress: () async {
                    String sessionId = await watch.createNewSession(
                        friends_model[index].displayName,
                        friends_model[index].uid);
                    Navigator.pushNamed(
                      context,
                      'watch_together_page',
                      arguments: {
                        'friendName': friends_model[index].displayName,
                        'sessionId': sessionId
                      },
                    );
                  },
                );
              },
            )
          : Center(child: Text(check_friends_status)),

      // Davetler Sekmesi
      FutureBuilder<List<DocumentSnapshot>>(
        future: watch.getInvitations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Davetleri alırken hata oluştu.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Henüz davetiniz yok.'));
          } else {
            List<DocumentSnapshot> invitations = snapshot.data!;
            return ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                var invitation =
                    invitations[index].data() as Map<String, dynamic>;
                String friendName = invitation['friendName'];
                String status = invitation['status'];

                return ListTile(
                  title: Text('Davet eden: $friendName'),
                  subtitle: Text('Durum: $status'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          watch.acceptInvitation(
                              context, invitations[index].id);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          watch.rejectInvitation(invitations[index].id);
                          setState(() {
                            _futureUser = _getUserInfo();
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var watch = ref.watch(view_model);
    var read = ref.read(view_model);

    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Hata: ${snapshot.error}");
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text(Constants.user_not_found));
          } else {
            UserModel user = snapshot.data!;
            display_name = user.displayName;
            email = user.email;
            bio = user.bio;
            username = user.username;
            profile_pp = user.profileImageUrl;
            cover_image = user.coverImageUrl;
            isOnline = user.isOnline;
            friends = user.friends;
            sent_requests = user.sentFriendRequests;
            get_requests = user.receivedFriendRequests;
            posts = user.posts;

            isFriendRequestSent =
                user.sentFriendRequests!.contains(_auth.currentUser!.uid);
            isFriendRequestReceived =
                user.receivedFriendRequests!.contains(_auth.currentUser!.uid);
            isFriend = user.friends!.contains(_auth.currentUser!.uid);

            return _buildBody(context, watch, read);
          }
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfilePageViewmodel watch,
      ProfilePageViewmodel read) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Kapak Fotoğrafı ve Profil Fotoğrafı
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Kapak Fotoğrafı
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      watch.showCoverPhotoDialog(context, cover_image);
                    },
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: cover_image.isEmpty
                          ? const Center(
                              child: Text(Constants.empty_cover_photo))
                          : CachedNetworkImage(imageUrl: cover_image),
                    ),
                  ),
                ),
                // Profil Fotoğrafı
                Positioned(
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      watch.showProfilePhotoDialog(context, profile_pp);
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profile_pp.isEmpty
                          ? const AssetImage(Constants.logo_path)
                          : NetworkImage(profile_pp),
                      child: profile_pp.isEmpty
                          ? null
                          : ClipOval(
                              child: watch.getPhoto(profile_pp),
                            ),
                    ),
                  ),
                ),
                // Ayarlar Butonu
                if (showSettingsButton)
                  Positioned(
                    top: 10,
                    right: 5,
                    child: IconButton(
                      onPressed: () {
                        read.goSettingsPage(context);
                      },
                      icon: Icon(Icons.settings),
                    ),
                  ),
                // Geri Butonu
                if (!showSettingsButton)
                  Positioned(
                    top: 10,
                    left: 5,
                    child: IconButton(
                      onPressed: () {
                        read.goSearchPage(context);
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.tealAccent),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          // Display Name, Username ve Bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextWidgets(
                      text: display_name ?? "Kullanıcı",
                      color: Colors.white,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Container(
                        width: 15,
                        height: 15,
                        child: CircleAvatar(
                          backgroundColor:
                              isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                CustomTextWidgets(
                  text: username ?? "Kullanıcı adı",
                  color: Colors.white,
                  font_size: 10,
                ),
                const SizedBox(height: 15),
                CustomTextWidgets(
                  text: bio ?? "bio",
                  color: Colors.white,
                  font_size: 10,
                ),
                const SizedBox(height: 5),
                const CustomDividerWidgets(),
                SizedBox(height: 15),

                // Arkadaşlık Durumuna Göre Butonu Oluşturma
                if (!showSettingsButton)
                  CustomButtonWidgets(
                      funciton: () {
                        Navigator.pushNamed(context, "send_message_page",
                            arguments: userId);
                      },
                      text: Constants.send_message),

                if (!showSettingsButton)
                  if (!isFriend)
                    ElevatedButton(
                      onPressed: () async {
                        await watch.handleFriendRequest(context, userId!);
                      },
                      child: Text(friend_button_status),
                    ),

                if (isFriend)
                  ElevatedButton(
                    onPressed: () async {
                      await watch.removeFriends(userId!);
                      setState(() {
                        _futureUser = _getUserInfo();
                      });
                    },
                    child: Text('Arkadaşlıktan çıkar'),
                  ),

                SizedBox(height: 15),
                // Takipçi ve Takip Edilen Butonları
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_camera_back),
                        onPressed: () {
                          watch.onItemTapped(0);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.people),
                        onPressed: () {
                          watch.onItemTapped(1);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.watch),
                        onPressed: () {
                          watch.onItemTapped(2);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Seçilen sekme içeriğini gösterme
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: widgetOptions(context, watch, posts_model,
                          friends_model, watch.getPhoto)
                      .elementAt(watch.selectedIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
