import 'dart:io';

import 'package:esu_n_esu/domain/post.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditPostModel extends ChangeNotifier {
  final Post? post;

  EditPostModel(this.post) {
    if (post != null) {
      titleController.text = post!.title!;
      contentController.text = post!.content!;
      imageUrls = post!.imageUrls;
    }
  }

  bool isUploading = false;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String? title;
  String? content;
  List<String>? imageUrls;

  final imagePicker = ImagePicker();
  Map<int, File> imageFiles = {};

  void startLoading() {
    isUploading = true;
    notifyListeners();
  }

  void endLoading() {
    isUploading = false;
    notifyListeners();
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setContent(String content) {
    this.content = content;
  }

  // TODO: 画像取得処理(投稿済みのポストから) ※編集機能を作成時に実装する

  Future pickImage(int index) async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFiles.addAll({index: File(pickedFile.path)});
      notifyListeners();
    }
  }

  bool isUpdated() {
    return title != null || content != null;
  }

  // TODO: 新規投稿処理

  // TODO: 編集処理
}
