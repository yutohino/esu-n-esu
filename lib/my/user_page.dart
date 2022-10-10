// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, use_build_context_synchronously, must_be_immutable

import 'package:esu_n_esu/colors/Palette.dart';
import 'package:esu_n_esu/content/content_page.dart';
import 'package:esu_n_esu/domain/AppUser.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:esu_n_esu/edit/edit_post_page.dart';
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
      create: (_) => UserModel(user)..firstFetchPosts(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.mainColor,
          title: Text('マイページ'),
          actions: [
            Consumer<UserModel>(builder: (context, model, child) {
              return PopupMenuButton(
                onSelected: (Menu selectedItem) async {
                  if (selectedItem == Menu.followList) {
                    // TODO: フォローリスト画面に遷移する
                  } else if (selectedItem == Menu.bookMarkList) {
                    // TODO: ブックマーク画面に遷移する
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
              );
            }),
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

                return _buildListView(controller, model, posts);
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
          return FloatingActionButton(
            backgroundColor: Palette.mainColor,
            onPressed: () async {
              String? uploadMessage = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostPage(null),
                    fullscreenDialog: true,
                  ));

              if (uploadMessage != null) {
                _showSnackBar(context, uploadMessage, true);
              }
              await model.firstFetchPosts();
            },
            tooltip: '新規記事投稿',
            child: Icon(Icons.add),
          );
        }),
      ),
    );
  }

  /// タイムラインのListViewを作成
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
                        _showUserImage(model, model.user.userImageUrl, 28),
                        SizedBox(width: 4),
                        Text(
                          model.user.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
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

  /// ユーザーアイコンを表示
  Widget _showUserImage(UserModel model, String userImageUrl, double size) {
    if (userImageUrl.isEmpty) {
      return Icon(
        Icons.account_circle,
        size: size,
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          userImageUrl,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Icon(
              Icons.account_circle,
              size: size,
            );
          },
        ),
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
