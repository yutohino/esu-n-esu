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
                      GestureDetector(
                        onTap: () {
                          // TODO: PickImage
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Container(
                            color: Colors.black12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: PickImage
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Container(
                            color: Colors.black12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: PickImage
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Container(
                            color: Colors.black12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: PickImage
                        },
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Container(
                            color: Colors.black12,
                          ),
                        ),
                      ),
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
