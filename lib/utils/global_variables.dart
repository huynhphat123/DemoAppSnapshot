import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lvtn_mangxahoi/screens/home_screen.dart';
import 'package:lvtn_mangxahoi/screens/profile_screen.dart';
import 'package:lvtn_mangxahoi/screens/search_screen.dart';

const webScreenSize = 600;

List <Widget> HomeScreenItems = [
  const Text('notif'),
  const SearchScreen(),
  const Text('Posts'),
  const Text('Notifications'),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
