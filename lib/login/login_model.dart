import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {
  List<Post> posts = [];
  bool isLoading = false;
  DocumentSnapshot? _fetchedLastSnapshot; // 現在取得している最後のドキュメントを保持
  bool isFetchLastItem = false;

  void startLoading() {
    isLoading = true;
  }

  void endLoading() {
    isLoading = false;
  }

// TODO: ログインしてるかチェック
}
