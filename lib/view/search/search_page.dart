import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/view/profile/profile_page.dart';
import 'package:heychat_2/view_model/search/search_page_viewmodel.dart';
import 'package:heychat_2/widgets/custom_textfield_widgets.dart';

import '../../model/user_model.dart';

final view_model = ChangeNotifierProvider((ref) => SearchPageViewmodel());

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<SearchPage> {
  TextEditingController search_text_controller = TextEditingController();
  List<UserModel> searchResults = [];
  
  @override
  Widget build(BuildContext context) {
    var watch = ref.watch(view_model);
    var read = ref.read(view_model);
    return Scaffold(
      body: _buildBody(context, watch, read),
    );
  }

  Widget _buildBody(BuildContext context, var watch, var read) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTextfieldWidgets(
            controller: search_text_controller,
            hint_text: Constants.search,
            prefix_icon: const Icon(Icons.search),
            keyboard_type: TextInputType.text,
            onChanged: (value) async {
              if(value.isNotEmpty)  {
                print("test");
                await watch.searchUserWithUsername(context,value).then((user){
                  if (user != null) {
                    // Kullanıcı bulundu ise ListTile içinde göster
                    setState(() {
                      searchResults = [user];
                    });

                  } else {
                    setState(() {
                      searchResults = [];
                    });
                  }
                });

              }else{
                setState(() {
                  searchResults = [];
                });

              }
            },
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              UserModel user = searchResults[index];
              return ListTile(
                leading: getPhoto(user.profileImageUrl),
                title: Text(user.displayName),
                subtitle: Text(user.username),
                trailing: user.isOnline ? Container(width: 15, child: const CircleAvatar(backgroundColor: Colors.green,)) : Container(width: 15,child: const CircleAvatar(backgroundColor: Colors.grey,)) ,
                onTap: () {
                  // ListTile'a tıklama işlemini burada işleyebilirsiniz
                  Navigator.pushNamed(context, "profile_page",arguments: user.uid);

                },
              );
            },
          ),
        ],
      ),
    );
  }
  Widget getPhoto(String image_url) {
    if(image_url.isNotEmpty){
      return ClipOval(
        child: CachedNetworkImage(
          alignment: Alignment.center,
          imageUrl: image_url,
          progressIndicatorBuilder: (context, url, downloadProgress) {
            if (downloadProgress.totalSize != null) {
              final percent =
              (downloadProgress.progress! * 100).toStringAsFixed(0);
              return Center(
                child: Text("$percent% done loading"),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },

        ),
      );
    }else{
      return Image.asset(Constants.logo_path);
    }

  }
}
