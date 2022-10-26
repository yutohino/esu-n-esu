// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, use_build_context_synchronously, must_be_immutable

import 'package:esu_n_esu/bookmark_list/bookmark_list_page.dart';
import 'package:esu_n_esu/colors/Palette.dart';
import 'package:esu_n_esu/content/content_page.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:esu_n_esu/edit_post/edit_post_page.dart';
import 'package:esu_n_esu/edit_profile/edit_profile_page.dart';
import 'package:esu_n_esu/follow_list/follow_list_page.dart';
import 'package:esu_n_esu/my/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum Menu { followList, bookMarkList, logout }

class UserPage extends StatelessWidget {
  UserPage(this.user);

  AppUser user;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel(user)..initProc(),
      child: Consumer<UserModel>(builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, model.isFollowUser);
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Palette.mainColor,
              title: setTitle(model),
              actions: [
                if (model.loginUser != null && model.isMyAccount()) ...{
                  PopupMenuButton(
                    onSelected: (Menu selectedItem) async {
                      if (selectedItem == Menu.followList) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FollowListPage(model.loginUser!),
                            ));
                      } else if (selectedItem == Menu.bookMarkList) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookmarkListPage(model.loginUser!),
                            ));
                      } else if (selectedItem == Menu.logout) {
                        model.startLoading();
                        await model.logout();
                        model.endLoading();
                        Navigator.pop(context, 'ログアウトしました');
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<Menu>>[
                        PopupMenuItem<Menu>(
                          value: Menu.followList,
                          child: Text('フォローリスト'),
                        ),
                        PopupMenuItem<Menu>(
                          value: Menu.bookMarkList,
                          child: Text('ブックマークリスト'),
                        ),
                        PopupMenuItem<Menu>(
                          value: Menu.logout,
                          child: Text('ログアウト'),
                        ),
                      ];
                    },
                    icon: Icon(Icons.more_vert),
                  ),
                },
              ],
            ),
            body: Stack(
              children: [
                Center(
                  child: Consumer<UserModel>(builder: (context, model, child) {
                    final posts = model.posts;
                    if (posts.isEmpty) {
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
                      if (controller.position.maxScrollExtent ==
                              controller.offset &&
                          !model.isLoading) {
                        model.startLoading();
                        model.fetchPosts();
                        model.endLoading();
                      }
                    });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _showUserImage(model.user.userImageUrl, 80),
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: Text(
                                            model.user.username,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (model.user.userDetail.isNotEmpty) ...{
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    model.user.userDetail,
                                    maxLines: 16,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.2,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              },
                              if (model.loginUser != null) ...{
                                if (model.isMyAccount()) ...{
                                  // ログイン中のアカウントの場合
                                  _showEditMyAccountButton(context, model),
                                } else ...{
                                  // 他ユーザーのアカウントの場合
                                  _showFollowButton(context, model),
                                }
                              },
                            ],
                          ),
                        ),
                        Container(
                          height: 0.25,
                          width: double.infinity,
                          color: Colors.grey,
                        ),
                        Flexible(
                          flex: 1,
                          child: _buildListView(controller, model, posts),
                        )
                      ],
                    );
                  }),
                ),
                Consumer<UserModel>(builder: (context, model, child) {
                  if (model.isLoading) {
                    return Container(
                      color: Colors.black54,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Palette.mainColor,
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
              ],
            ),
            floatingActionButton:
                Consumer<UserModel>(builder: (context, model, child) {
              if (model.loginUser != null && model.isMyAccount()) {
                return FloatingActionButton(
                  backgroundColor: Palette.mainColor,
                  onPressed: () async {
                    String? status = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPostPage(null),
                          fullscreenDialog: true,
                        ));

                    if (status == '新規投稿') {
                      await model.firstFetchPosts();
                    }
                  },
                  tooltip: '新規記事投稿',
                  child: Icon(Icons.add),
                );
              } else {
                return SizedBox();
              }
            }),
          ),
        );
      }),
    );
  }

  /// ユーザーのポスト一覧のListViewを作成
  Widget _buildListView(
      ScrollController controller, UserModel model, List<Post> posts) {
    return RefreshIndicator(
      // ポストの情報を初期化 & 最初の10件を取得
      onRefresh: () async {
        await model.firstFetchPosts();
      },
      child: ListView.separated(
        controller: controller,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: posts.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index < posts.length) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                bool isUpdatedOrDeletedPost = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContentPage(posts[index], model.user),
                    ));
                if (isUpdatedOrDeletedPost) {
                  await model.firstFetchPosts();
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      posts[index].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      posts[index].content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.2,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        for (String imageUrl in posts[index].imageUrls) ...{
                          Container(
                            color: Colors.black12,
                            child: Image.network(
                              imageUrl,
                              height: 80,
                              width: 80,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 80,
                                );
                              },
                            ),
                          ),
                          if (imageUrl != posts[index].imageUrls.last)
                            SizedBox(width: 8),
                        },
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _showUserImage(model.user.userImageUrl, 28),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            model.user.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '投稿日 [${DateFormat('yyyy/MM/dd').format(posts[index].createdAt!)}]',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        if (posts[index].isEdited)
                          Text(
                            '編集日 [${DateFormat('yyyy/MM/dd').format(posts[index].editedAt!)}]',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
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

  Widget setTitle(UserModel model) {
    if (model.loginUser != null && model.isMyAccount()) {
      return Text('マイページ');
    } else {
      return Text('ユーザーページ');
    }
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
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// プロフィール編集ボタンの表示
  Widget _showEditMyAccountButton(BuildContext context, UserModel model) {
    return TextButton(
      onPressed: () async {
        String? updatedMessage = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfilePage(model.user),
          ),
        );

        if (updatedMessage != null) {
          _showSnackBar(context, updatedMessage, true);
        }
        await model.reloadUserProfile();
        await model.firstFetchPosts();
      },
      style: TextButton.styleFrom(
        backgroundColor: Palette.mainColor,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_outlined),
          SizedBox(
            width: 4,
          ),
          Text('編集'),
        ],
      ),
    );
  }

  /// フォローボタンの表示
  Widget _showFollowButton(BuildContext context, UserModel model) {
    return TextButton(
      onPressed: () async {
        String? followedMessage = await model.followUser();
        if (followedMessage != null) {
          _showSnackBar(context, followedMessage, true);
        }
      },
      style: model.isFollowUser
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
          model.isFollowUser ? Icon(Icons.check) : Icon(Icons.add),
          Text('フォロー'),
        ],
      ),
    );
  }

  /// スナックバーを表示
  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
