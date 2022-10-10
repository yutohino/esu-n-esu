// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:esu_n_esu/colors/Palette.dart';
import 'package:esu_n_esu/login/login_model.dart';
import 'package:esu_n_esu/register/register_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginModel>(
      create: (_) => LoginModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.mainColor,
          title: Text('ログイン'),
        ),
        body: Center(
          child: Consumer<LoginModel>(builder: (context, model, child) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: model.emailController,
                        decoration: InputDecoration(
                          hintText: 'メールアドレス',
                        ),
                        onChanged: (text) {
                          model.setEmail(text);
                        },
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: model.passwordController,
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.mainColor,
                        ),
                        onPressed: () async {
                          try {
                            model.startLoading();
                            await model.login();
                            Navigator.pop(context, 'ログインしました');
                          } catch (e) {
                            _showSnackBar(context, e.toString(), false);
                          } finally {
                            model.endLoading();
                          }
                        },
                        child: Text('ログイン'),
                      ),
                      TextButton(
                        onPressed: () async {
                          String? registeredMessage = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                                fullscreenDialog: true,
                              ));
                          if (registeredMessage != null) {
                            Navigator.pop(context, registeredMessage);
                          }
                        },
                        child: Text(
                          '新規登録の方はこちら',
                          style: TextStyle(
                            color: Palette.mainColor,
                          ),
                        ),
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
