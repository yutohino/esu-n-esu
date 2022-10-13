// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, use_build_context_synchronously, must_be_immutable

import 'package:esu_n_esu/colors/Palette.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/edit_profile/edit_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Menu { deleteAccount }

class EditProfilePage extends StatelessWidget {
  EditProfilePage(this.user);

  AppUser user;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditProfileModel>(
      create: (_) => EditProfileModel(user),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.mainColor,
          title: Text('プロフィール編集'),
          actions: [
            Consumer<EditProfileModel>(builder: (context, model, child) {
              return PopupMenuButton(
                onSelected: (Menu selectedItem) async {
                  if (selectedItem == Menu.deleteAccount) {
                    String? deleteMessage =
                        await _showDeleteMyAccountDialog(context, model);
                    if (deleteMessage == null) {
                      return;
                    }
                    model.startUploading();
                    try {
                      await model.deleteMyAccount();
                      _showSnackBar(context, 'アカウントを削除しました', true);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (_) => false,
                      );
                    } catch (e) {
                      _showSnackBar(context, 'アカウントの削除に失敗しました', false);
                      print(e.toString());
                    }
                    model.endUploading();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<Menu>>[
                    PopupMenuItem<Menu>(
                      value: Menu.deleteAccount,
                      child: Text('アカウント削除'),
                    ),
                  ];
                },
                icon: Icon(Icons.more_vert),
              );
            }),
          ],
        ),
        body: Stack(
          children: [
            Center(
              child:
                  Consumer<EditProfileModel>(builder: (context, model, child) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              await model.pickImage();
                            },
                            child: _showUserImage(model, 80),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: TextField(
                              controller: model.usernameController,
                              maxLength: 24,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'ユーザー名',
                                contentPadding: EdgeInsets.all(8),
                              ),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (text) {
                                model.setUsername(text);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        String? editedUserDetail =
                            await _showEditUserDetailDialog(context, model);
                        if (editedUserDetail != null) {
                          model.setUserDetail(editedUserDetail);
                        } else {
                          model.userDetailController.text = model.userDetail;
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        child: Text(
                          model.userDetail.isNotEmpty
                              ? model.userDetail
                              : '"自己紹介文"',
                          maxLines: 16,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.2,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          model.startUploading();
                          await model.saveEditedProfile();
                          Navigator.pop(context, 'プロフィールを更新しました');
                        } catch (e) {
                          _showSnackBar(context, 'プロフィールの更新に失敗しました', false);
                          print(e.toString());
                        } finally {
                          model.endUploading();
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Palette.mainColor,
                        shape: StadiumBorder(),
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      ),
                      child: Text(
                        '保存する',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            Consumer<EditProfileModel>(builder: (context, model, child) {
              if (model.isLoading) {
                return Container(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Palette.mainColor,
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }),
          ],
        ),
      ),
    );
  }

  /// ユーザー画像を表示
  Widget _showUserImage(EditProfileModel model, double size) {
    if (model.editedImageFile != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: FileImage(model.editedImageFile!),
              onError: (error, stackTrace) {
                print(stackTrace);
              },
              fit: BoxFit.cover),
        ),
      );
    }
    if (model.user.userImageUrl.isEmpty) {
      return Icon(
        Icons.account_circle,
        size: size,
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: NetworkImage(model.user.userImageUrl),
            onError: (error, stackTrace) {
              print(stackTrace);
            },
            fit: BoxFit.cover),
      ),
    );
  }

  /// 自己紹介編集ダイアログの表示
  Future _showEditUserDetailDialog(
          BuildContext context, EditProfileModel model) =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          insetPadding: EdgeInsets.all(16),
          title: Text('自己紹介文'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: model.userDetailController,
              autofocus: true,
              maxLength: 120,
              maxLines: 16,
              decoration: InputDecoration(
                hintText: '自己紹介文',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, model.userDetailController.text);
              },
              child: Text(
                '保存する',
                style: TextStyle(
                  color: Palette.mainColor,
                ),
              ),
            ),
          ],
        ),
      );

  /// アカウント削除の確認ダイアログの表示
  Future _showDeleteMyAccountDialog(
          BuildContext context, EditProfileModel model) =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('アカウントを削除すると、あなたの投稿したポストも全て削除されます。本当にアカウントを削除しますか?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'アカウントを削除しました');
              },
              child: Text(
                '削除する',
                style: TextStyle(
                  color: Palette.mainColor,
                ),
              ),
            ),
          ],
        ),
      );

  /// スナックバーを表示
  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
