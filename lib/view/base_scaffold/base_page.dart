import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/view_model/base_scaffold_view/base_scaffold_viewmodel.dart';

import '../../utils/constants.dart';

final view_model = ChangeNotifierProvider((ref) => BaseScaffoldViewmodel());

class BasePage extends ConsumerStatefulWidget {
  const BasePage({super.key});

  @override
  ConsumerState<BasePage> createState() => _BasePageState();
}

class _BasePageState extends ConsumerState<BasePage> {
  @override
  Widget build(BuildContext context) {
    var watch = ref.watch(view_model);
    var read = ref.read(view_model);

    return Scaffold(
      appBar: watch.showAppBar ? _buildAppBar(read) : null,
      bottomNavigationBar: _buildNavBar(watch),
      body: watch.buildBody(),
    );
  }

  AppBar _buildAppBar(var read) {
    return AppBar(
      title: Text(
        read.title,
        style: const TextStyle(color: Colors.green),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        PopupMenuButton<String>(
          onSelected: (String result) {
            switch (result) {
              case "post":
                read.goPostPage(context);
                break;
              case "request":
                read.goRequestPage(context);
                break;
              case "logout":
                read.signOut(context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'post',
              child: Row(
                children: [
                  Icon(Icons.add),
                  Text(Constants.add_post),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'request',
              child: Row(
                children: [
                  Icon(Icons.notification_important_rounded),
                  Text(Constants.get_friends_request),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app),
                  Text(Constants.exit),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  BottomNavigationBar _buildNavBar(var watch) {
    return BottomNavigationBar(
      selectedItemColor: Colors.pinkAccent,
      unselectedItemColor: Colors.green,
      currentIndex: watch.currentIndex,
      items: watch.items,
      onTap: (newPageIndex) {
        watch.setCurrentIndex(newPageIndex);
      },
    );
  }
}
