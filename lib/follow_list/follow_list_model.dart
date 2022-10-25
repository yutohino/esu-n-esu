import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/domain/follow_users.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';

class FollowListModel extends ChangeNotifier {
  AppUser loginUser;

  FollowListModel(this.loginUser);

  List<Post> posts = [];
  bool isLoading = false;
  int retrievedFollowUserListIndex = 0; // 現在取得している最後のユーザーのインデックスを保持
  bool isFetchLastItem = false;

  FollowUsers? followUsers; // ログイン中のユーザーのフォローユーザー情報を取得
  List<String> followUsersIdList = []; // FollowUsersのユーザーIDリスト(降順)
  List<AppUser> followUserList = []; // FollowUsersのユーザー情報

  void startLoading() {
    isLoading = true;
  }

  void endLoading() {
    isLoading = false;
  }

  Future initProc() async {
    _reset();
    await _fetchFollowUsers();
    followUsersIdList = [...followUsers!.followUsersIdList.reversed];
    await _firstFetchFollowUserList();
  }

  /// followコレクションからフォロー情報を取得し、FollowUsersクラスを作成する
  Future _fetchFollowUsers() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('follow')
        .doc(loginUser.id)
        .get();
    if (!snapshot.exists) {
      // followにドキュメントが無い場合は作成する
      await FirebaseFirestore.instance
          .collection('follow')
          .doc(loginUser.id)
          .set({});
      snapshot = await FirebaseFirestore.instance
          .collection('follow')
          .doc(loginUser.id)
          .get();
    }
    followUsers = FollowUsers(snapshot);
  }

  /// uidを基にusersコレクションからフォローユーザーを15件取得(初回)
  Future _firstFetchFollowUserList() async {
    // フォローユーザーを15件取得
    for (int index = 0; index < 15; index++) {
      if (index == followUsersIdList.length) {
        break;
      }
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(followUsersIdList[index])
          .get();
      followUserList.add(AppUser(snapshot));
      retrievedFollowUserListIndex = index;
    }

    // 取得したフォローユーザーが15件以下
    isFetchLastItem = followUsersIdList.length <= 15;

    notifyListeners();
  }

  /// フォローユーザーを追加で15件取得
  Future fetchFollowUserList() async {
    // ループで前回の最後のIndexを起点に15件取得する(上限に達したらループ中断)
    for (int index = retrievedFollowUserListIndex + 1;
        index < index + 15;
        index++) {
      if (index == followUsersIdList.length) {
        break;
      }
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(followUsersIdList[index])
          .get();
      followUserList.add(AppUser(snapshot));
      retrievedFollowUserListIndex = index;
    }

    // 残り件数がまだあるかチェック
    final lastIndex = followUsersIdList.length - 1;
    final remainingItems = lastIndex - retrievedFollowUserListIndex;
    isFetchLastItem = remainingItems <= 0;

    notifyListeners();
  }

  /// ユーザーページのユーザーをフォローしているかチェック
  bool isFollowUser(String userId) {
    if (followUsers != null) {
      return followUsers!.followUsersIdList.contains(userId);
    }
    return false;
  }

  /// ユーザーをフォロー登録/解除する
  Future followUser(String userId) async {
    if (followUsers!.followUsersIdList.contains(userId)) {
      // フォロー解除
      followUsers!.followUsersIdList.remove(userId);
    } else {
      // フォロー登録
      followUsers!.followUsersIdList.add(userId);
    }
    await FirebaseFirestore.instance
        .collection('follow')
        .doc(loginUser.id)
        .update({
      'followUsersIdList': followUsers!.followUsersIdList,
    });
    notifyListeners();
  }

  /// 遷移先のユーザーページのフォローステータスを反映する
  void setFollowUserStatus(String userId, bool isFollow) {
    if (isFollow) {
      // フォロー登録
      followUsers!.followUsersIdList.add(userId);
    } else {
      // フォロー解除
      followUsers!.followUsersIdList.remove(userId);
    }
    notifyListeners();
  }

  /// 取得しフォローユーザーの情報とフラグをリセット
  void _reset() {
    posts = [];
    retrievedFollowUserListIndex = 0;
    isFetchLastItem = false;
    followUsers = null;
    followUserList = [];
  }
}
