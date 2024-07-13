import 'package:flutter/material.dart';
import 'package:heychat_2/view/chats/chats_page.dart';
import 'package:heychat_2/view/feed/feed_page.dart';
import 'package:heychat_2/view/profile/profile_page.dart';
import 'package:heychat_2/view/search/search_page.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class BaseScaffoldViewmodel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  String title = Constants.chats;

  List<String> labels = [
    Constants.chats,
    Constants.feed,
    Constants.search,
    Constants.profile,
  ];
  List<IconData> icons = [
    Icons.chat,
    Icons.arrow_downward,
    Icons.search,
    Icons.person
  ];

  List<BottomNavigationBarItem> get items {
    return List<BottomNavigationBarItem>.generate(labels.length, (index) {
      return BottomNavigationBarItem(
        icon: Icon(icons[index]),
        label: labels[index],
      );
    });
  }

  //Çıkış yap
  Future<void> signOut(BuildContext context) async {
    await _authService.signOut(context);
    notifyListeners();
  }

  //goPostPage
  Future<void> goPostPage(BuildContext context) async {
    Navigator.pushNamed(context, "post_page");
    notifyListeners();
  }

  Future<void> goRequestPage(BuildContext context) async {
    Navigator.pushNamed(context, "request_page");
    notifyListeners();
  }

  int _currentIndex = 0;
  bool _showAppBar = true;

  int get currentIndex => _currentIndex;

  bool get showAppBar => _showAppBar;

  void setCurrentIndex(int i) {
    _currentIndex = i;
    title = labels[i];
    _showAppBar = i != 3;
    notifyListeners();
  }

  Widget buildBody() {
    switch (_currentIndex) {
      case 0:
        return ChatsPage();
      case 1:
        return FeedPage();
      case 2:
        return SearchPage();
      case 3:
        return ProfilePage();
      default:
        return ChatsPage();
    }
  }
}
