// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, use_build_context_synchronously, must_be_immutable

import 'package:esu_n_esu/bookmark_list/bookmark_list_model.dart';
import 'package:esu_n_esu/colors/Palette.dart';
import 'package:esu_n_esu/content/content_page.dart';
import 'package:esu_n_esu/domain/app_user.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookmarkListPage extends StatelessWidget {
  BookmarkListPage(this.loginUser);

  AppUser loginUser;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookmarkListModel>(
      create: (_) => BookmarkListModel(loginUser)..initProc(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.mainColor,
          title: Text('ブックマークリスト'),
        ),
        body: Center(
          child: Consumer<BookmarkListModel>(builder: (context, model, child) {
            final posts = model.posts;
            if (posts.isEmpty) {
              if (!model.isFetchLastItem) {
                // ポストを取得するまでサークルを表示
                return CircularProgressIndicator(
                  color: Palette.mainColor,
                );
              }
            }

            // ポストを10件ずつリスト表示する
            final controller = ScrollController();
            controller.addListener(() async {
              if (model.isFetchLastItem) {
                return;
              }
              if (controller.position.pixels >=
                      controller.position.maxScrollExtent * 0.9 &&
                  !model.isLoading) {
                model.startLoading();
                await model.fetchBookmarkList();
                model.endLoading();
              }
            });

            return _buildListView(controller, model, posts);
          }),
        ),
      ),
    );
  }

  /// ブックマーク一覧のListViewを作成
  Widget _buildListView(
      ScrollController controller, BookmarkListModel model, List<Post> posts) {
    return RefreshIndicator(
      // ポストの情報を初期化 & 最初の10件を取得
      onRefresh: () async {
        await model.initProc();
      },
      child: ListView.separated(
        controller: controller,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: posts.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index < posts.length) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                bool? isUpdatedOrDeletedPost = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentPage(posts[index],
                          model.getPostedUserInfo(posts[index].uid)!),
                    ));
                if (isUpdatedOrDeletedPost != null && isUpdatedOrDeletedPost) {
                  await model.initProc();
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      posts[index].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      posts[index].content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.2,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        for (String imageUrl in posts[index].imageUrls) ...{
                          Container(
                            color: Colors.black12,
                            child: Image.network(
                              imageUrl,
                              height: 80,
                              width: 80,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 80,
                                );
                              },
                            ),
                          ),
                          if (imageUrl != posts[index].imageUrls.last)
                            SizedBox(width: 8),
                        },
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _showUserImage(
                            model.getPostedUserInfo(posts[index].uid) != null
                                ? model
                                    .getPostedUserInfo(posts[index].uid)!
                                    .userImageUrl
                                : '',
                            28),
                        SizedBox(width: 4),
                        Text(
                          model.getPostedUserInfo(posts[index].uid) != null
                              ? model
                                  .getPostedUserInfo(posts[index].uid)!
                                  .username
                              : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '投稿日 [${DateFormat('yyyy/MM/dd').format(posts[index].createdAt!)}]',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        if (posts[index].isEdited)
                          Text(
                            '編集日 [${DateFormat('yyyy/MM/dd').format(posts[index].editedAt!)}]',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            if (model.isFetchLastItem) {
              // ポストを最後まで読み込んだらインジケータを表示しない
              return Container();
            } else {
              // 最下部にポストの追加読み込みインジケーターを表示
              return SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Palette.mainColor,
                  ),
                ),
              );
            }
          }
        },
        separatorBuilder: (BuildContext context, int index) => Container(
          width: double.infinity,
          height: 0.25,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// ユーザー画像を表示
  Widget _showUserImage(String userImageUrl, double size) {
    if (userImageUrl.isEmpty) {
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
            image: NetworkImage(userImageUrl),
            onError: (error, stackTrace) {
              print(stackTrace);
            },
            fit: BoxFit.cover),
      ),
    );
  }
}
