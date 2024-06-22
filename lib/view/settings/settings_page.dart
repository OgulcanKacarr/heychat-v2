import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/model/post_model.dart';
import 'package:heychat_2/model/user_model.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/view_model/settings/settings_page_viewmodel.dart';
import 'package:heychat_2/widgets/custom_divider_widgets.dart';
import 'package:heychat_2/widgets/custom_text_widgets.dart';
import 'package:heychat_2/widgets/custom_textfield_widgets.dart';

final view_model = ChangeNotifierProvider((ref) => SettingsPageViewmodel());

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  TextEditingController _nameAndSurnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String profile_pp = "";
  String cover_image = "";

  late Future<UserModel?> _futureUser;


  @override
  void initState() {
    super.initState();
    _futureUser = _getUserInfo();


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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data found.'));
          } else {
            UserModel user = snapshot.data!;
            _nameAndSurnameController.text = user.displayName;
            _emailController.text = user.email;
            _bioController.text = user.bio;
            _usernameController.text = user.username;
            profile_pp = user.profileImageUrl;
            cover_image = user.coverImageUrl;

            return _buildBody(context, watch, read);
          }
        },
      ),
    );
  }

  Future<UserModel?> _getUserInfo() async {
    UserModel? user = await ref.read(view_model).getUserInfo(context);
    return user;
  }


  Widget _buildBody(BuildContext context, SettingsPageViewmodel watch,
      SettingsPageViewmodel read) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Cover Photo and Profile Photo
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                // Cover Photo
                Positioned(
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: cover_image.isEmpty
                        ? const Center(child: Text(Constants.empty_cover_photo))
                        : CachedNetworkImage(imageUrl: cover_image),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 5,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "home_page");
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.tealAccent,
                    ),
                  ),
                ),

                // Change Cover Photo
                Positioned(
                  bottom: 5,
                  left: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () async {
                        await watch.selectCoverImageInGallery(context, true);
                      },
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                // Profile Photo
                Positioned(
                  bottom: 0,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profile_pp.isEmpty
                        ? null// Eğer profile_pp boşsa, varsayılan bir resim göster
                        : NetworkImage(profile_pp),
                    // Eğer profile_pp doluysa, profile_pp'deki resmi göster
                    child: profile_pp.isEmpty
                        ? Stack(
                            children: [
                              profile_pp.isEmpty
                                  ? const Center(
                                      child:
                                          Text(Constants.empty_profile_photo))
                                  : CachedNetworkImage(imageUrl: profile_pp),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    onPressed: () async {
                                      await watch.selectCoverImageInGallery(
                                          context, false);
                                    },
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.pinkAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ) // Eğer backgroundImage kullanıyorsanız, child kullanmamalısınız. Bu yüzden null olarak bırakın.
                        : ClipOval(
                            child: getPhoto(
                                profile_pp), // Veya getPhoto(profile_pp) kullanarak resmi doldur
                          ),
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextWidgets(
            text: Constants.update_info,
            color: Colors.white,
          ),
          const SizedBox(
            height: 5,
          ),
          const CustomDividerWidgets(),
          const SizedBox(
            height: 5,
          ),
          // Bio
          _buildTextFieldWithUpdateButton(
              context,
              _bioController,
              Constants.bio,
              const Icon(Icons.info_outline),
              () => read.updateBio(context, _bioController.text)),
          // Name and surname
          const SizedBox(
            height: 5,
          ),
          _buildTextFieldWithUpdateButton(
            context,
            _nameAndSurnameController,
            Constants.name_and_surname,
            const Icon(Icons.person),
            () => watch.updateNameAndSurname(
                context, _nameAndSurnameController.text),
          ),
          // Username
          const SizedBox(
            height: 5,
          ),
          _buildTextFieldWithUpdateButton(
              context,
              _usernameController,
              Constants.username,
              const Icon(Icons.person),
              () => watch.updateUsername(context, _usernameController.text)),
          // Email
          const SizedBox(
            height: 5,
          ),
          _buildTextFieldWithUpdateButton(
              context,
              _emailController,
              Constants.email,
              const Icon(Icons.email),
              () => watch.updateEmail(context, _emailController.text)),
          // Password
          const SizedBox(
            height: 5,
          ),
          _buildTextFieldWithUpdateButton(
              context,
              _passwordController,
              Constants.password,
              const Icon(Icons.lock),
              () => watch.updatePassword(context, _passwordController.text),
              isPassword: true),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithUpdateButton(
      BuildContext context,
      TextEditingController controller,
      String hintText,
      Icon prefixIcon,
      VoidCallback onUpdate,
      {bool isPassword = false}) {
    return Row(
      children: [
        Expanded(
          child: CustomTextfieldWidgets(
            controller: controller,
            hint_text: hintText,
            prefix_icon: prefixIcon,
            keyboard_type:
                isPassword ? TextInputType.visiblePassword : TextInputType.text,
            is_password: isPassword,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton(
          onPressed: onUpdate,
          child: const Text(Constants.update),
        ),
      ],
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
