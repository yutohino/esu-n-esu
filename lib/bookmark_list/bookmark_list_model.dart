import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/domain/bookmarks.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';

class BookmarkListModel extends ChangeNotifier {
  AppUser loginUser;

  BookmarkListModel(this.loginUser);

  bool isLoading = false;
  int retrievedBookmarksDocIdListIndex = 0; // 現在取得している最後のユーザーのインデックスを保持
  bool isFetchLastItem = false;

  Bookmarks? bookmarks; // ログイン中のユーザーのブックマーク情報を取得
  List<String> bookmarksDocIdList = []; // BookmarksのユーザーIDリスト(降順)
  List<Post> posts = [];

  List<AppUser> postedUsers = [];

  void startLoading() {
    isLoading = true;
  }

  void endLoading() {
    isLoading = false;
  }

  Future initProc() async {
    _reset();
    await _fetchBookmarks();
    bookmarksDocIdList = [...bookmarks!.bookmarksDocIdList.reversed];
    await _firstFetchBookmarkList();
  }

  /// bookmarksコレクションからブックマーク情報を取得し、Bookmarksクラスを作成する
  Future _fetchBookmarks() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(loginUser.id)
        .get();
    if (!snapshot.exists) {
      // bookmarksにドキュメントが無い場合は作成する
      await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(loginUser.id)
          .set({});
      snapshot = await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(loginUser.id)
          .get();
    }
    bookmarks = Bookmarks(snapshot);
  }

  /// uidを基にusersコレクションからブックマークを10件取得(初回)
  Future _firstFetchBookmarkList() async {
    // ブックマークを10件取得
    for (int index = 0; index < 10; index++) {
      if (index == bookmarksDocIdList.length) {
        break;
      }
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(bookmarksDocIdList[index])
          .get();
      // ポストが存在しない場合はブックマークリストから削除する & ブックマーク解除する
      if (!snapshot.exists) {
        await _removeBookmark(bookmarksDocIdList[index]);
        bookmarksDocIdList.removeAt(index);
        index--;
        continue;
      }
      final post = Post(snapshot);
      posts.add(post);
      await _addUserInfo(post.uid);
      retrievedBookmarksDocIdListIndex = index;
    }

    // 取得したブックマークが10件以下
    isFetchLastItem = bookmarksDocIdList.length <= 10;

    notifyListeners();
  }

  /// ブックマークを追加で10件取得
  Future fetchBookmarkList() async {
    // ループで前回の最後のIndexを起点に10件取得する(上限に達したらループ中断)
    for (int index = retrievedBookmarksDocIdListIndex + 1;
        index < index + 10;
        index++) {
      if (index == bookmarksDocIdList.length) {
        break;
      }
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(bookmarksDocIdList[index])
          .get();
      // ポストが存在しない場合はブックマークリストから削除する & ブックマーク解除する
      if (!snapshot.exists) {
        await _removeBookmark(bookmarksDocIdList[index]);
        bookmarksDocIdList.removeAt(index);
        index--;
        continue;
      }
      final post = Post(snapshot);
      posts.add(post);
      await _addUserInfo(post.uid);
      retrievedBookmarksDocIdListIndex = index;
    }

    // 残り件数がまだあるかチェック
    final lastIndex = bookmarksDocIdList.length - 1;
    final remainingItems = lastIndex - retrievedBookmarksDocIdListIndex;
    isFetchLastItem = remainingItems <= 0;

    notifyListeners();
  }

  /// ブックマークを解除する
  Future _removeBookmark(String postId) async {
    bookmarks!.bookmarksDocIdList.remove(postId);
    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(loginUser.id)
        .update({
      'bookmarksDocIdList': bookmarks!.bookmarksDocIdList,
    });
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

  /// 取得したブックマークの情報とフラグをリセット
  void _reset() {
    posts = [];
    retrievedBookmarksDocIdListIndex = 0;
    isFetchLastItem = false;
    bookmarks = null;
    posts = [];
    postedUsers = [];
  }
}
