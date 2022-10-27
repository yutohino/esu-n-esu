// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, use_build_context_synchronously, must_be_immutable

import 'package:esu_n_esu/colors/Palette.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/follow_list/follow_list_model.dart';
import 'package:esu_n_esu/my/user_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowListPage extends StatelessWidget {
  FollowListPage(this.loginUser);

  AppUser loginUser;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FollowListModel>(
      create: (_) => FollowListModel(loginUser)..initProc(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.mainColor,
          title: Text('フォローリスト'),
        ),
        body: Center(
          child: Consumer<FollowListModel>(builder: (context, model, child) {
            final followUserList = model.followUserList;
            if (followUserList.isEmpty) {
              if (!model.isFetchLastItem) {
                // ポストを取得するまでサークルを表示
                return CircularProgressIndicator(
                  color: Palette.mainColor,
                );
              }
            }

            // ポストを10件ずつリスト表示する
            final controller = ScrollController();
            controller.addListener(() async {
              if (model.isFetchLastItem) {
                return;
              }
              if (controller.position.pixels >=
                      controller.position.maxScrollExtent * 0.9 &&
                  !model.isLoading) {
                model.startLoading();
                await model.fetchFollowUserList();
                model.endLoading();
              }
            });

            return _buildListView(controller, model, followUserList);
          }),
        ),
      ),
    );
  }

  /// フォロー一覧のListViewを作成
  Widget _buildListView(ScrollController controller, FollowListModel model,
      List<AppUser> followUserList) {
    return RefreshIndicator(
      // フォローユーザーの情報を初期化 & 最初の10件を取得
      onRefresh: () async {
        await model.initProc();
      },
      child: ListView.separated(
        controller: controller,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: followUserList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index < followUserList.length) {
            final followUser = model.followUserList[index];
            return InkWell(
              onTap: () async {
                bool isFollow = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPage(followUser),
                    ));
                // 遷移先のユーザーページのフォローステータスを反映
                model.setFollowUserStatus(followUser.id, isFollow);
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    _showUserImage(followUser.userImageUrl, 40),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      followUser.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    _showFollowButton(context, model, index),
                    SizedBox(
                      width: 8,
                    )
                  ],
                ),
              ),
            );
          } else {
            if (model.isFetchLastItem) {
              // ポストを最後まで読み込んだらインジケータを表示しない
              return Container();
            } else {
              // 最下部にポストの追加読み込みインジケーターを表示
              return SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Palette.mainColor,
                  ),
                ),
              );
            }
          }
        },
        separatorBuilder: (BuildContext context, int index) => Container(
          width: double.infinity,
          height: 0.25,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// ユーザー画像を表示
  Widget _showUserImage(String userImageUrl, double size) {
    if (userImageUrl.isEmpty) {
      return Icon(
        Icons.account_circle,
        size: size,
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: NetworkImage(userImageUrl),
            onError: (error, stackTrace) {
              print(stackTrace);
            },
            fit: BoxFit.cover),
      ),
    );
  }

  /// フォローボタンの表示
  Widget _showFollowButton(
      BuildContext context, FollowListModel model, int index) {
    final userId = model.followUserList[index].id;
    return TextButton(
      onPressed: () async {
        model.isFollowUser(userId)
            ? await model.unfollowUser(userId)
            : await model.followUser(userId);
      },
      style: model.isFollowUser(userId)
          ? TextButton.styleFrom(
              backgroundColor: Palette.mainColor,
              foregroundColor: Colors.white,
              shape: StadiumBorder(),
              padding: EdgeInsets.all(10),
            )
          : TextButton.styleFrom(
              foregroundColor: Palette.mainColor,
              shape: StadiumBorder(),
              side: BorderSide(color: Palette.mainColor),
              padding: EdgeInsets.all(10),
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          model.isFollowUser(userId) ? Icon(Icons.check) : Icon(Icons.add),
          Text('フォロー'),
        ],
      ),
    );
  }
}
