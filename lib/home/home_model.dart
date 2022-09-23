import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';

class HomeModel extends ChangeNotifier {
  List<Post> posts = [];

  late ScrollController _scrollController;
  bool _isLoading = false;

  /// ポストを全件取得
  Future fetchPosts() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('posts').get();
    final List<Post> posts =
        snapshot.docs.map((document) => Post(document)).toList();
    this.posts = posts;
    notifyListeners();
  }

  // TODO: ログインしてるかチェック
}
