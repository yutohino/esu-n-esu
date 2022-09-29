import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? email;
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

  void setPassword(String password) {
    this.password = password;
    notifyListeners();
  }

  Future login() async {
    email = emailController.text;
    password = passwordController.text;

    if (email != null && password != null) {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);
    }
  }
}
