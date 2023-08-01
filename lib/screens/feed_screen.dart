import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lvtn_mangxahoi/utils/colors.dart';
import 'package:lvtn_mangxahoi/widgets/background_home.dart';
import 'package:lvtn_mangxahoi/widgets/post_card.dart';
import '../utils/global_variables.dart';
import 'chat_screen.dart';
import 'message_screen.dart';

class FeedScreen extends StatefulWidget {
  
  const FeedScreen({super.key});

  @override

  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
   
    final width = MediaQuery.of(context).size.width;
    return BackgroungHome(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 206, 5, 5),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shadowColor: Colors.transparent,
          backgroundColor: Color.fromARGB(0, 234, 8, 8),
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SvgPicture.asset(
              'assets/ic_snapshare.svg',
              
              height: 32,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.facebookMessenger,
                color: kBlack,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width * 0.3 : 0,
                  vertical: width > webScreenSize ? 15 : 0,
                ),
                child: PostCard(
                  snap: snapshot.data!.docs[index].data(),
                  idpost:snapshot.data!.docs[index].id,
                ),
              ),
            );
          },
        ),
      ),
    );
    ;
  }
}
