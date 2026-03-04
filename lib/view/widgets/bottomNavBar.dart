import 'package:flutter/material.dart';
import 'package:messager_app/data/notifier.dart';

class Bottomnavbar extends StatelessWidget {
  const Bottomnavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return NavigationBarTheme(
              data: NavigationBarThemeData(
                  labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                      (Set<MaterialState> states) =>
                          states.contains(MaterialState.selected)
                              ? const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)
                              : const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
              child: NavigationBar(
                destinations: [
                  NavigationDestination(
                      icon: Icon(Icons.chat_bubble), label: "Home"),
                  NavigationDestination(
                      icon: Icon(Icons.people), label: "Friends"),
                  NavigationDestination(
                      icon: Icon(Icons.settings), label: "Settings"),
                ],
                onDestinationSelected: (int value) {
                  selectedPageNotifier.value = value;
                },
                selectedIndex: selectedPage,
              ));
        });
  }
}
