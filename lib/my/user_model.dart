import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/AppUser.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  UserModel(this.user);

  AppUser user;

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
    _reset();

    // ポストを10件取得
    final QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: user.uid)
        .orderBy('editedAt', descending: true)
        .limit(10)
        .get();

    if (snapshots.docs.isNotEmpty) {
      _fetchedLastSnapshot = snapshots.docs.last;
    }

    // 取得したポスト数が10件未満なら、postsコレクションのドキュメント
    isFetchLastItem = snapshots.docs.length < 10;

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
        .where('uid', isEqualTo: user.uid)
        .orderBy('editedAt', descending: true)
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
    });
    notifyListeners();
  }

  Future reloadUserProfile() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(user.id).get();
    user = AppUser(snapshot);
    notifyListeners();
  }

  /// 取得したポストの情報とフラグをリセット
  void _reset() {
    posts = [];
    _fetchedLastSnapshot = null;
    isFetchLastItem = false;
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
