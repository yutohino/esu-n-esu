import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/domain/bookmarks.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContentModel extends ChangeNotifier {
  Post post;
  AppUser user;

  ContentModel(this.post, this.user) {
    titleController.text = post.title;
    contentController.text = post.content;
    imageUrls = post.imageUrls;
  }

  bool isUploading = false;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String? title;
  String? content;
  List<String> imageUrls = [];

  Map<int, File> imageFiles = {};

  bool isUpdatedPost = false;
  bool isDeletedPost = false;

  AppUser? loginUser;

  Bookmarks? bookmarks;

  bool isBookmark = false;

  Future initProc() async {
    await reload();
  }

  /// ログイン中のユーザー情報を取得
  Future _getLoginUserAccount() async {
    User? loginUser = FirebaseAuth.instance.currentUser;
    if (loginUser == null) {
      return;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(loginUser.uid)
        .get();
    this.loginUser = AppUser(snapshot);
  }

  /// ポストの投稿者のユーザー情報を取得
  Future _getPostedUserAccount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(user.id).get();
    user = AppUser(snapshot);
  }

  /// ログインしているユーザーのブックマーク情報を取得する
  Future _getBookmarkInfo() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(loginUser!.id)
        .get();
    if (!snapshot.exists) {
      // bookmarksにドキュメントが無い場合は作成する
      await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(loginUser!.id)
          .set({});
      snapshot = await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(loginUser!.id)
          .get();
    }
    bookmarks = Bookmarks(snapshot);
  }

  /// 表示しているポストをブックマークしているかチェック
  void _getBookmarkStatus() {
    if (bookmarks!.bookmarksDocIdList.contains(post.id)) {
      isBookmark = true;
    } else {
      isBookmark = false;
    }
  }

  /// ブックマーク登録/解除する
  Future<String?> bookmarkPost() async {
    String? resultMessage;
    if (isBookmark) {
      // ブックマーク解除
      bookmarks!.bookmarksDocIdList.remove(post.id);
      isBookmark = false;
      resultMessage = 'ブックマーク解除しました';
    } else {
      // ブックマーク登録
      bookmarks!.bookmarksDocIdList.add(post.id);
      bookmarks!.bookmarksDocIdList =
          bookmarks!.bookmarksDocIdList.toSet().toList(); // 重複する値を削除
      isBookmark = true;
      resultMessage = 'ブックマーク登録しました';
    }
    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(loginUser!.id)
        .update({
      'bookmarksDocIdList': bookmarks!.bookmarksDocIdList,
    });
    notifyListeners();
    return resultMessage;
  }

  Future reload() async {
    // ログイン中のユーザー情報を取得
    await _getLoginUserAccount();

    await _reloadPost();

    // ポストの投稿者のユーザー情報を取得
    await _getPostedUserAccount();

    notifyListeners();
  }

  Future _reloadPost() async {
    // 記事が削除されていないかチェック
    final snapshot =
        await FirebaseFirestore.instance.collection('posts').doc(post.id).get();
    if (!snapshot.exists) {
      flagDeletedPost();
      notifyListeners();
      return;
    }
    post = Post(snapshot);

    // ブックマークの状態を取得
    if (loginUser != null) {
      await _getBookmarkInfo();
      _getBookmarkStatus();
    }
  }

  Future updatedPost() async {
    await reload();
    isUpdatedPost = true;
  }

  void flagDeletedPost() {
    isDeletedPost = true;
  }
}
