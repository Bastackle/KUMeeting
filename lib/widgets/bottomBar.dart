import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/widgetScreens/home_screen.dart';
import 'package:project/screens/widgetScreens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/screens/widgetScreens/reservationList.dart';
import 'package:project/screens/widgetScreens/search_screen.dart';

class BottomBar extends StatefulWidget {
  BottomBar({super.key});
  final user = FirebaseAuth.instance.currentUser;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = [
    HomeScreen(),
    SearchScreen(),
    reservationList(),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55),
          child: AppBar(
            title: Text(
              'KUMeeting',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Mitr',
                color: Theme.of(context).primaryColor,
                fontSize: 35,
              ),
            ),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            elevation: 2,
            actions: [
              IconButton(
                icon: Icon(
                  FluentIcons.person_circle_12_regular,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(),
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        body: _widgetOptions[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTap,
          elevation: 10,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                FluentIcons.home_12_regular,
              ),
              activeIcon: Icon(FluentIcons.home_12_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
                icon: Icon(FluentIcons.search_12_regular),
                activeIcon: Icon(FluentIcons.search_12_filled),
                label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(FluentIcons.ticket_diagonal_16_regular),
                activeIcon: Icon(FluentIcons.ticket_diagonal_16_filled),
                label: 'Ticket'),
          ],
        ));
  }
}
