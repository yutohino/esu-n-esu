import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterModel extends ChangeNotifier {
  final titleController = TextEditingController();
  final usernameController = TextEditingController();
  final authorController = TextEditingController();

  String? email;
  String? username;
  String? password;

  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void setEmail(String email) {
    this.email = email;
    notifyListeners();
  }

  void setUsername(String username) {
    this.username = username;
    notifyListeners();
  }

  void setPassword(String password) {
    this.password = password;
    notifyListeners();
  }

  Future signUp() async {
    email = titleController.text;
    username = usernameController.text;
    password = authorController.text;

    if (email != null && username != null && password != null) {
      // Firebase Authでユーザー作成
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!, password: password!);
      final user = userCredential.user;

      if (user != null) {
        final uid = user.uid;

        // Firestoreに追加
        final docUsers =
            FirebaseFirestore.instance.collection('users').doc(uid);
        await docUsers.set({
          'username': username,
          'email': email,
          'userImageUrl': '',
          'userDetail': '',
        });
        final docFollows =
            FirebaseFirestore.instance.collection('follow').doc(uid);
        await docFollows.set({
          'followUsersIdList': [],
        });
        final docBookmarks =
            FirebaseFirestore.instance.collection('bookmarks').doc(uid);
        await docBookmarks.set({
          'bookmarksDocIdList': [],
        });
      }
    }
  }
}
