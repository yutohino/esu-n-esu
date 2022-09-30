import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/AppUser.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyModel extends ChangeNotifier {
  List<Post> posts = [];
  bool isLoading = false;
  DocumentSnapshot? _fetchedLastSnapshot; // 現在取得している最後のドキュメントを保持
  bool isFetchLastItem = false;

  List<AppUser> users = [];

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
        .orderBy('editedAt', descending: true)
        .limit(10)
        .get();

    // 次のページ読み込み時の開始地点を設定
    _fetchedLastSnapshot = snapshots.docs.last;

    // 取得したポスト数が10件未満なら、postsコレクションのドキュメント
    isFetchLastItem = snapshots.docs.length < 10;

    posts = []; // 表示中のポストを初期化
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

  /// 記事のユーザー情報を取得
  AppUser? fetchPostedUserInfo(String uid) {
    for (AppUser user in users) {
      return user;
    }
    return null;
  }

  /// uidを基にユーザー情報を取得してusersに追加する
  Future _addUserInfo(String uid) async {
    // usersにユーザー情報がある場合
    for (AppUser user in users) {
      if (uid == user.uid) {
        return;
      }
    }

    // usersに無い場合はusersコレクションから取得する
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final user = AppUser(snapshot);
    users.add(user);
  }

  /// 取得したポストの情報とフラグをリセット
  void reset() {
    posts = [];
    _fetchedLastSnapshot = null;
    isFetchLastItem = false;
    users = [];
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut();
    sleep(const Duration(seconds: 2));
  }
}
