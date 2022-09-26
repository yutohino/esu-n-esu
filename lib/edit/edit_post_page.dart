// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:esu_n_esu/domain/post.dart';
import 'package:esu_n_esu/edit/edit_post_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditPostPage extends StatelessWidget {
  final Post? post;

  EditPostPage(this.post);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditPostModel>(
      create: (_) => EditPostModel(post),
      child: Scaffold(
        appBar: AppBar(
          title: Text(post == null ? '新規投稿作成' : '編集'),
          actions: [
            Consumer<EditPostModel>(builder: (context, model, child) {
              final isActive = model.isUpdated();
              return TextButton(
                onPressed: isActive
                    ? () async {
                        // TODO: 投稿処理
                      }
                    : null,
                child: Text(
                  '投稿',
                  style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.5)),
                ),
              );
            }),
          ],
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Consumer<EditPostModel>(builder: (context, model, child) {
              return Column(
                children: [
                  TextField(
                    controller: model.titleController,
                    maxLength: 50,
                    style: TextStyle(
                      fontSize: 24,
                    ),
                    decoration: InputDecoration(
                      hintText: 'タイトル',
                    ),
                    onChanged: (text) {
                      model.setTitle(text);
                    },
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: model.contentController,
                    maxLength: 2200,
                    maxLines: 20,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: '内容',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      model.setContent(text);
                    },
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < 4; i++) ...{
                        //
                        if (model.post == null) ...{
                          if (model.imageFiles.containsKey(i)) ...{
                            // 端末から取得した画像を表示
                            // TODO: book-list-sampleのリスト項目みたいに
                            // TODO: メソッドでWidgetを返す（あとmodel.imageFiles[i]!の分岐は共通化できそう）
                          } else ...{
                            GestureDetector(
                              onTap: () async {
                                await model.pickImage(i);
                                print('画像なし');
                              },
                              onLongPress: () {
                                // TODO: 削除
                              },
                              child: Container(
                                height: 80,
                                width: 80,
                                color: Colors.black12,
                              ),
                            ),
                          },
                        },
                        if (model.post != null) ...{
                          if (model.post!.imageUrls!.contains(i)) ...{
                            // ポストにアップロード済みの画像を表示
                            GestureDetector(
                              onTap: () async {
                                // TODO: 削除、または編集か質問ダイアログ出す
                                await model.pickImage(i);
                                print('うp済み');
                              },
                              onLongPress: () {
                                // TODO: 削除
                              },
                              child: Image.network(model.post!.imageUrls![i]),
                            ),
                          } else if (model.imageFiles.containsKey(i)) ...{
                            // 端末から取得した画像を表示
                            GestureDetector(
                              onTap: () async {
                                await model.pickImage(i);
                                print('端末から取得済み');
                              },
                              onLongPress: () {
                                // TODO: 削除
                              },
                              child: Container(
                                height: 80,
                                width: 80,
                                color: Colors.black12,
                                child: Image.file(model.imageFiles[i]!),
                              ),
                            ),
                          } else ...{
                            GestureDetector(
                              onTap: () async {
                                await model.pickImage(i);
                                print('画像なし');
                              },
                              onLongPress: () {
                                // TODO: 削除
                              },
                              child: Container(
                                height: 80,
                                width: 80,
                                color: Colors.black12,
                              ),
                            ),
                          },
                        },
                        if (i < 3) ...{
                          Expanded(
                            child: SizedBox(),
                          ),
                        },
                      },
                    ],
                  ),
                  SizedBox(
                    height: 32,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
