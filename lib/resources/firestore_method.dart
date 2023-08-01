import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lvtn_mangxahoi/models/comment.dart';
import 'package:lvtn_mangxahoi/models/notification.dart';
import 'package:lvtn_mangxahoi/models/post.dart';
import 'package:lvtn_mangxahoi/models/user.dart' as userM;
import 'package:uuid/uuid.dart';

import 'storage_method.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  Future<String> updateInforUser({Uint8List? file,String? id,String? username,String? bio})async {
    try{
      late String photoUrl="";
      if(file!=null){
          //set hình vào storege firebase
          photoUrl = await StorageMethods().uploadImageToStorage('profilePic', file, true);
      }
      
      Map<String,dynamic> data = Map();
      if(username!.isNotEmpty){
        data['username']= username;
      }
      if(bio!.isNotEmpty){
        data['bio']= bio;
      }
       if(photoUrl!=""){
        data['photoUrl'] = photoUrl;
      }
      
      _firestore.collection("users").doc(id).get().then(
        (value){
          if(value.exists){
            
            return _firestore.collection("users").doc(id).update(
              data
            );
          }else {
            return "dont found";
          }
        }
      );
    }catch(e){
      print(e);
    }
    return "";
  } 
  Future<String> userLikePost({ String? id ,String? idpost,required String idUserPost})async {
   
    try{
      //tim user haved like post
       final a =  await _firestore.collection("posts").doc(idpost).get();
     Map<String,dynamic>? map = a.data();
     for (var element in List.from(map!['likes'])) {
       if(id==element){
        //delete elemet 
          _firestore.collection("posts").doc(idpost).get().then(
        (value){
          if(value.exists){
          
            return _firestore.collection("posts").doc(idpost).update(
              {
                "likes": FieldValue.arrayRemove([id])
              }
            );

          }else {
             
            return "dont found";
          }
        }
      );
          return "unlike";
       }
     }
     //like
     String? image = await getUserImage(FirebaseAuth.instance.currentUser!.uid);
     String? name = await getUserName(FirebaseAuth.instance.currentUser!.uid);
     String nofiD= const Uuid().v1();
            Map<String,dynamic> data = {
              "noId":nofiD,
              "uid_action":FirebaseAuth.instance.currentUser!.uid,
              "uid_recei":idUserPost,
              "uid_action_image": image,
              "uid_action_name": name ,
              "content":"like",
              "created_at":DateTime.now(),
              "postId":idpost
            };
            await _firestore.collection("notifications").doc(nofiD).set(data);
      _firestore.collection("posts").doc(idpost).get().then(
        (value){
          if(value.exists){
             
            return _firestore.collection("posts").doc(idpost).update(
              {
                "likes": FieldValue.arrayUnion([id])
              }
            );
          }else {
            return "dont found";
          }
        }
      );
    }catch(e){
      print(e);
    }
    return "";
  }


  Future<Map<String,dynamic>?> getPostByID(String id)async {
    final a = await _firestore.collection('posts')
              .doc(id).get();
    
    Map<String,dynamic>? map = a.data();
    return map;
  }
  
  Future<String?> getUserName(String id)async {
    final a = await _firestore.collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid).get();
    
    Map<String,dynamic>? map = a.data();
    return map!['username'];
  }
  Future<String?> getUserImage(String id)async {
    final a = await _firestore.collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid).get();
    
    Map<String,dynamic>? map = a.data();
    return map!['photoUrl'];
  }
  Future<String?> userSavePost({ String? id ,String? idpost})async {
  //update khi user lưu hoặc bỏ lưu
    try{
      //tim user haved like post
       final a =  await _firestore.collection("posts").doc(idpost).get();
     Map<String,dynamic>? map = a.data();
     for (var element in List.from(map!['saves'])) {
       if(id==element){
        //delete elemet 
          _firestore.collection("posts").doc(idpost).get().then(
        (value){
          if(value.exists){
            
            return _firestore.collection("posts").doc(idpost).update(
              {
                "saves": FieldValue.arrayRemove([id])
              }
            );
          }else {
            return "dont found";
          }
        }
      );
          return "unsave";
       }
     }
     //save
      _firestore.collection("posts").doc(idpost).get().then(
        (value){
          if(value.exists){
            
            return _firestore.collection("posts").doc(idpost).update(
              { // thêm userid vào mảng trong post
                "saves": FieldValue.arrayUnion([id])
              }
            );
          }else {
            return "dont found";
          }
        }
      );
    }catch(e){
      print(e);
    }
    return "";
  } 
  Future<dynamic> checUserLiked({ String? id ,String? idpost})async {
     //kiểm tra xem user đã xem
    try{
     final a =  await _firestore.collection("posts").doc(idpost).get();
     Map<String,dynamic>? map = a.data();
     for (var element in List.from(map!['likes'])) {
       if(id==element){
        return true;
       }
     }
    }catch(e){
      return e;
    }
    return false;
  }
  Future<dynamic> checUserSaved({ String? id ,String? idpost})async {
    //kiểm tra user đã savve chưa
    try{
     final a =  await _firestore.collection("posts").doc(idpost).get();
     Map<String,dynamic>? map = a.data();
     for (var element in List.from(map!['saves'])) {
       if(id==element){
        return true;
       }
     }
    }catch(e){
      return false;
    }
    return false;
  }
  Future<dynamic> addComment(comment cmt,String uidpost) async {
    // thêm comment
    try{
      await  _firestore.collection("comments").doc(cmt.commentId).set(cmt.toMap());
       String? image = await getUserImage(FirebaseAuth.instance.currentUser!.uid);
     String? name = await getUserName(FirebaseAuth.instance.currentUser!.uid);
     String nofiD= const Uuid().v1();
            Map<String,dynamic> data = {
              "noId":nofiD,
              "uid_action":FirebaseAuth.instance.currentUser!.uid,
              "uid_recei":uidpost,
              "uid_action_image": image,
              "uid_action_name": name ,
              "content":"comment",
              "created_at":DateTime.now().millisecondsSinceEpoch.toString(),
              "postId":cmt.postId
            };
            await _firestore.collection("notifications").doc(nofiD).set(data);
    }catch(e){
      return e;
    }
    return false;
  }
  Future<dynamic> countComment(String idpost) async {
    //đếm số lượng commment
    try{
     QuerySnapshot result =  await  _firestore.collection("comments").where("postId",isEqualTo: idpost).get();
     return result;
    }catch(e){
      return 0;
    }
   
  }
  Future<dynamic> addNotificationn(notification nofi) async {
    // thêm comment
    try{
      
      await  _firestore.collection("notifications").doc(nofi.noId).set(nofi.toMap());
      
    }catch(e){
      return e;
    }
    return false;
  }
  Future<int> checCountUserLiked({ String? idpost})async {
     //kiểm tra xem user đã xem
    try{
     final a =  await _firestore.collection("posts").doc(idpost).get();
    Map<String,dynamic>? map = a.data();
     return map!['likes'].length;
    }catch(e){
      return 0;
    }
     
  }
  Future<String> deletePost(String postId) async {
  String res = "Có lỗi xảy ra";
  try {
    await _firestore.collection('posts').doc(postId).delete();
    res = "Xóa thành công";
  } catch (err) {
    res = err.toString();
  }
  return res;
}
 Future<dynamic> updatePost({  String? idpost,String? description})async {
     //kiểm tra xem user đã xem
    try{
     final a =  await _firestore.collection("posts").doc(idpost).update(
      {
        "description":description
      }
     );
     return true;
    }catch(e){
      return false;
 
    }
 
  }
}


  


FirestoreMethods fireMethod = new FirestoreMethods();