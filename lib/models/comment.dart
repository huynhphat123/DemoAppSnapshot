import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first


class comment {
    
   final String username;
   final String uid;
   final String content;
   final String uimage;
   final String postId;
   final DateTime datePublished;
   final String commentId;
  comment({required this.datePublished, 
    required this.postId,
    required this.username,
    required this.uid,
    required this.content,
    required this.uimage,
    required this.commentId,
  });
   

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "datePublished": datePublished,
      'username': username,
      'uid': uid,
      'content': content,
      'uimage': uimage,
      'commentId': commentId,
      'postId':postId
    };
  }

  factory comment.fromMap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return comment( 
      datePublished: snapshot["datePublished"],
      postId: snapshot['postId'],
      username: snapshot['username']  ,
      uid: snapshot['uid'] ,
      content: snapshot['content'] ,
      uimage: snapshot['uimage'],
      commentId: snapshot['commentId'],
    );
  }

  
}
