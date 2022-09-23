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

  /// ポストを10件ずつ取得
  Future fetchPosts() async {
    // TODO: ↑ひとまず実装した。10件目を削除した際にどうなるか確認する(※ポスト新規追加機能を実装後に)
    // ポストを10件取得
    QuerySnapshot snapshots;
    if (_fetchedLastSnapshot == null) {
      snapshots = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
    } else {
      snapshots = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_fetchedLastSnapshot!)
          .limit(10)
          .get();
    }

    isFetchLastItem = snapshots.docs.isEmpty;
    if (isFetchLastItem) {
      notifyListeners();
      return;
    }

    // 最後に取得したドキュメントを次ページ読み込み時の開始地点とする
    _fetchedLastSnapshot = snapshots.docs.last;

    snapshots.docs.map((document) {
      final post = Post(document);
      posts.add(post);
      return post;
    }).toList();
    notifyListeners();
  }

// TODO: ログインしてるかチェック
}
