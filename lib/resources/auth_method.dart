import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lvtn_mangxahoi/models/user.dart' as model;
import 'package:lvtn_mangxahoi/resources/storage_method.dart';
import 'package:lvtn_mangxahoi/utils/key_shared.dart';
import 'package:lvtn_mangxahoi/utils/sharedpreference.dart';

class AuthMethod {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
        return model.User.fromSnap(snap);
  }
bool isEmailValid(String email) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
    return emailRegex.hasMatch(email);
  }

  bool isPasswordValid(String password) {
    // Kiểm tra độ dài password và định dạng bằng biểu thức chính quy
    final passwordRegex = RegExp(r'^.{6,}$');
    return passwordRegex.hasMatch(password);
  }
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty && 
          password.isNotEmpty &&                                  
          username.isNotEmpty && 
          bio.isNotEmpty && 
          file != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print(cred.user);
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePic', file, false);

        model.User user = model.User(
           username: username,
            uid: cred.user!.uid,
            photoUrl: photoUrl,
            email: email,
            bio: bio,
            createdAt: '',
            isOnline: false,
            lastActive: '',
            pushToken: '',
            followers: [],
            following: [],
            titleUser: [],);

        await _firestore.collection("users").doc(cred.user!.uid).set(
              user.toJson(),
            );
        res = "success";
          String a = await  _auth.currentUser!.uid;
        sharedPreferences.setString(keyShared.CURRENTUSER,a);
      } else {
        if (email.isEmpty || !isEmailValid(email)) {
          res = 'Email không đúng định dạng!';
        } else if (password.isEmpty || !isPasswordValid(password)) {
          res = 'Password không đúng định dạng!';
        } else {
          res = 'Vui lòng điền đầy đủ thông tin';
        }}
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'Email không đúng định dạng!';
      } else if (err.code == 'email-already-in-use') {
        // Email đã được sử dụng, trả về thông báo lỗi
        res = 'Email đã được sử dụng';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
        String a = await  _auth.currentUser!.uid;
        sharedPreferences.setString(keyShared.CURRENTUSER,a);

      } else {
        res = "Hãy điền vào thông tin đăng nhập";
       
      }
    }on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found' || error.code == 'wrong-password') {
        res = 'Email hoặc mật khẩu không hợp lệ';
      } else {
        res = error.message!;
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }
   
  Future<void> signOut() async {
     
    await _auth.signOut();
  }
}

AuthMethod aut =  AuthMethod();