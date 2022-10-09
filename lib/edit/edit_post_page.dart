// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, iterable_contains_unrelated_type

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/colors/Palette.dart';
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
          backgroundColor: Palette.mainColor,
          title: Text(post == null ? '新規投稿作成' : '編集'),
          actions: [
            Consumer<EditPostModel>(builder: (context, model, child) {
              final isActive = model.isUpdated();
              return TextButton(
                onPressed: isActive
                    ? () async {
                        try {
                          model.startUploading();
                          String uploadedMessage;
                          if (model.post == null) {
                            await model.uploadNewPost();
                            uploadedMessage = 'ポストを新規投稿しました';
                          } else {
                            await model.uploadExistingPost();
                            uploadedMessage = 'ポストを更新しました';
                          }
                          Navigator.pop(context, uploadedMessage);
                        } on FirebaseException catch (e) {
                          print("Failed with error '${e.code}': ${e.message}");
                          final snackBar = SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } finally {
                          model.endUploading();
                        }
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
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child:
                    Consumer<EditPostModel>(builder: (context, model, child) {
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
                                model.uploadedImageUrls.containsKey(index)) ...{
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
            Consumer<EditPostModel>(
              builder: (context, model, child) {
                if (model.isUploading) {
                  return Container(
                    // height: double.infinity,
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Palette.mainColor,
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyImageBox(EditPostModel model, int index) {
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

  Widget _pickedImageBox(BuildContext context, EditPostModel model, int index) {
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
      BuildContext context, EditPostModel model, int index) {
    return GestureDetector(
      onTap: () {
        _showChangeOrDeleteImageDialog(context, model, index);
      },
      child: Container(
          height: 80,
          width: 80,
          color: Colors.black12,
          child: Image.network(
            model.uploadedImageUrls[index] ?? '',
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Icon(
                Icons.image_not_supported_outlined,
                size: 80,
              );
            },
          )),
    );
  }

  /// 画像を変更 or 削除の確認ダイアログ
  Future _showChangeOrDeleteImageDialog(
      BuildContext context, EditPostModel model, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('${index + 1}番目の画像を削除または変更しますか?'),
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
