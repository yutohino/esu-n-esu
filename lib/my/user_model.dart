import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/domain/follow_user.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  AppUser user;

  UserModel(this.user);

  List<Post> posts = [];
  bool isLoading = false;
  DocumentSnapshot? _fetchedLastSnapshot; // 現在取得している最後のドキュメントを保持
  bool isFetchLastItem = false;

  AppUser? loginUser;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future initProc() async {
    // ログイン中のユーザーアカウント情報を取得
    await _getLoginUserAccount();
    // ポストを初回10件取得
    await firstFetchPosts();
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

  /// ユーザーページの情報が自分のアカウントかどうかチェック
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

  bool isMyAccount() {
    return user.uid == loginUser!.uid;
  }

  Future _getStatusFollow() async {
    // TODO：フォローリストを取得
    final snapshot = await FirebaseFirestore.instance
        .collection('follow')
        .where('uid', isEqualTo: user.uid)
        .get();
    FollowUser followUser = FollowUser(snapshot.docs[0]);
    // TODO: フォローリストからuidの一致するデータを取得する(ループで)
    followUser.followUserList.map((followUser) {
      // followUser
    });
    // TODO: 一致するデータがあれば true、なければfalse
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
