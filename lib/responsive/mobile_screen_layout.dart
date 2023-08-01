import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lvtn_mangxahoi/resources/firestore_methods.dart';
import 'package:lvtn_mangxahoi/screens/add_post_screen.dart';
import 'package:lvtn_mangxahoi/screens/feed_screen.dart';
import 'package:lvtn_mangxahoi/screens/home_screen.dart';
import 'package:lvtn_mangxahoi/screens/notification_screen.dart';
import 'package:lvtn_mangxahoi/screens/profile_screen.dart';
import 'package:lvtn_mangxahoi/screens/search_screen.dart';
import 'package:lvtn_mangxahoi/utils/colors.dart';
import 'package:lvtn_mangxahoi/utils/global_variables.dart';
import 'package:lvtn_mangxahoi/utils/key_shared.dart';
import 'package:lvtn_mangxahoi/utils/sharedpreference.dart';

import '../utils/global_variables.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
    FireStoreMethods.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (FireStoreMethods.Auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          FireStoreMethods.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          FireStoreMethods.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }
  

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }
  List<Widget> getList(){
    String a =sharedPreferences.getString(keyShared.CURRENTUSER);
    return [
  // const Text('Notifications'),
  const HomeScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const notificationScreen(),
  ProfileScreen(
     uid: sharedPreferences.getString(keyShared.CURRENTUSER),
  ),
];

  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: getList(),
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: kWhite,
        color: k2MainThemeColor,
        animationDuration: Duration(milliseconds: 300),
        height: 60,
        items: [
          Icon(
              Icons.home,
              color: _page == 0 ? blackColor : secondaryColor,
            ),
            Icon(
              Icons.search,
              color: _page == 1 ? blackColor : secondaryColor,
            ),
            Icon(
              Icons.add_circle,
              color: _page == 2 ? blackColor : secondaryColor,
            ),
            Icon(
              Icons.notifications,
              color: _page == 3 ? blackColor : secondaryColor,
            ),
            Icon(
              Icons.person,
              color: _page == 4 ? blackColor : secondaryColor,
            ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.home,
          //     color: _page == 0 ? primaryColor : secondaryColor,
          //   ),
          //   backgroundColor: primaryColor,
          //   label: '',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.search,
          //     color: _page == 1 ? primaryColor : secondaryColor,
          //   ),
          //   backgroundColor: primaryColor,
          //   label: '',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.add_circle,
          //     color: _page == 2 ? primaryColor : secondaryColor,
          //   ),
          //   backgroundColor: primaryColor,
          //   label: '',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.notifications,
          //     color: _page == 3 ? primaryColor : secondaryColor,
          //   ),
          //   backgroundColor: primaryColor,
          //   label: '',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.person,
          //     color: _page == 4 ? primaryColor : secondaryColor,
          //   ),
          //   backgroundColor: primaryColor,
          //   label: '',
          // ),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
