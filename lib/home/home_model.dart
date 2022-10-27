import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeModel extends ChangeNotifier {
  List<Post> posts = [];
  bool isLoading = false;
  DocumentSnapshot? _fetchedLastSnapshot; // 現在取得している最後のドキュメントを保持
  bool isFetchLastItem = false;

  List<AppUser> postedUsers = [];
  AppUser? loginUser;

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

    if (FirebaseAuth.instance.currentUser != null) {
      await _checkLoginUserInfo(FirebaseAuth.instance.currentUser!.uid);
    }

    // ポストを10件取得
    final QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('editedAt', descending: true)
        .limit(10)
        .get();

    // 次のページ読み込み時の開始地点を設定
    if (snapshots.docs.isNotEmpty) {
      _fetchedLastSnapshot = snapshots.docs.last;
    }

    // 取得したポスト数が10件未満なら、postsコレクションのドキュメント
    isFetchLastItem = snapshots.docs.length < 10;

    await Future.wait(snapshots.docs.map((document) async {
      final post = Post(document);
      posts.add(post);
      await _addUserInfo(post.uid);
    }).toList());
    notifyListeners();
  }

  /// ポストを追加で10件取得
  Future fetchPosts() async {
    // 最後に取得したドキュメントを起点に、ポストを10件取得
    final QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('editedAt', descending: true)
        .startAfterDocument(_fetchedLastSnapshot!)
        .limit(10)
        .get();

    // postsコレクションのドキュメントを全て取得したかチェック
    isFetchLastItem = snapshots.docs.isEmpty;
    if (isFetchLastItem) {
      return;
    }

    // 次のページ読み込み時の開始地点を設定
    _fetchedLastSnapshot = snapshots.docs.last;

    await Future.wait(snapshots.docs.map((document) async {
      final post = Post(document);
      posts.add(post);
      await _addUserInfo(post.uid);
    }).toList());
  }

  /// 記事のユーザー情報を取得
  AppUser? getPostedUserInfo(String uid) {
    for (AppUser user in postedUsers) {
      if (uid == user.id) {
        return user;
      }
    }
    return null;
  }

  /// uidを基にユーザー情報を取得してpostedUsersに追加する
  Future _addUserInfo(String uid) async {
    // postedUsersにユーザー情報がある場合
    for (AppUser user in postedUsers) {
      if (uid == user.id) {
        return;
      }
    }

    // postedUsersに無い場合はusersコレクションから取得する
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final user = AppUser(snapshot);
    postedUsers.add(user);
  }

  /// ログインしているユーザー情報の確認
  Future _checkLoginUserInfo(String uid) async {
    if (loginUser != null) {
      return;
    }
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final user = AppUser(snapshot);
    loginUser = user;
  }

  /// 取得したポストの情報とフラグをリセット
  void _reset() {
    loginUser = null;
    posts = [];
    _fetchedLastSnapshot = null;
    isFetchLastItem = false;
    postedUsers = [];
  }
}
