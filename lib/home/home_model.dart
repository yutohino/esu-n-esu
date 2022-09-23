import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';

class HomeModel extends ChangeNotifier {
  List<Post> posts = [];
  bool isLoading = false;
  DocumentSnapshot? fetchedLastDoc; // 現在取得している最後のドキュメントを保持

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  /// ポストを全件取得
  Future fetchPosts() async {
    // TODO: 投稿順に並べて、startAfterDocumentとendAtDocumentとlimitを使って10件ずつ取得する
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('posts').get();
    final List<Post> posts =
        snapshot.docs.map((document) => Post(document)).toList();
    this.posts = posts;
    notifyListeners();
  }

// TODO: ログインしてるかチェック
}
