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
            if (posts.isEmpty) {
              // ポストを取得するまでサークルを表示
              return CircularProgressIndicator();
            }

            // ポストを20件ずつリスト表示する
            final controller = ScrollController();
            controller.addListener(() async {
              // TODO: 最下部までスクロールした時の挙動を書く
            });
            return ListView.separated(
              controller: controller,
              itemCount: model.posts.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < posts.length) {
                  return Container(
                    height: 200, // TODO: 高さを可変できるようにしたい
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
                  );
                } else {
                  // 最下部までスクロール時の追加読み込み表示
                  return SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
              separatorBuilder: (BuildContext context, int index) => Container(
                width: double.infinity,
                height: 0.5,
                color: Colors.grey,
              ),
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
