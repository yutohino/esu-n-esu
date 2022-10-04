// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, iterable_contains_unrelated_type, use_build_context_synchronously

import 'package:esu_n_esu/colors/Palette.dart';
import 'package:esu_n_esu/content/content_model.dart';
import 'package:esu_n_esu/domain/AppUser.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:esu_n_esu/edit/edit_post_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum Menu { postEdit }

class ContentPage extends StatelessWidget {
  final Post post;
  final AppUser user;

  ContentPage(this.post, this.user);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContentModel>(
      create: (_) => ContentModel(post),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.mainColor,
          title: Text(post.title),
          actions: [
            if (FirebaseAuth.instance.currentUser != null &&
                post.uid == FirebaseAuth.instance.currentUser!.uid)
              Consumer<ContentModel>(builder: (context, model, child) {
                return PopupMenuButton(
                  onSelected: (Menu selectedItem) async {
                    String? editedMessage = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPostPage(post),
                        ));
                    if (editedMessage != null) {
                      _showSuccessSnackBar(context, editedMessage);
                      // TODO: 内容を更新する
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                    PopupMenuItem<Menu>(
                      value: Menu.postEdit,
                      child: Text('編集'),
                    ),
                  ],
                  icon: Icon(Icons.more_vert),
                );
              }),
          ],
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Consumer<ContentModel>(builder: (context, model, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    '投稿日 [${DateFormat('yyyy/MM/dd').format(post.createdAt!)}]',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  if (post.isEdited)
                    Text(
                      '編集日 [${DateFormat('yyyy/MM/dd').format(post.editedAt!)}]',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  SizedBox(
                    height: 4,
                  ),
                  InkWell(
                    onTap: () {
                      // TODO: ポストを投稿したユーザーのページに移動
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 5, 20, 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                user.userImageUrl,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Icon(
                                    Icons.account_circle,
                                    size: 36,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            user.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (String imageUrl in post.imageUrls) ...{
                        _uploadedImageBox(context, imageUrl),
                        if (post.imageUrls.length == 1 ||
                            imageUrl != post.imageUrls.last)
                          Expanded(
                            child: SizedBox(),
                          ),
                      },
                    ],
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  // TODO: ブックマーク済みと未ブックマークで表示を変える
                  OutlinedButton(
                    onPressed: () {
                      // TODO: ブックマークとして登録する
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Palette.mainColor,
                      shape: StadiumBorder(),
                      side: BorderSide(color: Palette.mainColor),
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_add_outlined),
                        SizedBox(
                          width: 4,
                        ),
                        Text('ブックマーク'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: ブックマークを解除する
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.mainColor,
                      foregroundColor: Colors.white,
                      shape: StadiumBorder(),
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark),
                        SizedBox(
                          width: 4,
                        ),
                        Text('ブックマーク'),
                      ],
                    ),
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

  Widget _uploadedImageBox(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () {
        // TODO: ポップアップ表示的なことをする
      },
      child: Container(
        height: 80,
        width: 80,
        color: Colors.black12,
        child: Image.network(imageUrl),
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
