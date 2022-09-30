import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esu_n_esu/domain/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditPostModel extends ChangeNotifier {
  final Post? post;

  EditPostModel(this.post) {
    if (post != null) {
      titleController.text = post!.title!;
      contentController.text = post!.content!;
      imageUrls = post!.imageUrls!;
    }
  }

  bool isUploading = false;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String? title;
  String? content;
  List<String> imageUrls = [];

  final imagePicker = ImagePicker();
  Map<int, File> imageFiles = {};

  void startUploading() {
    isUploading = true;
    notifyListeners();
  }

  void endUploading() {
    isUploading = false;
    notifyListeners();
  }

  void setTitle(String title) {
    this.title = title;
    notifyListeners();
  }

  void setContent(String content) {
    this.content = content;
    notifyListeners();
  }

  Future getUploadedImage() async {
    // TODO: 画像取得処理(投稿済みのポストから) ※編集機能を作成時に実装する
    return null;
  }

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

  /// アップロードした画像、または端末から取得した画像を削除
  void deleteImage(int index) {
    if (imageFiles.containsKey(index)) {
      imageFiles.remove(index);
    } else {
      imageUrls.removeAt(index);
      // TODO: 削除した画像のURLを記憶して、編集保存時にStorageの削除処理をする
    }
    notifyListeners();
  }

  /// 新規ポストを投稿
  Future uploadNewPost() async {
    final doc = FirebaseFirestore.instance.collection('posts').doc();

    // 追加した画像をアップロード
    List<String> imageUrls = [];
    if (imageFiles.isNotEmpty) {
      // インデックスの順番に並び替える
      imageFiles = SplayTreeMap.from(imageFiles, (a, b) => a.compareTo(b));
      for (File imageFile in imageFiles.values) {
        final task = await FirebaseStorage.instance
            .ref('posts/${doc.id}${imageFile.hashCode}')
            .putFile(imageFile);
        final imgUrl = await task.ref.getDownloadURL();
        imageUrls.add(imgUrl);
      }
      this.imageUrls = imageUrls;
    }

    // Firestoreにポストをアップロード
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snapshot.data();
    final collection = FirebaseFirestore.instance.collection('posts');
    await collection.add({
      'title': title,
      'content': content,
      'imageUrls': this.imageUrls,
      'createdAt': Timestamp.now(),
      'editedAt': Timestamp.now(),
      'uid': data!['uid'],
      'isEdited': false,
    });
  }

  /// 投稿済みポストを編集完了
  Future uploadExistingPost() async {
    // TODO: Firestoreにアップロード
    // TODO: 画像の変更に応じて、Storageに画像をアップロードおよび削除をする
  }

  // TODO: 編集処理
  // TODO: アップロードした画像を削除 or 置き換えた場合、画像をStorageからも削除するようにする
}
