import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/widgets/custom_cardview_widgets.dart';
import 'package:heychat_2/widgets/custom_text_widgets.dart';

import '../../model/post_model.dart';
import '../../model/user_model.dart';
import '../../services/firestore_service.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<PostWithUser>> _postsWithUsers;

  @override
  void initState() {
    super.initState();
    _postsWithUsers = _fetchPostsWithUsers();
  }

  Future<List<PostWithUser>> _fetchPostsWithUsers() async {
    List<PostModel> posts = await _firestoreService.getPosts();
    List<PostWithUser> postsWithUsers = [];

    for (PostModel post in posts) {
      UserModel user = await _firestoreService.getUserById(post.userId);
      postsWithUsers.add(PostWithUser(post: post, user: user));
    }
    return postsWithUsers;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostWithUser>>(
      future: _postsWithUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No posts available.'));
        }

        List<PostWithUser> postsWithUsers = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            children: postsWithUsers.map((postWithUser) => buildPostCard(postWithUser)).toList(),
          ),
        );
      },
    );
  }

  Widget buildPostCard(PostWithUser postWithUser) {
    PostModel post = postWithUser.post;
    UserModel user = postWithUser.user;

    return CustomCardviewWidgets(
      container: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? NetworkImage(user.profileImageUrl)
                      : AssetImage('assets/default_profile.png') as ImageProvider, // Varsayılan resim
                ),
                const SizedBox(width: 5),
                CustomTextWidgets(
                  text: user.displayName,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              height: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                  image: CachedNetworkImageProvider(post.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              leading: IconButton(
                onPressed: () {
                  // Beğenme işlemi için gerekli kodu buraya ekleyin
                },
                icon: Icon(Icons.favorite_border),
              ),
              trailing: IconButton(
                onPressed: () {
                  // Yorum yapma işlemi için gerekli kodu buraya ekleyin
                },
                icon: Icon(Icons.comment_rounded),
              ),
              title: Text(post.caption),
            ),
            SizedBox(height: 10),
            // Yorumlar bölümü
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: post.comments.map((comment) {
                // Her yorum için ListTile oluştur
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(comment.split(':')[0][0]), // Yorum yapanın ilk harfi
                  ),
                  title: Text(comment),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget getPhoto(String imageUrl) {
    return CachedNetworkImage(
      alignment: Alignment.center,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        if (downloadProgress.totalSize != null) {
          final percent = (downloadProgress.progress! * 100).toStringAsFixed(0);
          return Center(
            child: Text("$percent% done loading"),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class PostWithUser {
  final PostModel post;
  final UserModel user;

  PostWithUser({required this.post, required this.user});
}
