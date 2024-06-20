import 'package:flutter/cupertino.dart';

class ProfilePageViewmodel extends ChangeNotifier{
  int selectedIndex = 0;

  void onItemTapped(int index) {
      selectedIndex = index;
      notifyListeners();
  }

  void goSettingsPage(BuildContext context){
    Navigator.pushNamed(context, "settings_page");
    notifyListeners();
  }

}