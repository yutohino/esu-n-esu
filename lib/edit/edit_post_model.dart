// ignore_for_file: avoid_print

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
      title = post!.title;
      content = post!.content;
      titleController.text = post!.title;
      contentController.text = post!.content;
      int index = 0;
      for (var imageUrl in post!.imageUrls) {
        uploadedImageUrls[index] = imageUrl;
        index++;
      }
    }
  }

  bool isUploading = false;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String title = '';
  String content = '';
  Map<int, String> uploadedImageUrls = {};
  bool isChangeImage = false;

  final imagePicker = ImagePicker();
  Map<int, File> imageFiles = {};
  List<String> deleteImageUrls = [];

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

  Future pickImage(int index) async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFiles.addAll({index: File(pickedFile.path)});
      notifyListeners();
      if (post != null) {
        String deleteImageUrl = uploadedImageUrls.remove(index) ?? '';
        if (deleteImageUrl.isNotEmpty) {
          deleteImageUrls.add(deleteImageUrl);
        }
        isChangeImage = true;
      }
    }
  }

  bool isUpdated() {
    if (post != null) {
      return title.isNotEmpty && content.isNotEmpty && post!.title != title ||
          post!.content != content ||
          isChangeImage;
    } else {
      return title.isNotEmpty && content.isNotEmpty;
    }
  }

  /// アップロードした画像、または端末から取得した画像を削除
  void deleteImage(int index) {
    if (imageFiles.containsKey(index)) {
      imageFiles.remove(index);
    } else {
      String deleteImageUrl = uploadedImageUrls.remove(index) ?? '';
      deleteImageUrls.add(deleteImageUrl);
      isChangeImage = true;
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
    }

    // Firestoreに新規ポストをアップロード
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snapshot.data();
    final collection = FirebaseFirestore.instance.collection('posts');
    await collection.add({
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.now(),
      'editedAt': Timestamp.now(),
      'uid': data!['uid'],
      'isEdited': false,
    });
  }

  /// 投稿済みポストの編集をアップロード
  Future uploadExistingPost() async {
    final doc = FirebaseFirestore.instance.collection('posts').doc(post!.id);
    List<String> imageUrlsList = [];
    if (!isChangeImage) {
      imageUrlsList.addAll(post!.imageUrls);
    } else {
      // 変更 or 削除された画像をStorageから削除
      for (String deleteImageUrl in deleteImageUrls) {
        try {
          await FirebaseStorage.instance.refFromURL(deleteImageUrl).delete();
        } on FirebaseException catch (e) {
          print("Failed with error '${e.code}': ${e.message}");
        }
      }

      // 追加した画像をアップロード
      Map<int, String> imageUrls = {};
      for (final data in imageFiles.entries) {
        final index = data.key;
        final imageFile = data.value;
        final task = await FirebaseStorage.instance
            .ref('posts/${doc.id}${imageFile.hashCode}')
            .putFile(imageFile);
        final imgUrl = await task.ref.getDownloadURL();
        imageUrls[index] = imgUrl;
      }
      // 既存の画像とアップロードした画像のMapを結合 & インデックスの順番に並び替える
      uploadedImageUrls.addAll(imageUrls);
      SplayTreeMap.from(uploadedImageUrls, (int a, int b) => a.compareTo(b));
      // MapからListに変換
      for (var imageUrl in uploadedImageUrls.values) {
        imageUrlsList.add(imageUrl);
      }
    }

    // Firestoreに更新したポストをアップロード
    await FirebaseFirestore.instance.collection('posts').doc(post!.id).update({
      'title': title,
      'content': content,
      'imageUrls': imageUrlsList,
      'editedAt': Timestamp.now(),
      'isEdited': true,
    });
  }

  /// ポストを削除する
  Future deletePost() async {
    await FirebaseFirestore.instance.collection('posts').doc(post!.id).delete();
    // アップロードした画像をStorageから削除する
    for (String imageUrl in post!.imageUrls) {
      try {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      } on FirebaseException catch (e) {
        print("Failed with error '${e.code}': ${e.message}");
      }
    }
  }
}
