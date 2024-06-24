import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/model/post_model.dart';
import 'package:heychat_2/view_model/profil/profile_page_viewmodel.dart';
import 'package:heychat_2/widgets/custom_button_widgets.dart';
import 'package:heychat_2/widgets/custom_divider_widgets.dart';
import 'package:heychat_2/widgets/custom_text_widgets.dart';

import '../../model/user_model.dart';
import '../../utils/constants.dart';

final view_model = ChangeNotifierProvider((ref) => ProfilePageViewmodel());

class ProfilePage extends ConsumerStatefulWidget {


  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<UserModel?> _futureUser;
  String profile_pp = "";
  String cover_image = "";
  String display_name = "";
  String email = "";
  String bio = "";
  String username = "";
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

  Future<void> _handleFriendRequest(
      var watch, BuildContext context, String target_id) async {

    if (!isFriendRequestSent && !isFriendRequestReceived) {
      friend_button_status = await watch.sendFriendsRequest(context, target_id);
    } else if (isFriendRequestReceived) {
      friend_button_status =  await watch.acceptFriendsRequest(target_id);
    } else if (isFriendRequestSent) {
      friend_button_status =  await watch.cancelFriendsRequest(target_id);
    } else if(isFriend){
      friend_button_status =  await watch.removeFriends(userId!);
    }

    // FutureBuilder içindeki _futureUser'ı yenilemek için setState kullanımı
    setState(() {
      _futureUser = _getUserInfo();
    });
  }





  Future<UserModel?> _getUserInfo() async {
    UserModel? user;

    if (userId != null && userId!.isNotEmpty) {
      showSettingsButton = false;
      user = await ref.read(view_model).getUserInfoFromSearch(context, userId!);
      posts = user?.posts; // Kullanıcının postlarını alma
      friends = user?.friends;

      if (friends != null) {
        friends_model = await ref.read(view_model).getFriendsByFriendsIds(user?.friends ?? []);
      }
      if (posts != null) {
        posts_model = await ref.read(view_model).getPostsByPostIds(posts!);
      }

      if (user != null) {
        sent_requests = user.sentFriendRequests;
        get_requests = user.receivedFriendRequests;
        isFriendRequestSent = sent_requests?.contains(_auth.currentUser!.uid) ?? false;
        isFriendRequestReceived = get_requests?.contains(userId) ?? false;
        isFriend = friends?.contains(userId) ?? false;


        if (isFriendRequestReceived) {
          //Kullanıcıya arkadaşlık isteği gönderilmiş mi?
          // Eğer gönderilmişse ve hedef kullanıcı bu isteği kabul etmemişse
          friend_button_status = Constants.add_friend;
        }else if (isFriendRequestSent) {
          //Kullanıcı tarafından hedef kullanıcıya bir arkadaşlık isteği gönderilmiş mi?
          // Eğer gönderilmişse ve hedef kullanıcı bu isteği henüz kabul etmemişse
          friend_button_status = Constants.cencel_friend;
        } else if (isFriend) {
          //Kullanıcı ve hedef kullanıcı zaten arkadaş mı? Eğer arkadaşlarsa,
          // yani kullanıcının arkadaş listesinde hedef kullanıcı varsa, buton metni "Arkadaşsınız" olarak ayarlanır.
          friend_button_status = Constants.remove_friend;
        }

      }


    } else {
      user = await ref.read(view_model).getUserInfo(context);
      posts = user?.posts; // Kullanıcının postlarını alma
      friends = user?.friends;

      if (posts != null) {
        posts_model = await ref.read(view_model).getPostsByPostIds(posts!);
      }
      if (friends != null) {
        friends_model = await ref.read(view_model).getFriendsByFriendsIds(user?.friends ?? []);
      }

    }



    return user;
  }

  static List<Widget> widgetOptions(
      BuildContext context,
      ProfilePageViewmodel watch,
      List<PostModel>? posts_model,
      List<UserModel>? friends_model, // Alınan veri tipini eşleştirmek için List<UserModel> olarak değiştirildi
      Widget Function(String) getPhoto,
      ) =>
      <Widget>[
        // Gönderiler için ızgara görünümü
        GridView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: posts_model?.length ?? 0, // Gönderi sayısı
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 3 sütunlu bir ızgara
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            // Her bir gönderiyi oluşturun
            PostModel post = posts_model![index];

            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        getPhoto(post.imageUrl), // getPhoto işlevinin bir Widget döndürdüğünü varsayalım
                        IconButton(
                          onPressed: () {
                            // Silme işlemi burada gerçekleştirilebilir
                            print('Post silindi');
                          },
                          icon: Icon(Icons.delete, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        post.caption,
                        style: TextStyle(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Arkadaş listesi
        ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: friends_model?.length ?? 0, // Arkadaş sayısı
          itemBuilder: (context, index) {
            UserModel user = friends_model![index]; // UserModel olarak dönüştürme

            return ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl) // Eğer profil resmi varsa NetworkImage kullan
                    : AssetImage(Constants.logo_path), // Yoksa AssetImage kullan
              ),
              title: Text(user.displayName ?? ""), // Display adını göster
              subtitle: Text(user.bio ?? ""), // Bio bilgisini göster
              onTap: () {
                // Arkadaşa tıklanınca yapılacak işlemler
                // Örneğin arkadaşın profiline gitmek için navigasyon vb.
              },
            );
          },
        ),
      ];


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
            return const Center(child: Text('Kullanıcı verisi bulunamadı.'));
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

            isFriendRequestSent = user.sentFriendRequests!.contains(_auth.currentUser!.uid);
            isFriendRequestReceived = user.receivedFriendRequests!.contains(_auth.currentUser!.uid);
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
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: cover_image.isEmpty
                        ? const Center(child: Text(Constants.empty_cover_photo))
                        : CachedNetworkImage(imageUrl: cover_image),
                  ),
                ),
                // Profil Fotoğrafı
                Positioned(
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profile_pp.isEmpty
                        ? const AssetImage(Constants
                        .logo_path) // Eğer profile_pp boşsa, varsayılan bir resim göster
                        : NetworkImage(profile_pp),
                    // Eğer profile_pp doluysa, profile_pp'deki resmi göster
                    child: profile_pp.isEmpty
                        ? null // Eğer backgroundImage kullanıyorsanız, child kullanmamalısınız. Bu yüzden null olarak bırakın.
                        : ClipOval(
                      child: getPhoto(
                          profile_pp), // Veya getPhoto(profile_pp) kullanarak resmi doldur
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
                  CustomButtonWidgets(funciton: (){
                    Navigator.pushNamed(context, "send_message_page",arguments: userId);
                  }, text: Constants.send_message),


                if(!isFriend)
                  ElevatedButton(
                    onPressed: () async {
                      await _handleFriendRequest(watch, context, userId!);
                      //friend_button_status = await watch.sendFriendsRequest(context, userId!);
                    },
                    child: Text(friend_button_status),
                  ),


                if (isFriend)
                  ElevatedButton(
                    onPressed: () async {
                      // Arkadaşlıktan çıkar işlemi yapılabilir
                      // Örnek olarak:
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
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Seçilen sekme içeriğini gösterme
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: widgetOptions(context, watch, posts_model, friends_model, getPhoto)
                      .elementAt(watch.selectedIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getPhoto(String image_url) {
    return CachedNetworkImage(
      alignment: Alignment.center,
      imageUrl: image_url,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        if (downloadProgress.totalSize != null) {
          final percent = (downloadProgress.progress! * 100).toStringAsFixed(0);
          return Center(
            child: Text("$percent% tamamlandı"),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

