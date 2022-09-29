// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, use_build_context_synchronously

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
                        decoration: InputDecoration(
                          hintText: 'パスワード',
                        ),
                        obscureText: true,
                        onChanged: (text) {
                          model.setPassword(text);
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          model.startLoading();
                          // アカウント登録
                          try {
                            await model.signUp();
                            // ログイン画面の遷移履歴を削除し、home画面に遷移
                            Navigator.pop(context, '新規登録しました');
                            // Navigator.pushNamedAndRemoveUntil(
                            // context, '/home', (_) => false);
                            // final snackBar = SnackBar(
                            //   content: Text('新規登録しました'),
                            //   backgroundColor: Colors.red,
                            // );
                            // ScaffoldMessenger.of(context)
                            //     .showSnackBar(snackBar);
                          } catch (e) {
                            final snackBar = SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } finally {
                            model.endLoading();
                          }
                        },
                        child: Text('登録する'),
                      ),
                    ],
                  ),
                ),
                if (model.isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
