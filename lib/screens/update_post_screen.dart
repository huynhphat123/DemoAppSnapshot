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
import 'package:lvtn_mangxahoi/utils/colors.dart';
import 'package:lvtn_mangxahoi/utils/key_shared.dart';
import 'package:lvtn_mangxahoi/utils/sharedpreference.dart';

import '../responsive/responsive_layout_screen.dart';

class updatePostScreen extends StatefulWidget {
  final snap;
  final String idpost;
  const updatePostScreen({super.key, this.snap, required this.idpost});

  @override
  State<updatePostScreen> createState() => _updatePostScreenState();
}

class _updatePostScreenState extends State<updatePostScreen> {
  TextEditingController titleController = TextEditingController();
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
    titleController.text = widget.snap['description'] ?? "";
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                "Chỉnh sửa bài viết",
                style: TextStyle(color: Colors.black),
              ),
            ),
            InkWell(
              onTap: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.black,
                      content: Text(
                        'Không được để trống!',
                        style: TextStyle(color: Colors.white),
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  final result = await fireMethod.updatePost(
                      idpost: widget.idpost, description: titleController.text);
                  if (result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.black,
                        content: Text(
                          'Thay đổi thành công!',
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(uid: widget.snap['uid']),
                        ));
                  }
                }
              },
              child: Container(
                height: 30,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(7))),
                child: Center(
                    child: Text(
                  "Lưu",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                )),
              ),
            )
          ],
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
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: titleController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(border: InputBorder.none),
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
