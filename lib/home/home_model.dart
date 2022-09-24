import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';

class HomeModel extends ChangeNotifier {
  List<Post> posts = [];
  bool isLoading = false;
  DocumentSnapshot? _fetchedLastSnapshot; // 現在取得している最後のドキュメントを保持
  bool isFetchLastItem = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  /// ポストを10件取得(初回)
  Future firstFetchPosts() async {
    // ポストを10件取得
    final QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    // 次のページ読み込み時の開始地点を設定
    _fetchedLastSnapshot = snapshots.docs.last;

    snapshots.docs.map((document) {
      final post = Post(document);
      posts.add(post);
      return post;
    }).toList();
    notifyListeners();
  }

  /// ポストを追加で10件取得
  Future fetchPosts() async {
    // 最後に取得したドキュメントを起点に、ポストを10件取得
    final QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(_fetchedLastSnapshot!)
        .limit(10)
        .get();

    // postsコレクションのドキュメントを全て取得したかチェック
    isFetchLastItem = snapshots.docs.isEmpty;
    if (isFetchLastItem) {
      notifyListeners();
      return;
    }

    // 次のページ読み込み時の開始地点を設定
    _fetchedLastSnapshot = snapshots.docs.last;

    snapshots.docs.map((document) {
      final post = Post(document);
      posts.add(post);
      return post;
    }).toList();
    notifyListeners();
  }

  /// 取得したポストの情報とフラグをリセット
  void reset() {
    posts = [];
    _fetchedLastSnapshot = null;
    isFetchLastItem = false;
  }

// TODO: ログインしてるかチェック
}
