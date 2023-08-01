import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  late String uid;
  late String email;
  late String photoUrl;
  late String username;
  late String bio;
  late String createdAt;
  late bool isOnline;
  late String lastActive;
  late List followers;
  late List following;
  late String pushToken;
  late List titleUser;

  User({
    required this.uid,
    required this.username,
    required this.photoUrl,
    required this.email,
    required this.bio,
    required this.createdAt,
    required this.isOnline,
    required this.lastActive,
    required this.pushToken,
    required this.followers,
    required this.following,
    required this.titleUser,
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    var user = User(
      uid: snapshot["uid"],
      username: snapshot["username"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      bio: snapshot["bio"],
      createdAt: snapshot["createdAt"],
      isOnline: snapshot["is_online"],
      lastActive: snapshot["last_active"],
      pushToken: snapshot["pushToken"],
      followers: snapshot["followers"],
      following: snapshot["following"],
      titleUser: snapshot["titleUser"],
    );
    return user;
  }

  User.fromJson(Map<String, dynamic> json) {
    email = json['email'] ?? '';
    uid = json['uid'] ?? '';
    photoUrl = json['photoUrl'] ?? '';
    username = json['username'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? false;
    lastActive = json['last_active'] ?? '';
    pushToken = json['push_Token'] ?? '';
    bio = json['bio'] ?? '';
    followers = json['followers'] ?? [];
    following = json['following'] ?? [];
    titleUser = json['titleUser'] ?? [];
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "createdAt": createdAt,
        "isOnline": isOnline,
        "lastActive": lastActive,
        "pushToken": pushToken,
        "followers": followers,
        "following": following,
        "titleUser": titleUser,
      };

 

}