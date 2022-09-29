// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:esu_n_esu/edit/edit_post_page.dart';
import 'package:esu_n_esu/my/my_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyModel>(
      create: (_) => MyModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('マイページ'),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: ログアウト処理(終わったらホーム画面に戻る)
              },
              child: Text('ログアウト'),
            ),
          ],
        ),
        body: Center(
          child: Consumer<MyModel>(builder: (context, model, child) {
            final posts = model.posts;
            if (posts.isEmpty) {
              // ポストを取得するまでサークルを表示
              return CircularProgressIndicator();
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

            return RefreshIndicator(
              // ポストの情報を初期化 & 最初の10件を取得
              onRefresh: () async {
                model.reset();
                model.firstFetchPosts();
              },
              child: ListView.separated(
                controller: controller,
                itemCount: posts.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index < posts.length) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            posts[index].title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            posts[index].content!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              for (String imageUrl
                                  in posts[index].imageUrls!) ...{
                                Container(
                                  color: Colors.black12,
                                  child: Image.network(
                                    imageUrl,
                                    height: 80,
                                    width: 80,
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
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
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 0.5,
                                    color: Colors.black87,
                                  ),
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                      posts[index].userImageUrl!,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                posts[index].username!,
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
                separatorBuilder: (BuildContext context, int index) =>
                    Container(
                  width: double.infinity,
                  height: 0.25,
                  color: Colors.grey,
                ),
              ),
            );
          }),
        ),
        floatingActionButton:
            Consumer<MyModel>(builder: (context, model, child) {
          return FloatingActionButton(
            // TODO: ログアウトの状態ではボタンを隠す(記事投稿にアカウント情報も保存するため)
            onPressed: () async {
              String? uploaded = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostPage(null),
                    fullscreenDialog: true,
                  ));

              if (uploaded != null) {
                final snackBar = SnackBar(
                  content: Text(uploaded),
                  backgroundColor: Colors.green,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
}
