import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lvtn_mangxahoi/resources/storage_method.dart';
import 'package:uuid/uuid.dart';

import '../models/comment.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../models/post.dart';
import '../models/user.dart';


class FireStoreMethods {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static auth.FirebaseAuth Auth = auth.FirebaseAuth.instance;

  static late User me;

  static auth.User get user => Auth.currentUser!;

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_follow_user')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      User chatUser) {
    return firestore
        .collection('users')
        .where('uid', isEqualTo: chatUser.uid)
        .snapshots();
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = User.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        updateActiveStatus(true);
        log('My Data: ${user.data()}');
      }
      // else {
      //   await createUser().then((value) => getSelfInfo());
      // }
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('uid',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      User chatUser) {
    return firestore
        .collection('chats/${getConversationID(chatUser.uid)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print('Push Token: $t');
      }
    });
  }

  static Future<void> sendMessage(User chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.uid,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.uid)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(User user) {
    return firestore
        .collection('chats/${getConversationID(user.uid)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(User chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = StorageMethods.storage.ref().child(
        'images/${getConversationID(chatUser.uid)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  // for sending push notification
  // static Future<void> sendPushNotification(
  //     User chatUser, String msg) async {
  //   try {
  //     final body = {
  //       "to": chatUser.pushToken,
  //       "notification": {
  //         "title": me.name, //our name should be send
  //         "body": msg,
  //         "android_channel_id": "chats"
  //       },
  //       // "data": {
  //       //   "some_data": "User ID: ${me.id}",
  //       // },
  //     };
  //     var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //         headers: {
  //           HttpHeaders.contentTypeHeader: 'application/json',
  //           HttpHeaders.authorizationHeader:
  //               'key=AAAAQ0Bf7ZA:APA91bGd5IN5v43yedFDo86WiSuyTERjmlr4tyekbw_YW6JrdLFblZcbHdgjDmogWLJ7VD65KGgVbETS0Px7LnKk8NdAz4Z-AsHRp9WoVfArA5cNpfMKcjh_MQI-z96XQk5oIDUwx8D1'
  //         },
  //         body: jsonEncode(body));
  //     log('Response status: ${res.statusCode}');
  //     log('Response body: ${res.body}');
  //   } catch (e) {
  //     log('\nsendPushNotificationE: $e');
  //   }
  // }

  // static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages() {
  //   return firestore.collection('messages').snapshots();
  // }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

 Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage, List titlePost) async {
    String res = "Some error";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        saves: [],
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        titlePost: titlePost,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  static Future<void> uploadTitle(List<String> selectedTopics) async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'titleUser': selectedTopics});
  }

  Future<String> updateInforUser(
      {Uint8List? file, String? id, String? username, String? bio}) async {
    try {
      late String photoUrl = "";
      if (file != null) {
        // set hình vào strage firebase
        photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePic', file, true);
      }

      Map<String, dynamic> data = Map();
      if (username!.isNotEmpty) {
        data['username'] = username;
      }
      if (bio!.isNotEmpty) {
        data['bio'] = bio;
      }
      if (photoUrl != "") {
        data['photoUrl'] = photoUrl;
      }

      firestore.collection("users").doc(id).get().then((value) {
        if (value.exists) {
          return firestore.collection("users").doc(id).update(data);
        } else {
          return "dont found";
        }
      });
    } catch (e) {
      print(e);
    }
    return "";
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> userLikePost({String? id, String? idpost}) async {
    try {
      //tim user haved like post
      final a = await firestore.collection("posts").doc(idpost).get();
      Map<String, dynamic>? map = a.data();
      for (var element in List.from(map!['likes'])) {
        if (id == element) {
          //delete elemet
          firestore.collection("posts").doc(idpost).get().then((value) {
            if (value.exists) {
              return firestore.collection("posts").doc(idpost).update({
                "likes": FieldValue.arrayRemove([id])
              });
            } else {
              return "dont found";
            }
          });
          return "unlike";
        }
      }
      //like
      firestore.collection("posts").doc(idpost).get().then((value) {
        if (value.exists) {
          return firestore.collection("posts").doc(idpost).update({
            "likes": FieldValue.arrayUnion([id])
          });
        } else {
          return "dont found";
        }
      });
    } catch (e) {
      print(e);
    }
    return "";
  }

  Future<dynamic> checUserLiked({String? id, String? idpost}) async {
    // kiểm tra xem user đã like chưa
    try {
      final a = await firestore.collection("posts").doc(idpost).get();
      Map<String, dynamic>? map = a.data();
      for (var element in List.from(map!['likes'])) {
        if (id == element) {
          return true;
        }
      }
    } catch (e) {
      return e;
    }
    return false;
  }

  Future<dynamic> checUserSaved({String? id, String? idpost}) async {
        // kiểm tra xem user đã save chưa

    try {
      final a = await firestore.collection("posts").doc(idpost).get();
      Map<String, dynamic>? map = a.data();
      for (var element in List.from(map!['saves'])) {
        if (id == element) {
          return true;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<dynamic> addComment(comment cmt) async {
    //them comment vô 
    try {
      await firestore
          .collection("comments")
          .doc(cmt.commentId)
          .set(cmt.toMap());
    } catch (e) {
      return e;
    }
    return false;
  }

  Future<dynamic> countComment(String idpost) async {
    // đếm số lượng comment
    try {
      QuerySnapshot result = await firestore
          .collection("comments")
          .where("postId", isEqualTo: idpost)
          .get();
      return result;
    } catch (e) {
      return 0;
    }
  }

  Future<String> userSavePost({String? id, String? idpost}) async {
    //update khi user lưu hoặc bỏ lưu
    try {
      //tim user haved like post
      final a = await firestore.collection("posts").doc(idpost).get();
      Map<String, dynamic>? map = a.data();
      for (var element in List.from(map!['saves'])) {
        if (id == element) {
          //delete elemet
          firestore.collection("posts").doc(idpost).get().then((value) {
            if (value.exists) {
              return firestore.collection("posts").doc(idpost).update({
                "saves": FieldValue.arrayRemove([id])
              });
            } else {
              return "dont found";
            }
          });
          return "unsave";
        }
      }
      //save
      firestore.collection("posts").doc(idpost).get().then((value) {
        if (value.exists) {
          return firestore.collection("posts").doc(idpost).update({
            "saves": FieldValue.arrayUnion([id])
          });
        } else {
          return "dont found";
        }
      });
    } catch (e) {
      print(e);
    }
    return "";
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> readPosts(int postCount) {
    StreamController<QuerySnapshot<Map<String, dynamic>>> streamController =
        StreamController<QuerySnapshot<Map<String, dynamic>>>();
    firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> userSnapshot) async {
      List<String> userTopics = [];
      if (userSnapshot.exists && userSnapshot.data() != null) {
        List<dynamic> arrayData =
            (userSnapshot.data() as dynamic)['following'].toList();
        if (arrayData != null && arrayData is List<dynamic>) {
          userTopics = List<String>.from(arrayData);
        }
      }
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('posts')
          .where('uid', whereIn: userTopics)
          // .orderBy('timestamp', descending: true)
          .limit(postCount)
          .get();
      // Thêm kết quả truy vấn vào Stream
      streamController.add(querySnapshot);
    });

    return streamController.stream;
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getChat() {
   
    return firestore
        .collection('users')
        .where('uid', whereIn: me.following)
        .snapshots();
  }
  static Future<QuerySnapshot<Map<String, dynamic>>>
      getPostsByUserTopics() async {
    // Lấy danh sách chủ đề của người dùng hiện tại
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    List<String> userTopics = [];
    // List<String> userTopics = (userSnapshot.data() as dynamic)['titleUser'];
    if (userSnapshot.exists && userSnapshot.data() != null) {
      List<dynamic> arrayData =
          (userSnapshot.data() as dynamic)['titleUser'].toList();
      if (arrayData != null && arrayData is List<dynamic>) {
        userTopics = List<String>.from(arrayData);
      }
    }
    QuerySnapshot<Map<String, dynamic>> postSnapshot = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('titlePost', arrayContainsAny: userTopics)
        .get();

    // Lấy danh sách các bài post
    List<DocumentSnapshot> posts = postSnapshot.docs;

    // return posts;
    return postSnapshot;
  }
  static Future<void> addReport(
      String idPost, String description, String postUrl) async {
    String reportId = const Uuid().v1();
    await FirebaseFirestore.instance.collection('reports').add({
      'idReport': reportId,
      'idPost': idPost,
      'idUser': user.uid,
      'description': description,
      'photoUrlPost': postUrl,
      'time': Timestamp.now().millisecondsSinceEpoch.toString(),
    });
  }
  Future<void> addFollowUser(String id) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_follow_user')
        .doc(id)
        .set({});
    await firestore.collection('users').doc(id).update({'createdAt': time});
  }
  static Future<void> sendFirstMessage(
      User chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.uid)
        .collection('my_follow_user')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }
}

  
FireStoreMethods fireMethod = new FireStoreMethods();
