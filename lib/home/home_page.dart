// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:esu_n_esu/content/content_page.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:esu_n_esu/edit/edit_post_page.dart';
import 'package:esu_n_esu/home/home_model.dart';
import 'package:esu_n_esu/login/login_page.dart';
import 'package:esu_n_esu/my/my_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel()..firstFetchPosts(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('ホーム'),
          actions: [
            Consumer<HomeModel>(builder: (context, model, child) {
              return IconButton(
                onPressed: () async {
                  if (FirebaseAuth.instance.currentUser != null) {
                    String? logoutMessage = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyPage(),
                        ));
                    if (logoutMessage != null) {
                      _showSuccessSnackBar(context, logoutMessage);
                      model.firstFetchPosts();
                    }
                  } else {
                    String? loginOrRegisterMessage = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ));
                    if (loginOrRegisterMessage != null) {
                      _showSuccessSnackBar(context, loginOrRegisterMessage);
                      model.firstFetchPosts();
                    }
                  }
                },
                icon: FirebaseAuth.instance.currentUser != null
                    ? _showUserImage(
                        model,
                        model
                            .fetchPostedUserInfo(
                                FirebaseAuth.instance.currentUser!.uid)!
                            .userImageUrl,
                        36)
                    : Icon(Icons.account_circle_outlined),
                iconSize: 36,
              );
            }),
          ],
        ),
        body: Center(
          child: Consumer<HomeModel>(builder: (context, model, child) {
            final posts = model.posts;
            if (posts.isEmpty) {
              if (!model.isFetchLastItem) {
                // ポストを取得するまでサークルを表示
                return CircularProgressIndicator();
              }
            }

            // ポストを10件ずつリスト表示する
            final controller = ScrollController();
            controller.addListener(() async {
              if (model.isFetchLastItem) {
                return;
              }
              if (controller.position.maxScrollExtent == controller.offset &&
                  !model.isLoading) {
                model.startLoading();
                model.fetchPosts();
                model.endLoading();
              }
            });

            return _buildListView(controller, model, posts);
          }),
        ),
        floatingActionButton:
            Consumer<HomeModel>(builder: (context, model, child) {
          if (FirebaseAuth.instance.currentUser == null) {
            return Container();
          }
          return FloatingActionButton(
            onPressed: () async {
              String? uploadMessage = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostPage(null),
                    fullscreenDialog: true,
                  ));

              if (uploadMessage != null) {
                _showSuccessSnackBar(context, uploadMessage);
              }
              model.firstFetchPosts();
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
      ScrollController controller, HomeModel model, List<Post> posts) {
    return RefreshIndicator(
      // ポストの情報を初期化 & 最初の10件を取得
      onRefresh: () async {
        model.reset();
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
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentPage(posts[index]),
                    ));
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
                          SizedBox(width: 8),
                        },
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _showUserImage(
                            model,
                            model.fetchPostedUserInfo(posts[index].uid) != null
                                ? model
                                    .fetchPostedUserInfo(posts[index].uid)!
                                    .userImageUrl
                                : '',
                            28),
                        SizedBox(width: 4),
                        Text(
                          model.fetchPostedUserInfo(posts[index].uid) != null
                              ? model
                                  .fetchPostedUserInfo(posts[index].uid)!
                                  .username
                              : '',
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
                    Text(
                      '投稿日 [${DateFormat('yyyy/MM/dd').format(posts[index].createdAt!)}]',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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
                  child: CircularProgressIndicator(),
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
  Widget _showUserImage(HomeModel model, String userImageUrl, double size) {
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

  /// 成功スナックバーを表示
  void _showSuccessSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
