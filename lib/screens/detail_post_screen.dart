import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lvtn_mangxahoi/resources/firestore_method.dart';
import 'package:lvtn_mangxahoi/responsive/mobile_screen_layout.dart';
import 'package:lvtn_mangxahoi/responsive/web_screen_layout.dart';
import 'package:lvtn_mangxahoi/screens/comment_screen.dart';
import 'package:lvtn_mangxahoi/screens/home_screen.dart';
import 'package:lvtn_mangxahoi/screens/profile_screen.dart';
import 'package:lvtn_mangxahoi/screens/update_post_screen.dart';
import 'package:lvtn_mangxahoi/utils/colors.dart';
import 'package:lvtn_mangxahoi/utils/key_shared.dart';
import 'package:lvtn_mangxahoi/utils/sharedpreference.dart';

import '../responsive/responsive_layout_screen.dart';

class detailPost extends StatefulWidget {
  final snap;
  final String idpost;
  const detailPost({super.key, this.snap, required this.idpost});

  @override
  State<detailPost> createState() => _detailPostState();
}

class _detailPostState extends State<detailPost> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  bool _checkLike = false;
  bool _checkSave = false;
  int likeCount = 0;

  void getResultLiked() async {
    bool data = await fireMethod.checUserLiked(
        id: FirebaseAuth.instance.currentUser!.uid, idpost: widget.idpost);
    bool dataSave = await fireMethod.checUserSaved(
        id: FirebaseAuth.instance.currentUser!.uid, idpost: widget.idpost);
    likeCount = await fireMethod.checCountUserLiked(idpost: widget.idpost);
    setState(() {
      _checkLike = data;
      _checkSave = dataSave;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getResultLiked();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                ),
              ),
            );
          },
          icon: Icon(
            Icons.keyboard_backspace,
            color: Colors.black,
          ),
        ),
        title: Text(
          "Bài viếttt",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.snap['profImage']),
                    maxRadius: 16.0,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(uid: widget.snap['uid']),
                            ));
                      },
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.snap['username'],
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(color: Colors.black),
                            ),
                            Text(
                              DateFormat.yMMMd().format(
                                  widget.snap['datePublished'].toDate()),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(color: const Color(0xFFD8D8D8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  sharedPreferences.getString(keyShared.CURRENTUSER) ==
                          widget.snap['uid']
                      ? InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 120.0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          dialogCustomNoti(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black,
                                                      width: 0.1))),
                                          padding: EdgeInsets.only(left: 10),
                                          alignment: Alignment.centerLeft,
                                          height: 60,
                                          width: double.infinity,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 17,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Xóa bài viết"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                            builder: (context) {
                                              return updatePostScreen(
                                                idpost: widget.idpost,
                                                snap: widget.snap,
                                              );
                                            },
                                          ));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black,
                                                      width: 0.1))),
                                          padding: EdgeInsets.only(left: 10),
                                          alignment: Alignment.centerLeft,
                                          height: 60,
                                          width: double.infinity,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 17,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Chỉnh sửa bài viết"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                         child: Container(
                            height: 30,
                            margin: const EdgeInsets.only(right: 10),
                            child: const Icon(
                              Icons.more_vert,
                              color: Color.fromARGB(255, 181, 176, 176),
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ), 
            SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                widget.snap['description'] ?? "",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.snap['postUrl']),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              color: Colors.black,
              height: 1,
            ),
            Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        height: 50,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              likeCount.toString(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ), //sửa style cho chữ và kích cỡ
            ),
            _checkLike
                ? IconButton(
                    onPressed: () async {
                      fireMethod.userLikePost(
                          id: FirebaseAuth.instance.currentUser!.uid,
                          idpost: widget.idpost,
                          idUserPost: widget.snap['uid']);
                      setState(() {
                        _checkLike = false;
                        likeCount--;
                      });
                    },
                    icon: const Icon(
                      Icons.favorite,
                      color: Color.fromARGB(255, 74, 7, 231),
                    ),
                  )
                : IconButton(
                    onPressed: () async {
                      fireMethod.userLikePost(
                          id: FirebaseAuth.instance.currentUser!.uid,
                          idpost: widget.idpost,
                          idUserPost: widget.snap['uid']);
                      setState(() {
                        _checkLike = true;
                        likeCount++;
                      });
                    },
                    icon: const Icon(
                      Icons.favorite_border_outlined,
                      color: Colors.black,
                    ),
                  ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where("postId", isEqualTo: widget.idpost)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Text(
                  snapshot.data!.docs.length.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => commentScreen(
                          postId: widget.snap['postId'],
                          uidPost: widget.snap['uid']),
                    ));
              },
              icon: const Icon(
                Icons.comment_outlined,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.send,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: _checkSave == false
                    ? IconButton(
                        onPressed: () {
                          fireMethod.userSavePost(
                              id: FirebaseAuth.instance.currentUser!.uid,
                              idpost: widget.idpost);
                          setState(() {
                            _checkSave = true;
                          });
                        },
                        icon: const Icon(
                          Icons.bookmark_border,
                          color: Colors.black,
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          fireMethod.userSavePost(
                              id: FirebaseAuth.instance.currentUser!.uid,
                              idpost: widget.idpost);
                          setState(() {
                            _checkSave = false;
                          });
                        },
                        icon: const Icon(
                          Icons.bookmark_rounded,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
          ],
        ),
      ),
     
    );
  }

  Future<dynamic> dialogCustomNoti(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thông báo'),
          content: Text('Bạn muốn xóa bài viết ?'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Đồng ý'),
              onPressed: () async {
                // Do something when the user presses the OK button.
                String result = await fireMethod.deletePost(widget.idpost);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result),
                    duration: Duration(seconds: 3),
                  ),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ResponsiveLayout(
                      mobileScreenLayout: MobileScreenLayout(),
                      webScreenLayout: WebScreenLayout(),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
