import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lvtn_mangxahoi/resources/auth_method.dart';
import 'package:lvtn_mangxahoi/screens/feed_screen.dart';
import 'package:lvtn_mangxahoi/screens/profile_screen.dart';
import 'package:lvtn_mangxahoi/screens/search_screen.dart';
import 'package:lvtn_mangxahoi/utils/key_shared.dart';
import 'package:lvtn_mangxahoi/utils/sharedpreference.dart';

import '../screens/add_post_screen.dart';
import '../screens/notification_screen.dart';

const webScreenSize = 600;

List <Widget> HomeScreenItems = [
  // const Text('Notifications'),
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const notificationScreen(),
  ProfileScreen(
     uid: sharedPreferences.getString(keyShared.CURRENTUSER),
  ),
];




