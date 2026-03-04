import 'package:flutter/material.dart';
import 'package:messager_app/data/notifier.dart';
import 'package:messager_app/view/find_people_page.dart';
import 'package:messager_app/view/home_page.dart';
import 'package:messager_app/view/settings_page.dart';
import 'package:messager_app/view/widgets/bottomNavBar.dart';

List<Widget> pages = [HomePage(), FindPeoplePage(), SettingsPage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: ValueListenableBuilder(
          valueListenable: selectedPageNotifier,
          builder: (context, selectedPage, child) {
            return pages.elementAt(selectedPage);
          }),
      bottomNavigationBar: Bottomnavbar(),
    ));
  }
}
