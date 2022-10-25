// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, iterable_contains_unrelated_type, use_build_context_synchronously

import 'package:esu_n_esu/colors/Palette.dart';
import 'package:esu_n_esu/content/content_model.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:esu_n_esu/edit_post/edit_post_page.dart';
import 'package:esu_n_esu/my/user_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum Menu { postEdit }

class ContentPage extends StatelessWidget {
  final Post post;
  final AppUser user; // 投稿者のユーザー情報

  ContentPage(this.post, this.user);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContentModel>(
      create: (_) => ContentModel(post, user)..initProc(),
      child: Consumer<ContentModel>(
        builder: (context, model, child) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, model.isUpdatedPost);
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Palette.mainColor,
                title: Text(model.post.title),
                actions: [
                  if (model.loginUser != null &&
                      model.post.uid == model.loginUser!.id)
                    Consumer<ContentModel>(builder: (context, model, child) {
                      return PopupMenuButton(
                        onSelected: (Menu selectedItem) async {
                          String? status = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPostPage(model.post),
                              ));
                          if (status == '更新') {
                            await model.reloadPost();
                          }
                          if (status == '削除') {
                            model.flagDeletedPost();
                            Navigator.pop(context, model.isDeletedPost);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<Menu>>[
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.post.title,
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
                        '投稿日 [${DateFormat('yyyy/MM/dd').format(model.post.createdAt!)}]',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      if (model.post.isEdited)
                        Text(
                          '編集日 [${DateFormat('yyyy/MM/dd').format(model.post.editedAt!)}]',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      SizedBox(
                        height: 4,
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserPage(user),
                              ));
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
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      return Icon(
                                        Icons.account_circle,
                                        size: 36,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  user.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
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
                        children: [
                          for (String imageUrl in model.post.imageUrls) ...{
                            _uploadedImageBox(context, imageUrl),
                            if (model.post.imageUrls.length == 1 ||
                                imageUrl != model.post.imageUrls.last)
                              SizedBox(
                                width: 8,
                              ),
                          },
                        ],
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Text(
                        model.post.content,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      if (model.loginUser != null) ...{
                        // ログイン中 & 他ユーザーのアカウントの場合
                        _showBookmarkButton(context, model),
                      },
                      SizedBox(
                        height: 32,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _uploadedImageBox(BuildContext context, String imageUrl) {
    return InkWell(
      onTap: () {
        _showImageDialog(context, imageUrl);
      },
      child: Container(
        height: 80,
        width: 80,
        color: Colors.black12,
        child: Image.network(
          imageUrl,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Icon(
              Icons.image_not_supported_outlined,
              size: 80,
            );
          },
        ),
      ),
    );
  }

  /// 画像をダイアログで表示する
  Future _showImageDialog(BuildContext context, String imageUrl) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          insetPadding: EdgeInsets.all(16),
          content: SizedBox(
            height: 500,
            width: 500,
            child: Image.network(
              imageUrl,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return Icon(
                  Icons.image_not_supported_outlined,
                  size: 500,
                );
              },
            ),
          ),
        ),
      );

  /// ブックマークボタンの表示
  Widget _showBookmarkButton(BuildContext context, ContentModel model) {
    return TextButton(
      onPressed: () async {
        String? followedMessage = await model.bookmarkPost();
        if (followedMessage != null) {
          _showSnackBar(context, followedMessage, true);
        }
      },
      style: model.isBookmark
          ? TextButton.styleFrom(
              backgroundColor: Palette.mainColor,
              foregroundColor: Colors.white,
              shape: StadiumBorder(),
              padding: EdgeInsets.all(10),
            )
          : TextButton.styleFrom(
              foregroundColor: Palette.mainColor,
              shape: StadiumBorder(),
              side: BorderSide(color: Palette.mainColor),
              padding: EdgeInsets.all(10),
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          model.isBookmark
              ? Icon(Icons.bookmark_added)
              : Icon(Icons.bookmark_add_outlined),
          Text('ブックマーク'),
        ],
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
