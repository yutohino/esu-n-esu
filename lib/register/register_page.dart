// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:esu_n_esu/colors/Palette.dart';
import 'package:esu_n_esu/register/register_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterModel>(
      create: (_) => RegisterModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.mainColor,
          title: Text('新規登録'),
        ),
        body: Center(
          child: Consumer<RegisterModel>(builder: (context, model, child) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: model.titleController,
                        decoration: InputDecoration(
                          hintText: 'メールアドレス',
                        ),
                        onChanged: (text) {
                          model.setEmail(text);
                        },
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: model.usernameController,
                        maxLength: 24,
                        decoration: InputDecoration(
                          hintText: 'ユーザー名',
                        ),
                        onChanged: (text) {
                          model.setUsername(text);
                        },
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: model.authorController,
                        maxLength: 20,
                        decoration: InputDecoration(
                          hintText: 'パスワード',
                        ),
                        obscureText: true,
                        onChanged: (text) {
                          model.setPassword(text);
                        },
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () async {
                          model.startLoading();
                          // アカウント登録
                          try {
                            await model.signUp();
                            Navigator.pop(context, '新規登録しました');
                          } catch (e) {
                            _showSnackBar(context, e.toString(), false);
                          } finally {
                            model.endLoading();
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Palette.mainColor,
                          foregroundColor: Colors.white,
                          shape: StadiumBorder(),
                          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                        ),
                        child: Text('登録する'),
                      ),
                    ],
                  ),
                ),
                if (model.isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Palette.mainColor,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
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
