// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, iterable_contains_unrelated_type

import 'package:esu_n_esu/content/content_model.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContentPage extends StatelessWidget {
  final Post? post;

  ContentPage(this.post);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContentModel>(
      create: (_) => ContentModel(post),
      child: Scaffold(
        appBar: AppBar(
          title: Text('投稿内容'),
          actions: [
            Consumer<ContentModel>(builder: (context, model, child) {
              // TODO: 自分の記事の場合は編集ボタンを表示「...」をタップしたら「編集」を表示する
              return Container();
            }),
          ],
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Consumer<ContentModel>(builder: (context, model, child) {
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
                      for (int index = 0; index < 4; index++) ...{
                        if (model.imageFiles.containsKey(index)) ...{
                          // 端末から取得した画像
                          _pickedImageBox(context, model, index),
                        } else if (model.post != null &&
                            model.post!.imageUrls.contains(index)) ...{
                          // アップロード済みの画像
                          _uploadedImageBox(context, model, index)
                        } else ...{
                          // 画像なし
                          _emptyImageBox(model, index),
                        },
                        if (index < 3) ...{
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

  Widget _emptyImageBox(ContentModel model, int index) {
    return GestureDetector(
      onTap: () async {
        await model.pickImage(index);
      },
      child: Container(
        height: 80,
        width: 80,
        color: Colors.black12,
      ),
    );
  }

  Widget _pickedImageBox(BuildContext context, ContentModel model, int index) {
    return GestureDetector(
      onTap: () {
        _showChangeOrDeleteImageDialog(context, model, index);
      },
      child: Container(
        height: 80,
        width: 80,
        color: Colors.black12,
        child: Image.file(model.imageFiles[index]!),
      ),
    );
  }

  Widget _uploadedImageBox(
      BuildContext context, ContentModel model, int index) {
    return GestureDetector(
      onTap: () {
        _showChangeOrDeleteImageDialog(context, model, index);
      },
      child: Container(
          height: 80,
          width: 80,
          color: Colors.black12,
          child: Image.network(model.post!.imageUrls[index])),
    );
  }

  /// 画像を変更 or 削除の確認ダイアログ
  Future _showChangeOrDeleteImageDialog(
      BuildContext context, ContentModel model, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('$index番目の画像を削除または変更しますか?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text('変更'),
              onPressed: () async {
                Navigator.pop(context);
                await model.pickImage(index);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text('削除'),
              onPressed: () {
                Navigator.pop(context);
                model.deleteImage(index);
              },
            ),
          ],
        );
      },
    );
  }
}
