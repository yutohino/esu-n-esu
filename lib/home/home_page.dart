// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:esu_n_esu/home/home_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel()..fetchPosts(), // TODO: 必要な情報を取得する
      child: Scaffold(
        appBar: AppBar(
          title: Text('ホーム'),
          actions: [
            IconButton(
              onPressed: () {
                // TODO: ローディング中はタップできないようにする
                // TODO: マイページ or ログイン画面に遷移
              },
              icon: Icon(Icons.account_circle_outlined),
              iconSize: 36,
            ),
          ],
        ),
        body: Center(
          child: Consumer<HomeModel>(builder: (context, model, child) {
            final posts = model.posts;
            if (posts == null) {
              // ポストを取得するまでサークルを表示
              return CircularProgressIndicator();
            }

            // ポストを全件リスト表示する
            return ListView(
              children: posts
                  .map((post) => Container(
                        height: 200, // TODO: 高さを可変できるようにしたい
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title!,
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
                              post.content!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                // TODO: 枚数に応じて画像を表示できるようにする
                                Image.network(
                                  'https://pbs.twimg.com/media/CqRhw4dVMAAmnR1.jpg',
                                  height: 50,
                                ),
                                SizedBox(width: 8),
                                Image.network(
                                  'https://pbs.twimg.com/media/CqRhw4dVMAAmnR1.jpg',
                                  height: 50,
                                ),
                              ],
                            )
                          ],
                        ),
                      ))
                  .toList(),
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: 投稿作成画面
          },
          tooltip: '新規記事投稿',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
