import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/model/user_model.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/view_model/settings/settings_page_viewmodel.dart';
import 'package:heychat_2/widgets/custom_divider_widgets.dart';
import 'package:heychat_2/widgets/custom_text_widgets.dart';
import 'package:heychat_2/widgets/custom_textfield_widgets.dart';

final viewModel = ChangeNotifierProvider((ref) => SettingsPageViewmodel());

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _nameAndSurnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String profilePp = "";
  String coverImage = "";
  String _nameAndSurname = "";
  String _email = "";
  String _bio =  "";
  String _username = "";

  late Future<UserModel?> _futureUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _futureUser = _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    var watch = ref.watch(viewModel);
    var read = ref.read(viewModel);
    return RefreshIndicator(
      onRefresh: () async {
        await _refreshUserInfo();
      },
      child: Scaffold(

        body: FutureBuilder<UserModel?>(
          future: _futureUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No user data found.'));
            } else {
              UserModel user = snapshot.data!;
              _nameAndSurname = user.displayName;
              _email = user.email;
              _bio = user.bio;
              _username = user.username;
              profilePp = user.profileImageUrl;
              coverImage = user.coverImageUrl;

              return _buildBody(context, watch, read);
            }
          },
        ),
      ),
    );
  }

  Future<UserModel?> _getUserInfo() async {
    UserModel? user = await ref.watch(viewModel).getUserInfo(context);
    return user;
  }

  Future<void> _refreshUserInfo() async {
    UserModel? user = await _getUserInfo();
    setState(() {
      _futureUser = Future.value(user);
    });
  }

  Widget _buildBody(BuildContext context, SettingsPageViewmodel watch, SettingsPageViewmodel read) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: Constants.screenHeight(context) * 0.4,
            child: Stack(
              children: [
                coverPhoto(),
                backButton(),
                changeCoverPhoto(watch),
                profilePhoto(watch),
              ],
            ),
          ),
          const SizedBox(height: 10),
          CustomTextWidgets(
            text: Constants.update_info,
            color: Colors.white,
          ),
          const SizedBox(height: 7),
          const CustomDividerWidgets(),
          const SizedBox(height: 7),
          _buildTextFieldWithUpdateButton(
            context,
            _bioController,
            _bio,
            const Icon(Icons.info_outline),
                () => watch.updateBio(context, _bioController.text),
          ),
          const SizedBox(height: 7),
          _buildTextFieldWithUpdateButton(
            context,
            _nameAndSurnameController,
            _nameAndSurname,
            const Icon(Icons.person),
                () => watch.updateNameAndSurname(context, _nameAndSurnameController.text),
          ),
          const SizedBox(height: 7),
          _buildTextFieldWithUpdateButton(
            context,
            _usernameController,
            _username,
            const Icon(Icons.person),
                () => watch.updateUsername(context, _usernameController.text),
          ),
          const SizedBox(height: 7),
          _buildTextFieldWithUpdateButton(
            context,
            _emailController,
            _email,
            const Icon(Icons.email),
                () => watch.updateEmail(context, _emailController.text),
          ),
          const SizedBox(height: 7),
          _buildTextFieldWithUpdateButton(
            context,
            _passwordController,
            Constants.password,
            const Icon(Icons.lock),
                () => watch.updatePassword(context, _passwordController.text),
            isPassword: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithUpdateButton(
      BuildContext context,
      TextEditingController controller,
      String hintText,
      Icon prefixIcon,
      VoidCallback onUpdate, {
        bool isPassword = false,
      }) {
    return Row(
      children: [
        Expanded(
          child: CustomTextfieldWidgets(
            controller: controller,
            hint_text: hintText,
            prefix_icon: prefixIcon,
            keyboard_type: isPassword ? TextInputType.visiblePassword : TextInputType.text,
            is_password: isPassword,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onUpdate,
          child: const Text(Constants.update),
        ),
      ],
    );
  }

  Widget changeCoverPhoto(SettingsPageViewmodel watch) {
    return Positioned(
      bottom: 5,
      left: 0,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          onPressed: () async {
            await watch.selectCoverImageInGallery(context, true);
          },
          icon: const Icon(Icons.camera_alt, color: Colors.green),
        ),
      ),
    );
  }

  Widget profilePhoto(SettingsPageViewmodel watch) {
    return Positioned(
      bottom: 0,
      left: Constants.screenWith(context) / 2 - 50,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: profilePp.isEmpty ? null : NetworkImage(profilePp),
            child: profilePp.isEmpty
                ? const Center(child: Text(Constants.empty_profile_photo))
                : ClipOval(
              child: CachedNetworkImage(imageUrl: profilePp),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () async {
                  await watch.selectCoverImageInGallery(context, false);
                },
                icon: const Icon(Icons.camera_alt, color: Colors.pinkAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget backButton() {
    return Positioned(
      top: 10,
      left: 5,
      child: IconButton(
        onPressed: () {
          Navigator.pushNamed(context, "home_page");
        },
        icon: const Icon(Icons.arrow_back, color: Colors.tealAccent),
      ),
    );
  }

  Widget coverPhoto() {
    return Positioned.fill(
      child: coverImage.isEmpty
          ? const Center(child: Text(Constants.empty_cover_photo))
          : CachedNetworkImage(imageUrl: coverImage),
    );
  }
}
