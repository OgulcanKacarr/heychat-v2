import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/view_model/profil/profile_page_viewmodel.dart';
import 'package:heychat_2/widgets/custom_divider_widgets.dart';
import 'package:heychat_2/widgets/custom_text_widgets.dart';

final viewModelProvider = ChangeNotifierProvider((ref) => ProfilePageViewmodel());

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {

  static List<Widget> widgetOptions(
      BuildContext context, ProfilePageViewmodel watch) =>
      <Widget>[
        GridView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: 20, // Number of posts
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            return Container(
              color: Colors.grey[300],
              child: Center(child: Text('Post $index')),
            );
          },
        ),
        ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: 20, // Number of friends
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text('A$index'),
              ),
              title: Text('Friend $index'),
            );
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    var watch = ref.watch(viewModelProvider);
    var read = ref.read(viewModelProvider);
    return Scaffold(
      body: _buildBody(context, watch,read),
    );
  }

  Widget _buildBody(BuildContext context, ProfilePageViewmodel watch, ProfilePageViewmodel read) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Cover Photo and Profile Photo
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cover Photo
                Positioned(
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    color: Colors.red,
                  ),
                ),
                // Profile Photo
                Positioned(
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 50,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        alignment: Alignment.center,
                        imageUrl:
                        "https://avatars.githubusercontent.com/u/63792003?v=4",
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) {
                          if (downloadProgress.totalSize != null) {
                            final percent = (downloadProgress.progress! * 100)
                                .toStringAsFixed(0);
                            return Center(
                              child: Text("$percent% done loading"),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                    right: 5,
                    child: IconButton(
                  onPressed: (){
                    read.goSettingsPage(context);
                  }, icon: Icon(Icons.settings),
                )),
              ],
            ),
          ),
          const SizedBox(height: 7),
          // Display Name, Username and Bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextWidgets(
                      text: "Oğulcan KAÇAR",
                      color: Colors.white,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Container(
                        width: 15,
                        height: 15,
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                // isOnline Indicator
                const SizedBox(height: 2),
                CustomTextWidgets(
                  text: "ogulcankacar",
                  color: Colors.white,
                  font_size: 10,
                ),
                const SizedBox(height: 15),
                CustomTextWidgets(
                  text: "Kılıcın aydınlattığı, kalemin parlattığı",
                  color: Colors.white,
                  font_size: 10,
                ),
                const SizedBox(height: 5),
                const CustomDividerWidgets(),
                const SizedBox(height: 15),
              ],
            ),
          ),
          // Followers and Following Buttons
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
          const SizedBox(height: 10),
          // Display selected tab content
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // Adjust height as needed
            child: widgetOptions(context, watch).elementAt(watch.selectedIndex),
          ),
        ],
      ),
    );
  }
}
